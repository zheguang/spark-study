package edu.brown.cs.sparkstudy

import java.lang.management.ManagementFactory

import org.apache.spark.rdd.RDD
import org.apache.spark.{RangePartitioner, HashPartitioner, SparkConf, SparkContext}

import scala.collection.parallel.ForkJoinTaskSupport
import scala.collection.parallel.immutable.ParVector
import scala.concurrent.forkjoin.ForkJoinPool

object SparkExp {

  def main(args: Array[String]) = {
    val sc = new SparkContext(new SparkConf())
    val cols = 4
    val parters = Array(
      new HashPartitioner(3),
      new HashPartitioner(2)
    )
    val u = sc.textFile("file:///devel/spark-study/u.input").map {
      line =>
        val xs = line.split(" ")
        (xs(0), xs.drop(0))
    }
      //.partitionBy(parters(0))
      .setName("u") .cache()
    /*val u = sc.makeRDD(Seq(
      (10, Array.tabulate[Double](cols)(x => x * 2)),
      (11, Array.tabulate[Double](cols)(x => x * 2 + 10)),
      (12, Array.tabulate[Double](cols)(x => x * 2 + 100))
    )) .partitionBy(new HashPartitioner(3))
    .setName("u").cache()*/

    val v = sc.textFile("file:///devel/spark-study/v.input").map {
      line =>
        val xs = line.split(" ")
        (xs(0), xs.drop(0))
    }
      //.partitionBy(parters(0))
      .setName("v") .cache()
    /*val v = sc.makeRDD(Seq(
      (10, Array.tabulate[Double](cols)(x => x * 2 + 1)),
      (11, Array.tabulate[Double](cols)(x => x * 2 + 1 + 10)),
      (12, Array.tabulate[Double](cols)(x => x * 2 + 1 + 100)),
      (10, Array.tabulate[Double](cols)(x => x * 2 + 1 + 1000))
    )) .partitionBy(new HashPartitioner(3))
    .setName("v").cache()*/

    /*val w = sc.makeRDD(Seq(
      (10, Array.tabulate[Double](cols)(x => x * 2 + 1)),
      (11, Array.tabulate[Double](cols)(x => x * 2 + 1 + 10)),
      (12, Array.tabulate[Double](cols)(x => x * 2 + 1 + 100)),
      (10, Array.tabulate[Double](cols)(x => x * 2 + 1 + 1000))
    )) .partitionBy(new HashPartitioner(3))
      .setName("v").cache()*/


    def getProcessInfo = {
      s"${ManagementFactory.getRuntimeMXBean.getName}.${Thread.currentThread().getId}"
    }

    println(s"driver: $getProcessInfo}")

    //u.foreachPartition(xs => { println(s"partition[$getProcessInfo]: ${xs.foldLeft("")((result, x) => result ++ " " ++ stringify(x._2))}") })
    //v.foreachPartition(xs => { println(s"partition[$getProcessInfo]: ${xs.foldLeft("")((result, x) => result ++ " " ++ stringify(x._2))}") })
    //u.foreach(x => { println(s"partition[$getProcessInfo]: ${stringify(x._2)}") })
    //v.foreach(x => { println(s"partition[$getProcessInfo]: ${stringify(x._2)}") })
    //w.foreachPartition(xs => { println(s"partition[$getProcessInfo]: ${xs.foldLeft("")((result, x) => result ++ " " ++ stringify(x._2))}") })
    u.count()
    v.count()

    // to shuffle or not to shuffle?
    val joined = u.join(
      v //, parters(0)
    ).setName("joined1").cache()
    joined.foreachPartition(xs => { println(s"partition[$getProcessInfo]: ${xs.foldLeft("")((result, x) => result ++ " " ++ stringify(x._2._1) ++ ", " ++ stringify(x._2._2))}") })
    //joined.foreach(x => { println(s"partition[$getProcessInfo]: ${stringify(x._2._1) ++ ", " ++ stringify(x._2._2)}") })

    sc.stop()
  }

  def matrixMultiply_v1(sc: SparkContext, rows: Int, cols: Int, u_mat: RDD[Array[Double]], v_mat: RDD[Array[Double]]): RDD[Array[Double]] = {
    val product = u_mat.cartesian(v_mat).map { case (u, v) =>
      var result = 0.0
      var i = 0
      while (i < u.length) {
        result += u(i) * v(i)
        i += 1
      }
      result
    }
    val product_collected = product.collect()

    sc.makeRDD(
      Array.tabulate[Double](rows, rows)((i, j) => product_collected(i * cols + j))
    )
  }

  def scalarMultiplicationScala(array_size: Int, parallel: Int): Array[Double] = {
    val xs  = scalaParallelArray(array_size, parallel)
    val xs_scaled = xs.map(_ * 2.0)
    xs_scaled.toArray
  }

  def scalaParallelArray(array_size: Int, parallel: Int): ParVector[Double] = {
    val xs = ParVector.tabulate(array_size)(x => x.toDouble)
    xs.tasksupport = new ForkJoinTaskSupport(new ForkJoinPool(parallel))
    xs
  }

  def dotProductScala(array_size: Int, parallel: Int): Double = {
    val xs = scalaParallelArray(array_size, parallel)
    val ys = scalaParallelArray(array_size, parallel)
    xs.zip(ys).foldLeft(0.0) { case (sum, (x, y)) =>
      sum + x * y
    }
  }

  def scalarMultiplicationSpark(sc: SparkContext, array_size: Int, parallel: Int): Array[Double] = {
    val xs = Array.tabulate(array_size)(x => x.toDouble)
    val xs_rdd = sc.parallelize(xs, parallel)
    val xs_scaled = xs_rdd.map(_ * 2.0)
    xs_scaled.collect()
  }

  def stringify[T](xs: Array[T]): String = {
    "[" ++ xs.foldLeft("") { (result, x) =>
      result + " " + x.toString
    } ++ "]"
  }

  def consume(xs: Array[Double]): Unit = {
    printf("scaled_xs: [%s]\n", xs.foldLeft("") { (result, x) =>
      result + " " + x.toString
    })
  }

}
