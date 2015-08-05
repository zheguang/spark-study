package edu.brown.cs.sparkstudy

import edu.brown.cs.sparkstudy.CfSgdCommon._
import org.apache.spark.rdd.RDD
import org.apache.spark.storage.StorageLevel
import org.apache.spark.{Logging, SparkConf, SparkContext, HashPartitioner}

import scala.collection.mutable

object SparkSgdNaive extends Logging {

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

  def main(args: Array[String]) = {
    if (args.length < argNames.length) {
      printUsage("SparkSgd")
      System.exit(123)
    }
    val sc = new SparkContext(new SparkConf().setAppName("ScalaSgdNaive"))

    val num_latent = args(0).toInt
    val filePath = args(1)
    val num_users = args(2).toInt // fixme: never used
    val num_items = args(3).toInt // fixme: never used
    val num_ratings = args(4).toInt // fixme: never used
    val num_procs = args(5).toInt
    val num_nodes = 1

    val data = sc.textFile(s"file://$filePath")
    val ratings = data.map(_.split(" ") match {
      case Array(user, item, rate) =>
        Rating(user.toInt, item.toInt, rate.toDouble)
    }).setName("ratings")

    val numUserBlocks = num_nodes * num_procs
    val numItemBlocks = num_nodes * num_procs

    val userPart = new HashPartitioner(numUserBlocks)
    val itemPart = new HashPartitioner(numItemBlocks)

    val ratingsBlocks = partitionRatings(ratings, userPart, itemPart)
    var (usersBlocks, itemsBlocks) = makeFactorsBlocks(userPart, itemPart, ratingsBlocks, num_latent)
    // materialize
    usersBlocks.count()
    itemsBlocks.count()
    //logInfo(s"[sam] init: usersBlocks size: ${usersBlocks.count()}, itemsBlocks size: ${itemsBlocks.count()}")

    val maxNumIters = 1
    val numDiagnalRounds = itemsBlocks.count().toInt

    // XXX
    var gamma = 0.001
    for (iter <- 0 until maxNumIters) {
      for (round <- 0 until numDiagnalRounds) {
        val ratingsBlocksInRound = ratingsBlocks.filter {
          case ((usersBlockId, itemsBlockId), _) => (usersBlockId + round) % numDiagnalRounds == itemsBlockId
        }

        // fixme: look up factors blocks by ratingsBlocksInRound?
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
                // todo: improve O(n) to O(1) lookup
                val userId = ratingsBlock.users(i)
                val itemId = ratingsBlock.items(i)
                val userFactorIndex = usersBlock.users.indexOf(userId)
                val itemFactorIndex = itemsBlock.items.indexOf(itemId)
                val userFactor = usersBlock.factors(userFactorIndex)
                val itemFactor = itemsBlock.factors(itemFactorIndex)
                val pred = dotP(num_latent, userFactor, 0, itemFactor, 0)
                val err = pred - rate
                (0 until num_latent).foreach { i =>
                  userFactor(i) += - gamma * (err * itemFactor(i) + LAMBDA * userFactor(i))
                  itemFactor(i) += - gamma * (err * userFactor(i) + LAMBDA * itemFactor(i))
                }
            }
            (usersBlock, itemsBlock)
        }.persist(StorageLevel.MEMORY_AND_DISK)

        // update usersBlocks and itemsBlocks with counterparts in uriBlocks
        // fixme: use look up filter and then merge to update usersBlocks and itemsBlocks?
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
        //logInfo(s"[sam] at i$iter: usersBlocks size: ${usersBlocks.count()}, itemsBlocks size: ${itemsBlocks.count()}")
      }

      // XXX

