package edu.brown.cs.sparkstudy

import edu.brown.cs.sparkstudy.CfSgdCommon._
import org.apache.spark.{Logging, SparkContext, SparkConf}
import org.apache.spark.mllib.recommendation.ALS
import org.apache.spark.mllib.recommendation.Rating

object MllibSgd extends Logging {

  def main(args: Array[String]) = {
    if (args.length < argNames.length) {
      printUsage("SparkSgd")
      System.exit(123)
    }
    val num_latent = args(0).toInt
    val filePath = args(1)
    val num_users = args(2).toInt // never used, will compute from ratings
    val num_items = args(3).toInt // never used, will compute from ratings
    val num_ratings = args(4).toInt // never used, will compute from ratings
    val num_procs = args(5).toInt
    val num_nodes = 1

    val sc = new SparkContext(new SparkConf())
    // Load and parse the data
    val data = sc.textFile(s"file://$filePath")
    val ratings = data.map(_.split(' ') match { case Array(user, item, rate) =>
      Rating(user.toInt, item.toInt, rate.toDouble)
    })

    // Build the recommendation model using ALS
    val rank = num_latent
    val numIterations = 5
    val parallelism = num_nodes * num_procs

    val start = System.currentTimeMillis()
    val model = ALS.train(ratings, rank, numIterations, LAMBDA, parallelism)
    val end = System.currentTimeMillis()
    println(s"Average training time per iteration: ${(end - start) / numIterations}")

    // Evaluate the model on rating data
    val usersProducts = ratings.map { case Rating(user, product, rate) =>
      (user, product)
    }
    val predictions =
      model.predict(usersProducts).map { case Rating(user, product, rate) =>
        ((user, product), rate)
      }
    val ratesAndPreds = ratings.map { case Rating(user, product, rate) =>
      ((user, product), rate)
    }.join(predictions)
    val MSE = ratesAndPreds.map { case ((user, product), (r1, r2)) =>
      val err = r1 - r2
      err * err
    }.mean()
    println("Mean Squared Error = " + MSE)
  }
}
