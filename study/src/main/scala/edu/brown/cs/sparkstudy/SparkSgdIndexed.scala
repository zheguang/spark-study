package edu.brown.cs.sparkstudy

import edu.brown.cs.sparkstudy.CfSgdCommon._
import org.apache.spark.rdd.RDD
import org.apache.spark.storage.StorageLevel
import org.apache.spark._
import org.apache.spark.util.{CollectionsUtils, Utils}

import scala.collection.mutable

object SparkSgdIndexed extends Logging {

  def main(args: Array[String]) = {
    if (args.length < argNames.length) {
      printUsage("SparkSgd")
      System.exit(123)
    }
    val sc = new SparkContext(new SparkConf())
    sc.setLogLevel("OFF")

    val measure = args(0).toLowerCase
    val algebran = algebrans(measure)
    val num_latent = args(1).toInt
    val filePath = args(2)
    val num_users = args(3).toInt // never used, will compute from ratings
    val num_items = args(4).toInt // never used, will compute from ratings
    val num_ratings = args(5).toInt // never used, will compute from ratings
    val num_procs = args(6).toInt
    val num_nodes = 1

    val data = sc.textFile(s"file://$filePath")
    val ratings = data.map(_.split(" ") match {
      case Array(user, item, rate) =>
        Rating(user.toInt, item.toInt, rate.toDouble)
    }).setName("ratings")

    val numUserBlocks = num_nodes * num_procs
    val numItemBlocks = num_nodes * num_procs
    println(s"[sam] init: ratings count: ${ratings.count()}, numUserBlocks: $numUserBlocks, numItemBlocks: $numItemBlocks")

    val userPart = new HashPartitioner(numUserBlocks)
    val itemPart = new HashPartitioner(numItemBlocks)

    //val (ratingsBlocksDenormalized, ratingsBlocksNormalized) = partitionRatings(ratings, userPart, itemPart)
    val ratingsBlocks = partitionRatings(ratings, userPart, itemPart)
    var (usersBlocks, itemsBlocks) = makeFactorsBlocks(userPart, itemPart, ratingsBlocks, num_latent)
    // Uncommented when getting training per-iteration time without U-I init time
    // materialize
    usersBlocks.foreachPartition(_ => {})
    itemsBlocks.foreachPartition(_ => {})

    val start = System.currentTimeMillis()

    val maxNumIters = 5
    val numDiagnalRounds = numItemBlocks
    var gamma = 0.001

    val originalUsersBlocks = usersBlocks
    val originalItemsBlocks = itemsBlocks

    val ratingsBlocksInRounds = new Array[RDD[((UsersBlockId, ItemsBlockId), RatingsBlock)]](numDiagnalRounds)
    var round = 0
    while (round < numDiagnalRounds) {
      ratingsBlocksInRounds(round) = ratingsBlocks.filter {
          case ((usersBlockId, itemsBlockId), _) => (usersBlockId + round) % numDiagnalRounds == itemsBlockId
        }.setName(s"ratingsBlocksInRound(r$round)") // preserves partitioning
          .persist()
      round += 1
    }

    var iter = 0
    val previousUirBlocks = mutable.ArrayBuilder.make[RDD[((UsersBlockId, ItemsBlockId), (UsersBlock, ItemsBlock))]]
    while (iter < maxNumIters) {
      var round = 0
      while (round < numDiagnalRounds) {
        val ratingsBlocksInRound = ratingsBlocksInRounds(round)

        val uirBlocksInRound = itemsBlocks.keyBy {
          case (itemsBlockId, _) =>
            (itemsBlockId + round * (numDiagnalRounds - 1)) % numDiagnalRounds
        }.setName(s"I.keyBy(i$iter)(r$round)")
          .join(usersBlocks, new HashPartitioner(userPart.numPartitions))
          .setName(s"I.join(U)(i$iter)(r$round)")
          .map {
          case (usersBlockId, ((itemsBlockId, itemsBlock), usersBlock)) =>
            ((usersBlockId, itemsBlockId), (usersBlock, itemsBlock))
        }.setName(s"I.join(U).map(i$iter)(r$round)")
          .join(ratingsBlocksInRound, ratingsBlocks.partitioner.get)
          .setName(s"I.join(U, R).map.join(i$iter)(r$round)")

        val uirBlocksInRoundUpdated = uirBlocksInRound.mapValues {
          case ((usersBlock, itemsBlock), RatingsBlock(users, items, rates)) =>
            // Within one ratingsBlock, have to be sequential because of
            // multiple write-read dependencies for each uesr and item factor
            var i = 0
            while (i < rates.length) {
              val userFactor = usersBlock.factors(usersBlock.users(users(i)))
              val itemFactor = itemsBlock.factors(itemsBlock.items(items(i)))
              val pred = algebran.dotP(num_latent, userFactor, 0, itemFactor, 0)
              val err = pred - rates(i)
              (0 until num_latent).foreach { j =>
                userFactor(j) += - gamma * (err * itemFactor(j) + LAMBDA * userFactor(j))
                itemFactor(j) += - gamma * (err * userFactor(j) + LAMBDA * itemFactor(j))
              }
              i += 1
            }
            (usersBlock, itemsBlock)
        }.setName(s"uirBlocksUpdated(i$iter)(r$round)")
          .persist(StorageLevel.MEMORY_ONLY)

        // update usersBlocks and itemsBlocks with counterparts in uriBlocks
        usersBlocks = uirBlocksInRoundUpdated.mapPartitions({
          x => x.map {
            case ((usersBlockId, _), (usersBlock, _)) => (usersBlockId, usersBlock)
          }
        }, true)
        usersBlocks.setName(s"U(i$iter)(r$round)")

        itemsBlocks = uirBlocksInRoundUpdated.map {
          case ((_, itemsBlockId), (_, itemsBlock)) => (itemsBlockId, itemsBlock)
        }
        itemsBlocks.setName(s"I(i$iter(r$round)")

        previousUirBlocks += uirBlocksInRoundUpdated

        round += 1
      }
      gamma *= STEP_DEC
      iter += 1
    }

    // materialize results
    usersBlocks.persist(StorageLevel.MEMORY_ONLY)
    itemsBlocks.persist(StorageLevel.MEMORY_ONLY)
    val finalUsersCount = usersBlocks.count() // make sure work is done and measured
    val finalItemsCount = itemsBlocks.count()

    // clean up
    previousUirBlocks.result().foreach(_.unpersist(false))
    ratingsBlocksInRounds.foreach(_.unpersist(false))
    ratingsBlocks.unpersist(false)
    originalUsersBlocks.unpersist(false)
    originalItemsBlocks.unpersist(false)

    val end = System.currentTimeMillis()
    println(s"[sam] Time in iterations of sgd ${(end - start) / maxNumIters} (ms)")


    println(s"[sam] usersBlocks size: $finalUsersCount, itemsBlocks size: $finalItemsCount")
    println(s"[sam] usersBlocks parts: ${usersBlocks.partitions.length}, itemsBlocks parts: ${itemsBlocks.partitions.length}")
    val trainErr = computeTrainingError(algebran, usersBlocks, itemsBlocks, ratingsBlocks)
    println(s"[sam] training rmse $trainErr")
    println(s"[sam] finished training for total iterations: $maxNumIters")

    sc.stop()
  }