      /*for (iter <- 0 until maxNumIters) {
        var gamma = 0.001
        for (round <- 0 until numDiagnalRounds) {
          //val diagnalRoundBlocks = (0 until numDiagnalRounds).zip(0 until numDiagnalRounds map(x => (x + round) % numDiagnalRounds))
          val ratingsBlocksInRound = ratingsBlocks.filter {
            case ((usersBlockId, itemsBlockId), _) =>
              (usersBlockId + round) % numDiagnalRounds == itemsBlockId
          }

          // Filter in the users/items/ratings that participate in this round
          val uirBlocksInRound = usersBlocks.join(
            itemsBlocks.map {
              case (itemsBlockId, itemsBlock) =>
                ((itemsBlockId + round) % numDiagnalRounds, (itemsBlockId, itemsBlock))
            }, userPart
          ).map {
            case (usersBlockId, (usersBlock, (itemsBlockId, itemsBlock))) =>
              // changing schema for the join with rating blocks to filter
              ((usersBlockId, itemsBlockId), (usersBlock, itemsBlock))
          }.join(ratingsBlocksInRound, userPart)

          // update user and item factors using SGD
          val uirBlocksInRoundUpdated = uirBlocksInRound.map {
            case ((usersBlockId, itemsBlockId), ((usersBlock, itemsBlock), ratingsBlock)) =>
              // Within one ratingsBlock, have to be sequential because of
              // multiple write-read dependencies for each uesr and item factor
              ratingsBlock.ratings.zipWithIndex.foreach {
                case (rate, i) =>
                  // todo: improve O(n) to O(1) lookup
                  val userId = ratingsBlock.users(i)
                  val itemId = ratingsBlock.items(i)
                  val userFactorIndex = usersBlock.users.indexOf(userId)
                  val itemFactorIndex = itemsBlock.items.indexOf(itemId)
                  val userFactor = usersBlock.factors(userFactorIndex)
                  val itemFactor = itemsBlock.factors(itemFactorIndex)
                  val pred = dotP(num_latent, userFactor, 0, itemFactor, 0)
                  val err = pred - rate
                  (0 until num_latent).foreach { i =>
                    userFactor(i) += - gamma * (err * itemFactor(i) + LAMBDA * userFactor(i))
                    itemFactor(i) += - gamma * (err * userFactor(i) + LAMBDA * itemFactor(i))
                  }
              }
              ((usersBlockId, itemsBlockId), ((usersBlock, itemsBlock), ratingsBlock))
          }

          // update usersBlocks and itemsBlocks with counterparts in uriBlocks
          val previousUsersBlocks = usersBlocks
          usersBlocks = uirBlocksInRoundUpdated.map {
            case ((usersBlockId, _), ((usersBlock, _), _)) => (usersBlockId, usersBlock)
          }.join(usersBlocks, userPart).map {
            case ((usersBlockId, (usersBlockUpdated, usersBlock))) => (usersBlockId, usersBlockUpdated)
          }.persist()
          previousUsersBlocks.unpersist()

          val previousItemsBlocks = itemsBlocks
          itemsBlocks = uirBlocksInRoundUpdated.map {
            case ((_, itemsBlockId), ((_, itemsBlock), _)) => (itemsBlockId, itemsBlock)
          }.join(itemsBlocks, itemPart).map {
            case ((itemsBlockId, (itemsBlockUpdated, itemsBlock))) => (itemsBlockId, itemsBlockUpdated)
          }.persist()
          previousItemsBlocks.unpersist()

          // onward next round!
        }
        gamma *= STEP_DEC
      }*/
      gamma *= STEP_DEC
      /*val trainErr = computeTrainingError(usersBlocks, itemsBlocks, ratingsBlocks)
      logInfo(s"sam, training rmse $trainErr")*/
    }

    logInfo(s"[sam] finished training for total iterations: $maxNumIters")

    logInfo(s"[sam] usersBlocks size: ${usersBlocks.count()}, itemsBlocks size: ${itemsBlocks.count()}")
    logInfo(s"[sam] usersBlocks parts: ${usersBlocks.partitions.length}, itemsBlocks parts: ${itemsBlocks.partitions.length}")

  }

  def makeFactorsBlocks(userPart: HashPartitioner, itemPart: HashPartitioner, ratingsBlocks: RDD[((UsersBlockId, ItemsBlockId), RatingsBlock)], num_latent: Int): (RDD[(UsersBlockId, UsersBlock)], RDD[(ItemsBlockId, ItemsBlock)]) = {
    val usersBlocks = ratingsBlocks.map {
      case ((usersBlockId, _), RatingsBlock(users_, _, _)) =>
        val users: Array[UsersBlockId] = users_.toSet.toSeq.sorted.toArray
        (usersBlockId, UsersBlock(users, Array.fill(users.length, num_latent)(randGen.nextDouble())))
    }.partitionBy(new HashPartitioner(userPart.numPartitions))
      .setName("usersBlock")
      .persist(StorageLevel.MEMORY_AND_DISK)

    val itemsBlocks = ratingsBlocks.map {
      case ((_, itemsBlockId), RatingsBlock(_, items_, _)) =>
        val items = items_.toSet.toSeq.sorted.toArray
        (itemsBlockId, ItemsBlock(items, Array.fill(items.length, num_latent)(randGen.nextDouble())))
    }.partitionBy(new HashPartitioner(itemPart.numPartitions))
      .setName("itemsBlock")
      .persist(StorageLevel.MEMORY_AND_DISK)

    (usersBlocks, itemsBlocks)
  }

  def partitionRatings(ratings: RDD[Rating], userPart: HashPartitioner, itemPart: HashPartitioner): RDD[((UsersBlockId, ItemsBlockId), RatingsBlock)] = {
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
            // TODO: improve O(n) to O(1) lookup
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

}
