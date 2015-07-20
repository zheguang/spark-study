package edu.brown.cs.sparkstudy

import org.apache.spark.{Logging, SparkContext, SparkConf}

object RddPageRank extends Logging {

  def main(args: Array[String]): Unit = {
    if (args.length < 2) {
      System.err.println("Usage: RddPageRank <file> <num_iters>")
      System.exit(1)
    }

    val fname = args(0)
    val iters = args(1).toInt
    val sparkConf = new SparkConf().setAppName("RddPageRank(" + fname + ")")
    val ctx = new SparkContext(sparkConf)
    val lines = ctx.textFile(fname, 1)
    val links = lines.map{ s =>
      val parts = s.split("\\s+")
      (parts(0), parts(1))
    }.distinct().groupByKey().cache()
    var ranks = links.mapValues(v => 1.0)

    for (i <- 1 to iters) {
      val contribs = links.join(ranks).values.flatMap{ case (urls, rank) =>
        val size = urls.size
        urls.map(url => (url, rank / size))
      }
      ranks = contribs.reduceByKey(_ + _).mapValues(0.15 + 0.85 * _)
    }

    val output = ranks.collect()
    output.foreach(tup => println(tup._1 + " has rank: " + tup._2 + "."))

    ctx.stop()
  }
}
