package edu.brown.cs.sparkstudy

import edu.brown.cs.sparkstudy.CfSgdCommon._
import org.apache.spark.rdd.RDD
import org.apache.spark.storage.StorageLevel
import org.apache.spark.{SparkConf, SparkContext, HashPartitioner}

import scala.collection.mutable

object SparkSgdNaive {

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
    val sc = new SparkContext(new SparkConf().setAppName("ScalaSgdNaive").setMaster("local[2]"))

    val num_latent = args(0).toInt
    val filename = args(1)
    val num_users = args(2).toInt
    val num_items = args(3).toInt
    val num_ratings = args(4).toInt
    val num_procs = args(5).toInt
    val num_nodes = 1

    val data = sc.textFile(s"file://$filename")
    val ratings = data.map(_.split(" ") match {
      case Array(user, item, rate) =>
        Rating(user.toInt, item.toInt, rate.toDouble)
    }).setName("ratings")

    val numUserBlocks = num_nodes * num_procs
    val numItemBlocks = num_nodes * num_procs

    val userPart = new HashPartitioner(numUserBlocks)
    val itemPart = new HashPartitioner(numItemBlocks)

    val ratingsBlocks = partitionRatings(ratings, userPart, itemPart).persist(StorageLevel.MEMORY_ONLY)
    var usersBlocks = ratingsBlocks.map {
      case ((usersBlockId, _), RatingsBlock(users_, _, _)) =>
        val users: Array[Int] = users_.toSet.toSeq.sorted.toArray
        (usersBlockId, UsersBlock(users, Array.fill(users.length, num_latent)(randGen.nextDouble())))
    }
    var itemsBlocks = ratingsBlocks.map {
      case ((_, itemsBlockId), RatingsBlock(_, items_, _)) =>
        val items = items_.toSet.toSeq.sorted.toArray
        (itemsBlockId, ItemsBlock(items, Array.fill(items.length, num_latent)(randGen.nextDouble())))
    }
    assert(usersBlocks.count == itemsBlocks.count) // XXX

    val maxNumIters = 5
    val numDiagnalRounds = itemsBlocks.count().toInt

    for (iter <- 0 until maxNumIters) {
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
          }
        ).map {
          case (usersBlockId, (usersBlock, (itemsBlockId, itemsBlock))) =>
            // changing schema for the join with rating blocks to filter
            ((usersBlockId, itemsBlockId), (usersBlock, itemsBlock))
        }.join(ratingsBlocksInRound)

        // update user and item factors using SGD
        val uirBlocksInRoundUpdated = uirBlocksInRound.map {
          case ((usersBlockId, itemsBlockId), ((usersBlock, itemsBlock), ratingsBlock)) =>
            // Within one ratingsBlock, have to be sequential because of
            // multiple write-read dependencies for each uesr and item factor
            ratingsBlock.ratings.zipWithIndex.foreach {
              case (rate, i) =>
                val userId = ratingsBlock.users(i)
                val itemId = ratingsBlock.items(i)
                val userFactorIndex = usersBlock.users.indexOf(userId) // TODO: improve O(n) to O(1) lookup
                val itemFactorIndex = itemsBlock.items.indexOf(itemId) // TODO: improve O(n) to O(1) lookup
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
        usersBlocks = uirBlocksInRoundUpdated.map {
          case ((usersBlockId, _), ((usersBlock, _), _)) => (usersBlockId, usersBlock)
        }.join(usersBlocks).map {
          case ((usersBlockId, (usersBlockUpdated, usersBlock))) => (usersBlockId, usersBlockUpdated)
        }

        itemsBlocks = uirBlocksInRoundUpdated.map {
          case ((_, itemsBlockId), ((_, itemsBlock), _)) => (itemsBlockId, itemsBlock)
        }.join(itemsBlocks).map {
          case ((itemsBlockId, (itemsBlockUpdated, itemsBlock))) => (itemsBlockId, itemsBlockUpdated)
        }

        // onward next round!
      }
      gamma *= STEP_DEC
    }

  }

  private def partitionRatings(ratings: RDD[Rating], userPart: HashPartitioner, itemPart: HashPartitioner): RDD[((UsersBlockId, ItemsBlockId), RatingsBlock)] = {
    ratings.map { r =>
      ((userPart.getPartition(r.user), itemPart.getPartition(r.item)), r)
    }.aggregateByKey(new RatingsBlockBuilder)(
        seqOp = (b, r) => b.add(r),
        combOp = (b1, b2) => b1.merge(b2.build()))
      .mapValues(_.build())
      .setName("ratingsBlock")
  }
}