  private def makeFactorsBlocks(userPart: HashPartitioner,
                                itemPart: HashPartitioner,
                                ratingsBlocks: RDD[((UsersBlockId, ItemsBlockId), RatingsBlock)],
                                num_latent: Int): (RDD[(UsersBlockId, UsersBlock)], RDD[(ItemsBlockId, ItemsBlock)]) = {
    // aggregate by user-block ids to create user blocks, each with unique user
    // ids that are shared across different item blocks
    val usersBlocks = ratingsBlocks.map {
      case ((usersBlockId, _), RatingsBlock(users, _, _)) => (usersBlockId, users)
    }.aggregateByKey(new UsersBlockBuilder(num_latent), new HashPartitioner(userPart.numPartitions))(
        seqOp = (b, us) => b.add(us),
        combOp = (b1, b2) => b1.merge(b2.build()))
      .mapValues(_.build())
      .setName("usersBlocks")
      .persist(StorageLevel.MEMORY_ONLY)

    // aggregate by item-block ids to create item blocks, each with unique
    // item ids that are shared acrosss different user blocks
    val itemsBlocks = ratingsBlocks.map {
      case ((_, itemsBlockId), RatingsBlock(_, items, _)) => (itemsBlockId, items)
    }.aggregateByKey(new ItemsBlockBuilder(num_latent), new HashPartitioner(itemPart.numPartitions))(
        seqOp = (b, is) => b.add(is),
        combOp = (b1, b2) => b1.merge(b2.build()))
      .mapValues(_.build())
      .setName("itemsBlocks")
      .persist(StorageLevel.MEMORY_ONLY)

    (usersBlocks, itemsBlocks)
  }

