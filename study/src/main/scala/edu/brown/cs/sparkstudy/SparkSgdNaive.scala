package edu.brown.cs.sparkstudy

import edu.brown.cs.sparkstudy.CfSgdCommon._
import org.apache.spark.rdd.RDD
import org.apache.spark.storage.StorageLevel
import org.apache.spark.{Logging, SparkConf, SparkContext, HashPartitioner}

import scala.collection.mutable

object SparkSgdNaive extends Logging {
/*
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

    val userPart = new HashPartitioner(numUserBlocks)
    val itemPart = new HashPartitioner(numItemBlocks)

    val ratingsBlocksDenormalized = partitionRatings(ratings, userPart, itemPart)
    var (usersBlocks, itemsBlocks) = makeFactorsBlocks(userPart, itemPart, ratingsBlocksDenormalized, num_latent)
    // materialize
    usersBlocks.count()
    itemsBlocks.count()
    //ratingsBlocksNormalized.count()
    //ratingsBlocksDenormalized.unpersist()

    val ratingsBlocks = ratingsBlocksDenormalized
    //println(s"[sam] init: ratingsblocks count: ${ratingsBlocks.count()}, usersBlocks count: ${usersBlocks.count()}, itemsBlocks count: ${itemsBlocks.count()}")
    //println(s"[sam] init: numUsers: ${usersBlocks.mapValues(_.users.length).values.sum()}, numItems: ${itemsBlocks.mapValues(_.items.length).values.sum()}")

    val maxNumIters = 5
    val numDiagnalRounds = itemsBlocks.count().toInt

    var gamma = 0.001
    for (iter <- 0 until maxNumIters) {
      val iterStart = System.currentTimeMillis()
      for (round <- 0 until numDiagnalRounds) {
        val ratingsBlocksInRound = ratingsBlocks.filter {
          case ((usersBlockId, itemsBlockId), _) => (usersBlockId + round) % numDiagnalRounds == itemsBlockId
        }
        //println(s"[sam] ratingsBlocksInRound count: ${ratingsBlocksInRound.count()}")

        val uirBlocksInRound = usersBlocks.join(
          itemsBlocks.keyBy { case (itemsBlockId, _) =>
            //(itemsBlockId + round) % numDiagnalRounds
            (itemsBlockId + round * (numDiagnalRounds - 1)) % numDiagnalRounds
          }
        ).map {
          case (usersBlockId, (usersBlock, (itemsBlockId, itemsBlock))) =>
            // changing schema for the join with rating blocks to filter
            ((usersBlockId, itemsBlockId), (usersBlock, itemsBlock))
        }.join(ratingsBlocksInRound)
        //println(s"[sam] uirBlocksInRound count: ${uirBlocksInRound.count()}")

        val uirBlocksInRoundUpdated = uirBlocksInRound.mapValues {
          case ((usersBlock, itemsBlock), RatingsBlockDenormalized(users, items, rates)) =>
            // Within one ratingsBlock, have to be sequential because of
            // multiple write-read dependencies for each uesr and item factor
            val start = System.currentTimeMillis()
            println(s"[sam][debug] start to sort: users size: ${users.length}, items size: ${items.length}")
            val uniqueUsers = users.toSet.toSeq.sorted
            val uniqueItems = items.toSet.toSeq.sorted
            println(s"[sam][debug] end sort, start zip: uniqueUsers size: ${uniqueUsers.length}, uniqueItems size: ${uniqueItems.length}, time: ${System.currentTimeMillis() - start}")
            rates.zipWithIndex.foreach {
              case (rate, i) =>
                val userFactor = usersBlock.factors(uniqueUsers.indexOf(users(i)))
                val itemFactor = itemsBlock.factors(uniqueItems.indexOf(items(i)))
                val pred = dotP(num_latent, userFactor, 0, itemFactor, 0)
                val err = pred - rate
                (0 until num_latent).foreach { j =>
                  userFactor(j) += - gamma * (err * itemFactor(j) + LAMBDA * userFactor(j))
                  itemFactor(j) += - gamma * (err * userFactor(j) + LAMBDA * itemFactor(j))
                }
            }
            println(s"[sam] done building one normalized rating block")
            (usersBlock, itemsBlock)
        }.persist(StorageLevel.MEMORY_ONLY)
        //println(s"[sam] uirBlocksInRoundUpdated count: ${uirBlocksInRoundUpdated.count()}")

        // update usersBlocks and itemsBlocks with counterparts in uriBlocks
        val previousUsersBlocks = usersBlocks
        /*usersBlocks = uirBlocksInRoundUpdated.map {
          case ((usersBlockId, _), (usersBlock, _)) => (usersBlockId, usersBlock)
        }.rightOuterJoin(usersBlocks).mapValues {
          case ((Some(usersBlockUpdated), _)) => usersBlockUpdated
          case (None, usersBlock) => usersBlock
        }*/
        usersBlocks = uirBlocksInRoundUpdated.map {
          case ((usersBlockId, _), (usersBlock, _)) => (usersBlockId, usersBlock)
        }.partitionBy(new HashPartitioner(userPart.numPartitions))
        previousUsersBlocks.unpersist()
        usersBlocks.setName(s"usersBlocks(i$iter)(r$round)").persist(StorageLevel.MEMORY_ONLY)

