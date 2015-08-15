package edu.brown.cs.sparkstudy

import edu.brown.cs.sparkstudy.CfSgdCommon._
import org.apache.spark.rdd.RDD
import org.apache.spark.storage.StorageLevel
import org.apache.spark.{Logging, SparkConf, SparkContext, HashPartitioner}
import org.apache.spark.util.{CollectionsUtils, Utils}

import scala.collection.mutable

object SparkSgdIndexed extends Logging {

  def main(args: Array[String]) = {
    if (args.length < argNames.length) {
      printUsage("SparkSgd")
      System.exit(123)
    }
    val sc = new SparkContext(new SparkConf())

    val num_latent = args(0).toInt
    val filePath = args(1)
    val num_users = args(2).toInt // never used, will compute from ratings
    val num_items = args(3).toInt // never used, will compute from ratings
    val num_ratings = args(4).toInt // never used, will compute from ratings
    val num_procs = args(5).toInt
    val num_nodes = 1

    val data = sc.textFile(s"file://$filePath")
    val ratings = data.map(_.split(" ") match {
      case Array(user, item, rate) =>
        Rating(user.toInt, item.toInt, rate.toDouble)
    }).setName("ratings")

    val numUserBlocks = num_nodes * num_procs
    val numItemBlocks = num_nodes * num_procs
    println(s"[sam] init: ratings count: ${ratings.count()}, numUserBlocks: $numUserBlocks, numItemBlocks: $numItemBlocks")

    val start = System.currentTimeMillis()
    val userPart = new HashPartitioner(numUserBlocks)
    val itemPart = new HashPartitioner(numItemBlocks)

    //val (ratingsBlocksDenormalized, ratingsBlocksNormalized) = partitionRatings(ratings, userPart, itemPart)
    val ratingsBlocks = partitionRatings(ratings, userPart, itemPart)
    var (usersBlocks, itemsBlocks) = makeFactorsBlocks(userPart, itemPart, ratingsBlocks, num_latent)
    // Uncommented when getting training per-iteration time without U-I init time
    // materialize
    usersBlocks.count()
    itemsBlocks.count()

    val maxNumIters = 5
    val numDiagnalRounds = numItemBlocks
    val originalUsersBlocks = usersBlocks
    val originalItemsBlocks = itemsBlocks

    var gamma = 0.001
    for (iter <- 0 until maxNumIters) {
      for (round <- 0 until numDiagnalRounds) {
        val ratingsBlocksInRound = ratingsBlocks.filter {
          case ((usersBlockId, itemsBlockId), _) => (usersBlockId + round) % numDiagnalRounds == itemsBlockId
        } // preserves partitioning
        //println(s"[sam] ratingsBlocksInRound count: ${ratingsBlocksInRound.count()}")

        val uirBlocksInRound = usersBlocks.join(
          itemsBlocks.keyBy { case (itemsBlockId, _) =>
              //(itemsBlockId + round) % numDiagnalRounds
            (itemsBlockId + round * (numDiagnalRounds - 1)) % numDiagnalRounds
          }, new HashPartitioner(userPart.numPartitions) //usersBlocks.partitioner.get
        ).map {
          case (usersBlockId, (usersBlock, (itemsBlockId, itemsBlock))) =>
            // changing schema for the join with rating blocks to filter
            ((usersBlockId, itemsBlockId), (usersBlock, itemsBlock))
        }.join(ratingsBlocksInRound, ratingsBlocks.partitioner.get)
        /*).mapPartitions({
          x => x.map {
            case (usersBlockId, (usersBlock, (itemsBlockId, itemsBlock))) =>
             //changing schema for the join with rating blocks to filter
             ((usersBlockId, itemsBlockId), (usersBlock, itemsBlock))
          }
          //case (usersBlockId, (usersBlock, (itemsBlockId, itemsBlock))) =>
            // changing schema for the join with rating blocks to filter
           // ((usersBlockId, itemsBlockId), (usersBlock, itemsBlock))
        }, true).join(ratingsBlocksInRound, ratingsBlocks.partitioner.get)*/
        //println(s"[sam] uirBlocksInRound count: ${uirBlocksInRound.count()}")

        val uirBlocksInRoundUpdated = uirBlocksInRound.mapValues {
          case ((usersBlock, itemsBlock), RatingsBlock(users, items, rates)) =>
            // Within one ratingsBlock, have to be sequential because of
            // multiple write-read dependencies for each uesr and item factor
            var i = 0
            while (i < rates.length) {
              val userFactor = usersBlock.factors(usersBlock.users(users(i)))
              val itemFactor = itemsBlock.factors(itemsBlock.items(items(i)))
              val pred = dotP(num_latent, userFactor, 0, itemFactor, 0)
              val err = pred - rates(i)
              (0 until num_latent).foreach { j =>
                userFactor(j) += - gamma * (err * itemFactor(j) + LAMBDA * userFactor(j))
                itemFactor(j) += - gamma * (err * userFactor(j) + LAMBDA * itemFactor(j))
              }
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
            (usersBlock, itemsBlock)
        }.setName(s"uirBlocks(i$iter)(r$round)")
          .persist(StorageLevel.MEMORY_ONLY)
        //println(s"[sam] uirBlocksInRoundUpdated count: ${uirBlocksInRoundUpdated.count()}")

        // update usersBlocks and itemsBlocks with counterparts in uriBlocks
        //val previousUsersBlocks = usersBlocks
        /*if (iter < maxNumIters - 1) {
          usersBlocks = uirBlocksInRoundUpdated.map {
            case ((usersBlockId, _), (usersBlock, _)) => (usersBlockId, usersBlock)
          }.partitionBy(new HashPartitioner(userPart.numPartitions))
        } else {
          usersBlocks = uirBlocksInRoundUpdated.mapPartitions({
            x => x.map {
              case ((usersBlockId, _), (usersBlock, _)) => (usersBlockId, usersBlock)
            }
          }, true) //.partitionBy(new HashPartitioner(userPart.numPartitions))
        }*/
        usersBlocks = uirBlocksInRoundUpdated.mapPartitions({
          x => x.map {
            case ((usersBlockId, _), (usersBlock, _)) => (usersBlockId, usersBlock)
          }
        }, true) //.partitionBy(new HashPartitioner(userPart.numPartitions))*/
        /*usersBlocks = uirBlocksInRoundUpdated.keyBy {
          case ((usersBlockId, _), _) => usersBlockId
        }.mapValues {
          case (_, (usersBlock, _)) => usersBlock
        }*/
        //previousUsersBlocks.unpersist()
        //usersBlocks.setName(s"usersBlocks(i$iter)(r$round)").persist(StorageLevel.MEMORY_ONLY)

        //val previousItemsBlocks = itemsBlocks
        /*if (iter < maxNumIters - 1) {
          itemsBlocks = uirBlocksInRoundUpdated.map {
            case ((_, itemsBlockId), (_, itemsBlock)) => (itemsBlockId, itemsBlock)
          }.partitionBy(new HashPartitioner(itemPart.numPartitions))
        } else {
          itemsBlocks = uirBlocksInRoundUpdated.mapPartitions({
            x => x.map {
              case ((_, itemsBlockId), (_, itemsBlock)) => (itemsBlockId, itemsBlock)
            }
          }, true) //.partitionBy(new HashPartitioner(itemPart.numPartitions))
        }*/
        itemsBlocks = uirBlocksInRoundUpdated.mapPartitions({
          x => x.map {
            case ((_, itemsBlockId), (_, itemsBlock)) => (itemsBlockId, itemsBlock)
          }
        }, true) //.partitionBy(new HashPartitioner(itemPart.numPartitions))*/
        /*itemsBlocks = uirBlocksInRoundUpdated.keyBy {
          case ((_, itemsBlockId), _) => itemsBlockId
        }.mapValues {
          case (_, (_, itemsBlock)) => itemsBlock
        }*/
        //previousItemsBlocks.unpersist()
        //itemsBlocks.setName(s"itemsBlocks(i$iter(r$round)").persist(StorageLevel.MEMORY_ONLY)

        // materialize
        //usersBlocks.count()
        //itemsBlocks.count()
        //println(s"[sam] usersBlocks count: ${usersBlocks.count()}, itemsBlocks coutn: ${itemsBlocks.count()}")

        // clean up
        uirBlocksInRoundUpdated.unpersist()
      }
      gamma *= STEP_DEC
    }
    originalUsersBlocks.unpersist()
    originalItemsBlocks.unpersist()
    usersBlocks.setName(s"usersBlocks(i$maxNumIters)").persist(StorageLevel.MEMORY_ONLY)
    itemsBlocks.setName(s"itemsBlocks(i$maxNumIters)").persist(StorageLevel.MEMORY_ONLY)
    usersBlocks.count() // make sure work is done and measured
    itemsBlocks.count()
    val end = System.currentTimeMillis()
    println(s"[sam] Time in iterations of sgd ${(end - start) / maxNumIters} (ms)")

    //println(s"[sam] usersBlocks size: ${usersBlocks.count()}, itemsBlocks size: ${itemsBlocks.count()}")
    //println(s"[sam] usersBlocks parts: ${usersBlocks.partitions.length}, itemsBlocks parts: ${itemsBlocks.partitions.length}")
    val trainErr = computeTrainingError(usersBlocks, itemsBlocks, ratingsBlocks)
    println(s"[sam] training rmse $trainErr")
    println(s"[sam] finished training for total iterations: $maxNumIters")
  }

  private def makeFactorsBlocks(userPart: HashPartitioner, itemPart: HashPartitioner, ratingsBlocks: RDD[((UsersBlockId, ItemsBlockId), RatingsBlock)], num_latent: Int): (RDD[(UsersBlockId, UsersBlock)], RDD[(ItemsBlockId, ItemsBlock)]) = {
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
  private def computeTrainingError(usersBlocks: RDD[(UsersBlockId, UsersBlock)], itemsBlocks: RDD[(ItemsBlockId, ItemsBlock)], ratingsBlocks: RDD[((UsersBlockId, ItemsBlockId), RatingsBlock)]): Double = {
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
            val pred = dotP(userFactor.length, userFactor, 0, itemFactor, 0)
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