  class RatingsBlocksPartitioner(partitions: Int) extends HashPartitioner(partitions) {
    override def getPartition(key: Any): Int = key match {
      case (k, _) => super.getPartition(k)
      case _ => super.getPartition(key)
    }
  }

  //private def partitionRatings(ratings: RDD[Rating], userPart: HashPartitioner, itemPart: HashPartitioner): (RDD[((UsersBlockId, ItemsBlockId), RatingsBlockDenormalized)], RDD[((UsersBlockId, ItemsBlockId), RatingsBlockNormalized)]) = {
  private def partitionRatings(ratings: RDD[Rating], userPart: HashPartitioner, itemPart: HashPartitioner): RDD[((UsersBlockId, ItemsBlockId), RatingsBlock)] = {
    ratings.map { r =>
      ((userPart.getPartition(r.user), itemPart.getPartition(r.item)), r)
    }.aggregateByKey(new RatingsBlockDenormalizedBuilder)(
        seqOp = (b, r) => b.add(r),
        combOp = (b1, b2) => b1.merge(b2.build()))
      .mapValues(_.build())
      .partitionBy(new RatingsBlocksPartitioner(userPart.numPartitions))
      .setName("ratingsBlockDenormalized")
      .persist(StorageLevel.MEMORY_ONLY)
  }

  //private def computeTrainingError(usersBlocks: RDD[(UsersBlockId, UsersBlock)], itemsBlocks: RDD[(ItemsBlockId, ItemsBlock)], ratingsBlocks: RDD[((UsersBlockId, ItemsBlockId), RatingsBlockNormalized)]): Double = {
  private def computeTrainingError(algebran: Algebran, usersBlocks: RDD[(UsersBlockId, UsersBlock)], itemsBlocks: RDD[(ItemsBlockId, ItemsBlock)], ratingsBlocks: RDD[((UsersBlockId, ItemsBlockId), RatingsBlock)]): Double = {
    /*val usersBlockMap = usersBlocks.collectAsMap()
    val itemsBlockMap = itemsBlocks.collectAsMap()

    val sumSquaredDev = ratingsBlocks.map {
      case ((usersBlockId, itemsBlockId), RatingsBlock(users, items, rates)) =>
        val usersBlock = usersBlockMap(usersBlockId)
        val itemsBlock = itemsBlockMap(itemsBlockId)
        rates.zipWithIndex.map {
          case (rate, i) =>
            val userFactor = usersBlock.factors(usersBlock.users(users(i)))
            val itemFactor = itemsBlock.factors(itemsBlock.items(items(i)))
            val pred = dotP(userFactor.length, userFactor, 0, itemFactor, 0)
            Math.pow(pred - rate, 2)
        }.sum
    }.sum()

    val numRatings = ratingsBlocks.map {
      case (_, ratingsBlock) =>
        ratingsBlock.ratings.length
    }.sum()

    Math.sqrt(sumSquaredDev / numRatings)*/

    val numDiagnalRounds = itemsBlocks.count().toInt
    val sumSquaredDevs = 0 until numDiagnalRounds map { round =>
      val ratingsBlocksInRound = ratingsBlocks.filter {
        case ((usersBlockId, itemsBlockId), _) => (usersBlockId + round) % numDiagnalRounds == itemsBlockId
      }
      val uirBlocksInRound = usersBlocks.join(
        itemsBlocks.keyBy { case (itemsBlockId, _) =>
          (itemsBlockId + round * (numDiagnalRounds - 1)) % numDiagnalRounds
        }
      ).map { // todo: keyBy, join and then mapValues?
        case (usersBlockId, (usersBlock, (itemsBlockId, itemsBlock))) =>
          // changing schema for the join with rating blocks to filter
          ((usersBlockId, itemsBlockId), (usersBlock, itemsBlock))
      }.join(ratingsBlocksInRound)
      //println(s"[sam] uirBlocksInRound count: ${uirBlocksInRound.count()}")

      uirBlocksInRound.mapValues {
        case ((usersBlock, itemsBlock), RatingsBlock(users, items, rates)) =>
          // Within one ratingsBlock, have to be sequential because of
          // multiple write-read dependencies for each uesr and item factor
          var i = 0
          var sumSquaredDev = 0.0
          while (i < rates.length) {
            val userFactor = usersBlock.factors(usersBlock.users(users(i)))
            val itemFactor = itemsBlock.factors(itemsBlock.items(items(i)))
            val pred = algebran.dotP(userFactor.length, userFactor, 0, itemFactor, 0)
            sumSquaredDev += Math.pow(pred - rates(i), 2)
            i += 1
          }
          /*rates.zipWithIndex.foreach {
            case (rate, i) =>
              val userFactor = usersBlock.factors(usersIndex(i))
              val itemFactor = itemsBlock.factors(itemsIndex(i))
              val pred = dotP(num_latent, userFactor, 0, itemFactor, 0)
              val err = pred - rate
              (0 until num_latent).foreach { j =>
                userFactor(j) += - gamma * (err * itemFactor(j) + LAMBDA * userFactor(j))
                itemFactor(j) += - gamma * (err * userFactor(j) + LAMBDA * itemFactor(j))
              }
          }*/
        sumSquaredDev
      }.values.sum()
    }
    val numRatings = ratingsBlocks.mapValues(_.ratings.length).values.sum()
    Math.sqrt(sumSquaredDevs.sum / numRatings)
  }