        val previousItemsBlocks = itemsBlocks
        /*itemsBlocks = uirBlocksInRoundUpdated.map {
          case ((_, itemsBlockId), (_, itemsBlock)) => (itemsBlockId, itemsBlock)
        }.rightOuterJoin(itemsBlocks).mapValues {
          case ((Some(itemsBlockUpdated), _)) => itemsBlockUpdated
          case (None, itemsBlock) => itemsBlock
        }*/
        itemsBlocks = uirBlocksInRoundUpdated.map {
          case ((_, itemsBlockId), (_, itemsBlock)) => (itemsBlockId, itemsBlock)
        }.partitionBy(new HashPartitioner(itemPart.numPartitions))
        previousItemsBlocks.unpersist()
        itemsBlocks.setName(s"itemsBlocks(i$iter(r$round)").persist(StorageLevel.MEMORY_ONLY)

        // materialize
        usersBlocks.count()
        itemsBlocks.count()
        //println(s"[sam] usersBlocks count: ${usersBlocks.count()}, itemsBlocks coutn: ${itemsBlocks.count()}")
      }
      gamma *= STEP_DEC
      val iterEnd = System.currentTimeMillis()
      println(s"[sam] Time in iteration $iter of sgd ${iterEnd - iterStart} (ms)")
    }

    //println(s"[sam] usersBlocks size: ${usersBlocks.count()}, itemsBlocks size: ${itemsBlocks.count()}")
    //println(s"[sam] usersBlocks parts: ${usersBlocks.partitions.length}, itemsBlocks parts: ${itemsBlocks.partitions.length}")
    val trainErr = computeTrainingError(usersBlocks, itemsBlocks, ratingsBlocks)
    println(s"[sam] training rmse $trainErr")
    println(s"[sam] finished training for total iterations: $maxNumIters")
  }

  private def makeFactorsBlocks(userPart: HashPartitioner, itemPart: HashPartitioner, ratingsBlocks: RDD[((UsersBlockId, ItemsBlockId), RatingsBlockDenormalized)], num_latent: Int): (RDD[(UsersBlockId, UsersBlock)], RDD[(ItemsBlockId, ItemsBlock)]) = {
    // aggregate by user-block ids to create user blocks, each with unique user
    // ids that are shared across different item blocks
    val usersBlocks = ratingsBlocks.map {
      case ((usersBlockId, _), RatingsBlockDenormalized(users, _, _)) => (usersBlockId, users)
    }.aggregateByKey(new UsersBlockBuilder(num_latent), new HashPartitioner(userPart.numPartitions))(
        seqOp = (b, us) => b.add(us),
        combOp = (b1, b2) => b1.merge(b2.build()))
      .mapValues(_.build())
      .setName("usersBlocks")
      .persist(StorageLevel.MEMORY_ONLY)

    // aggregate by item-block ids to create item blocks, each with unique
    // item ids that are shared acrosss different user blocks
    val itemsBlocks = ratingsBlocks.map {
      case ((_, itemsBlockId), RatingsBlockDenormalized(_, items, _)) => (itemsBlockId, items)
    }.aggregateByKey(new ItemsBlockBuilder(num_latent), new HashPartitioner(itemPart.numPartitions))(
        seqOp = (b, is) => b.add(is),
        combOp = (b1, b2) => b1.merge(b2.build()))
      .mapValues(_.build())
      .setName("itemsBlocks")
      .persist(StorageLevel.MEMORY_ONLY)

    (usersBlocks, itemsBlocks)
  }

  private def partitionRatings(ratings: RDD[Rating], userPart: HashPartitioner, itemPart: HashPartitioner): RDD[((UsersBlockId, ItemsBlockId), RatingsBlockDenormalized)] = {
    val denormalized = ratings.map { r =>
      ((userPart.getPartition(r.user), itemPart.getPartition(r.item)), r)
    }.aggregateByKey(new RatingsBlockDenormalizedBuilder)(
        seqOp = (b, r) => b.add(r),
        combOp = (b1, b2) => b1.merge(b2.build()))
      .mapValues(_.build())
      .setName("ratingsBlockDenormalized")
      .persist(StorageLevel.MEMORY_ONLY)

    /*val normalized = denormalized.mapValues { case RatingsBlock(us, is, rs) =>
      val start = System.currentTimeMillis()
      println(s"[sam][debug] start to sort: users size: ${us.length}, items size: ${is.length}")
      val uniqueUsers = us.toSet.toSeq.sorted.toArray
      val uniqueItems = is.toSet.toSeq.sorted.toArray
      println(s"[sam][debug] end sort, start zip: uniqueUsers size: ${uniqueUsers.length}, uniqueItems size: ${uniqueItems.length}, time: ${System.currentTimeMillis() - start}")
      val usersIndex = mutable.ArrayBuilder.make[Int]
      val itemsIndex = mutable.ArrayBuilder.make[Int]
      rs.zipWithIndex.foreach { case (_, i) =>
        val userId = us(i)
        val itemId = is(i)
        val userIdIndex = uniqueUsers.indexOf(userId)
        val itemIdIndex = uniqueItems.indexOf(itemId)
        assert(userIdIndex >= 0)
        assert(itemIdIndex >= 0)
        usersIndex += userIdIndex
        itemsIndex += itemIdIndex
      }
      println(s"[sam] done building one normalized rating block")
      RatingsBlockNormalized(rs, usersIndex.result(), itemsIndex.result())
    }
      .setName("ratingsBlocksNormalized")
      .persist(StorageLevel.MEMORY_ONLY)
    println("[sam][debug] done making normalized block")

    (denormalized, normalized)*/
    denormalized
  }

  private def computeTrainingError(usersBlocks: RDD[(UsersBlockId, UsersBlock)], itemsBlocks: RDD[(ItemsBlockId, ItemsBlock)], ratingsBlocks: RDD[((UsersBlockId, ItemsBlockId), RatingsBlockDenormalized)]): Double = {
    val usersBlockMap = usersBlocks.collectAsMap()
    val itemsBlockMap = itemsBlocks.collectAsMap()

    val sumSquaredDev = ratingsBlocks.map {
      case ((usersBlockId, itemsBlockId), RatingsBlockDenormalized(users, items, rates)) =>
        val usersBlock = usersBlockMap(usersBlockId)
        val itemsBlock = itemsBlockMap(itemsBlockId)
        val uniqueUsers = users.toSet.toSeq.sorted
        val uniqueItems = items.toSet.toSeq.sorted
        rates.zipWithIndex.map {
          case (rate, i) =>
            val userFactor = usersBlock.factors(uniqueUsers.indexOf(users(i)))
            val itemFactor = itemsBlock.factors(uniqueItems.indexOf(items(i)))
            val pred = dotP(userFactor.length, userFactor, 0, itemFactor, 0)
            Math.pow(pred - rate, 2)
        }.sum
    }.sum()

    val numRatings = ratingsBlocks.map {
      case (_, ratingsBlock) =>
        ratingsBlock.ratings.length
    }.sum()

    Math.sqrt(sumSquaredDev / numRatings)
  }

  type UserId = Int
  type ItemId = Int
  type UsersBlockId = Int
  type ItemsBlockId = Int

  case class Rating(user: UserId, item: ItemId, rating: Double) extends Serializable
  case class RatingsBlockDenormalized(users: Array[UserId], items: Array[ItemId], ratings: Array[Double]) extends Serializable
  //case class RatingsBlockNormalized(ratings: Array[Double], usersIndex: Array[Int], itemsIndex: Array[Int]) extends Serializable
  case class UsersBlock(users: Array[UserId], factors: Array[Array[Double]]) extends Serializable
  case class ItemsBlock(items: Array[ItemId], factors: Array[Array[Double]]) extends Serializable

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

    def merge(b: RatingsBlockDenormalized): RatingsBlockDenormalizedBuilder = {
      users ++= b.users
      items ++= b.items
      ratings ++= b.ratings
      this
    }

    def build(): RatingsBlockDenormalized = {
      RatingsBlockDenormalized(users.result(), items.result(), ratings.result())
    }
  }

  class UsersBlockBuilder(factorLength: Int) extends Serializable {
    val users = mutable.ArrayBuilder.make[UserId]

    def add(us: Array[UserId]): UsersBlockBuilder = {
      users ++= us
      this
    }

    def merge(b: UsersBlock): UsersBlockBuilder = {
      users ++= b.users
      this
    }

    def build(): UsersBlock = {
      val uniqueUsers = users.result().toSet.toSeq.sorted.toArray
      val factors = Array.fill(uniqueUsers.length, factorLength)(randGen.nextDouble())
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
      items ++= b.items
      this
    }

    def build(): ItemsBlock = {
      val uniqueItems = items.result().toSet.toSeq.sorted.toArray
      val factors = Array.fill(uniqueItems.length, factorLength)(randGen.nextDouble())
      ItemsBlock(uniqueItems, factors)
    }
  }*/
}
/*package edu.brown.cs.sparkstudy

import edu.brown.cs.sparkstudy.CfSgdCommon._
import org.apache.spark.rdd.RDD
import org.apache.spark.storage.StorageLevel
import org.apache.spark.{Logging, SparkConf, SparkContext, HashPartitioner}

import scala.collection.mutable

object SparkSgdNaive extends Logging {

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

    val userPart = new HashPartitioner(numUserBlocks)
    val itemPart = new HashPartitioner(numItemBlocks)

    val ratingsBlocks = partitionRatings(ratings, userPart, itemPart)
    var (usersBlocks, itemsBlocks) = makeFactorsBlocks(userPart, itemPart, ratingsBlocks, num_latent)
    // materialize
    usersBlocks.count()
    itemsBlocks.count()

    println(s"[sam] init: ratingsblocks count: ${ratingsBlocks.count()}, usersBlocks count: ${usersBlocks.count()}, itemsBlocks count: ${itemsBlocks.count()}")
    println(s"[sam] init: numUsers: ${usersBlocks.mapValues(_.users.length).values.sum()}, numItems: ${itemsBlocks.mapValues(_.items.length).values.sum()}")

    val maxNumIters = 5
    val numDiagnalRounds = itemsBlocks.count().toInt

    var gamma = 0.001
    for (iter <- 0 until maxNumIters) {
      val iterStart = System.currentTimeMillis()
      for (round <- 0 until numDiagnalRounds) {
        val ratingsBlocksInRound = ratingsBlocks.filter {
          case ((usersBlockId, itemsBlockId), _) => (usersBlockId + round) % numDiagnalRounds == itemsBlockId
        }

        val uirBlocksInRound = usersBlocks.join(
          itemsBlocks.map {
            case (itemsBlockId, itemsBlock) =>
              ((itemsBlockId + round) % numDiagnalRounds, (itemsBlockId, itemsBlock))
          }
        ).map {
          case (usersBlockId, (usersBlock, (itemsBlockId, itemsBlock))) =>
            // changing schema for the join with rating blocks to filter
            ((usersBlockId, itemsBlockId), (usersBlock, itemsBlock))
        }.join(ratingsBlocksInRound)

        val uirBlocksInRoundUpdated = uirBlocksInRound.mapValues {
          case ((usersBlock, itemsBlock), ratingsBlock) =>
            // Within one ratingsBlock, have to be sequential because of
            // multiple write-read dependencies for each uesr and item factor
            ratingsBlock.ratings.zipWithIndex.foreach {
              case (rate, i) =>
                // todo: improve O(log n) to O(1) reverse lookup factors
                val userId = ratingsBlock.users(i)
                val itemId = ratingsBlock.items(i)
                val userFactorIndex = usersBlock.users.indexOf(userId)
                val itemFactorIndex = itemsBlock.items.indexOf(itemId)
                val userFactor = usersBlock.factors(userFactorIndex)
                val itemFactor = itemsBlock.factors(itemFactorIndex)
                val pred = dotP(num_latent, userFactor, 0, itemFactor, 0)
                val err = pred - rate
                (0 until num_latent).foreach { j =>
                  userFactor(j) += - gamma * (err * itemFactor(j) + LAMBDA * userFactor(j))
                  itemFactor(j) += - gamma * (err * userFactor(j) + LAMBDA * itemFactor(j))
                }
            }
            (usersBlock, itemsBlock)
        }.persist(StorageLevel.MEMORY_AND_DISK)

        // update usersBlocks and itemsBlocks with counterparts in uriBlocks
        val previousUsersBlocks = usersBlocks
        usersBlocks = uirBlocksInRoundUpdated.map {
          case ((usersBlockId, _), (usersBlock, _)) => (usersBlockId, usersBlock)
        }.rightOuterJoin(usersBlocks).mapValues {
          case ((Some(usersBlockUpdated), _)) => usersBlockUpdated
          case (None, usersBlock) => usersBlock
        }
        previousUsersBlocks.unpersist()
        usersBlocks.setName(s"usersBlocks(i$iter)(r$round)").persist(StorageLevel.MEMORY_AND_DISK)

        val previousItemsBlocks = itemsBlocks
        itemsBlocks = uirBlocksInRoundUpdated.map {
          case ((_, itemsBlockId), (_, itemsBlock)) => (itemsBlockId, itemsBlock)
        }.rightOuterJoin(itemsBlocks).mapValues {
          case ((Some(itemsBlockUpdated), _)) => itemsBlockUpdated
          case (None, itemsBlock) => itemsBlock
        }
        previousItemsBlocks.unpersist()
        itemsBlocks.setName(s"itemsBlocks(i$iter(r$round)").persist(StorageLevel.MEMORY_AND_DISK)

        // materialize
        usersBlocks.count()
        itemsBlocks.count()
      }
      gamma *= STEP_DEC
      val iterEnd = System.currentTimeMillis()
      println(s"[sam] Time in iteration $iter of sgd ${iterEnd - iterStart} (ms)")
    }

    logInfo(s"[sam] usersBlocks size: ${usersBlocks.count()}, itemsBlocks size: ${itemsBlocks.count()}")
    logInfo(s"[sam] usersBlocks parts: ${usersBlocks.partitions.length}, itemsBlocks parts: ${itemsBlocks.partitions.length}")
    println(s"[sam] finished training for total iterations: $maxNumIters")
    val trainErr = computeTrainingError(usersBlocks, itemsBlocks, ratingsBlocks)
    println(s"[sam] training rmse $trainErr")
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
      .persist(StorageLevel.MEMORY_AND_DISK)

    // aggregate by item-block ids to create item blocks, each with unique
    // item ids that are shared acrosss different user blocks
    val itemsBlocks = ratingsBlocks.map {
      case ((_, itemsBlockId), RatingsBlock(_, items, _)) => (itemsBlockId, items)
    }.aggregateByKey(new ItemsBlockBuilder(num_latent), new HashPartitioner(itemPart.numPartitions))(
        seqOp = (b, is) => b.add(is),
        combOp = (b1, b2) => b1.merge(b2.build()))
      .mapValues(_.build())
      .setName("itemsBlocks")
      .persist(StorageLevel.MEMORY_AND_DISK)

    (usersBlocks, itemsBlocks)
  }

  private def partitionRatings(ratings: RDD[Rating], userPart: HashPartitioner, itemPart: HashPartitioner): RDD[((UsersBlockId, ItemsBlockId), RatingsBlock)] = {
    ratings.map { r =>
      ((userPart.getPartition(r.user), itemPart.getPartition(r.item)), r)
    }.aggregateByKey(new RatingsBlockBuilder)(
        seqOp = (b, r) => b.add(r),
        combOp = (b1, b2) => b1.merge(b2.build()))
      .mapValues(_.build())
      .setName("ratingsBlock")
      .persist(StorageLevel.MEMORY_AND_DISK)
  }

  private def computeTrainingError(usersBlocks: RDD[(UsersBlockId, UsersBlock)], itemsBlocks: RDD[(ItemsBlockId, ItemsBlock)], ratingsBlocks: RDD[((UsersBlockId, ItemsBlockId), RatingsBlock)]): Double = {
    val usersBlockMap = usersBlocks.collectAsMap()
    val itemsBlockMap = itemsBlocks.collectAsMap()

    val sumSquaredDev = ratingsBlocks.map {
      case ((usersBlockId, itemsBlockId), ratingsBlock) =>
        val usersBlock = usersBlockMap(usersBlockId)
        val itemsBlock = itemsBlockMap(itemsBlockId)
        ratingsBlock.ratings.zipWithIndex.map {
          case (rate, i) =>
            // todo: improve O(n) to O(1) lookup
            val userId = ratingsBlock.users(i)
            val itemId = ratingsBlock.items(i)
            val userFactorIndex = usersBlock.users.indexOf(userId)
            val itemFactorIndex = itemsBlock.items.indexOf(itemId)
            val userFactor = usersBlock.factors(userFactorIndex)
            val itemFactor = itemsBlock.factors(itemFactorIndex)
            val pred = dotP(userFactor.length, userFactor, 0, itemFactor, 0)
            Math.pow(pred - rate, 2)
        }.sum
    }.sum()

    val numRatings = ratingsBlocks.map {
      case (_, ratingsBlock) =>
        ratingsBlock.ratings.length
    }.sum()

    Math.sqrt(sumSquaredDev / numRatings)
  }

  type UserId = Int
  type ItemId = Int
  type UsersBlockId = Int
  type ItemsBlockId = Int

  case class Rating(user: UserId, item: ItemId, rating: Double) extends Serializable
  case class RatingsBlock(users: Array[UserId], items: Array[ItemId], ratings: Array[Double]) extends Serializable
  case class UsersBlock(users: Array[UserId], factors: Array[Array[Double]]) extends Serializable
  case class ItemsBlock(items: Array[ItemId], factors: Array[Array[Double]]) extends Serializable

  class RatingsBlockBuilder extends Serializable {
    val users  = mutable.ArrayBuilder.make[UserId]
    val items = mutable.ArrayBuilder.make[ItemId]
    val ratings = mutable.ArrayBuilder.make[Double]

    def add(r: Rating): RatingsBlockBuilder = {
      users += r.user
      items += r.item
      ratings += r.rating
      this
    }

    def merge(b: RatingsBlock): RatingsBlockBuilder = {
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
      users ++= b.users
      this
    }

    def build(): UsersBlock = {
      val uniqueUsers = users.result().toSet.toSeq.sorted.toArray
      val factors = Array.fill(uniqueUsers.length, factorLength)(randGen.nextDouble())
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
      items ++= b.items
      this
    }

    def build(): ItemsBlock = {
      val uniqueItems = items.result().toSet.toSeq.sorted.toArray
      val factors = Array.fill(uniqueItems.length, factorLength)(randGen.nextDouble())
      ItemsBlock(uniqueItems, factors)
    }
  }
}*/