  type UserId = Int
  type ItemId = Int
  type UsersBlockId = Int
  type ItemsBlockId = Int

  case class Rating(user: UserId, item: ItemId, rating: Double) extends Serializable
  case class RatingsBlock(users: Array[UserId], items: Array[ItemId], ratings: Array[Double]) extends Serializable
  case class UsersBlock(users: Map[UserId, Int], factors: Array[Array[Double]]) extends Serializable
  case class ItemsBlock(items: Map[ItemId, Int], factors: Array[Array[Double]]) extends Serializable

  class RatingsBlockDenormalizedBuilder extends Serializable {
    val users  = mutable.ArrayBuilder.make[UserId]
    val items = mutable.ArrayBuilder.make[ItemId]
    val ratings = mutable.ArrayBuilder.make[Double]

    def add(r: Rating): RatingsBlockDenormalizedBuilder = {
      users += r.user
      items += r.item
      ratings += r.rating
      this
    }

    def merge(b: RatingsBlock): RatingsBlockDenormalizedBuilder = {
      users ++= b.users
      items ++= b.items
      ratings ++= b.ratings
      this
    }

    def build(): RatingsBlock = {
      RatingsBlock(users.result(), items.result(), ratings.result())
    }
  }

  class UsersBlockBuilder(factorLength: Int) extends Serializable {
    val users = mutable.ArrayBuilder.make[UserId]

    def add(us: Array[UserId]): UsersBlockBuilder = {
      users ++= us
      this
    }

    def merge(b: UsersBlock): UsersBlockBuilder = {
      users ++= b.users.keys
      this
    }

    def build(): UsersBlock = {
      val uniqueUsers = users.result().toSet.toSeq.sorted.zipWithIndex.toMap
      val factors = Array.fill(uniqueUsers.size, factorLength)(randGen.nextDouble())
      UsersBlock(uniqueUsers, factors)
    }
  }

  class ItemsBlockBuilder(factorLength: Int) extends Serializable {
    val items = mutable.ArrayBuilder.make[ItemId]

    def add(us: Array[UserId]): ItemsBlockBuilder = {
      items ++= us
      this
    }

    def merge(b: ItemsBlock): ItemsBlockBuilder = {
      items ++= b.items.keys
      this
    }

    def build(): ItemsBlock = {
      val uniqueItems = items.result().toSet.toSeq.sorted.zipWithIndex.toMap
      val factors = Array.fill(uniqueItems.size, factorLength)(randGen.nextDouble())
      ItemsBlock(uniqueItems, factors)
    }
  }
}

