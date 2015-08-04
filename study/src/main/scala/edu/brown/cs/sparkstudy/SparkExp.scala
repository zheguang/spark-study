package edu.brown.cs.sparkstudy

import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}

import scala.collection.mutable.ArrayBuffer
import scala.collection.parallel.ForkJoinTaskSupport
import scala.collection.parallel.immutable.ParVector
import scala.concurrent.forkjoin.ForkJoinPool

object SparkExp {

  val params_ = Array("<array_size>", "<parallel_level>")
  val sc = new SparkContext(new SparkConf().setAppName("Exp").setMaster("local[2]"))

  def main(args: Array[String]) = {
    if (args.length < params_.length) {
      printUsage()
      System.exit(123)
    }
    val array_size = args(0).toInt
    val parallel_level = args(1).toInt

    consume(scalarMultiplicationScala(array_size, parallel_level))
    consume(scalarMultiplicationSpark(sc, array_size, parallel_level))

    val rows = 3
    val cols = 4
    val u_mat = sc.makeRDD(Array.tabulate[Double](rows, cols)((i, j) => i + j))
    val v_mat = sc.makeRDD(Array.tabulate[Double](rows, cols)((i, j) => i - j))
    val result = matrixMultiply_v1(rows, cols, u_mat, v_mat)


  }

  def matrixMultiply_v1(rows: Int, cols: Int, u_mat: RDD[Array[Double]], v_mat: RDD[Array[Double]]): RDD[Array[Double]] = {
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

  def matrixMultiply_v2(rows: Int, cols: Int, u_mat: RDD[Array[Double]], v_mat: RDD[Array[Double]]): RDD[Array[Double]] = {
    val product = u_mat.cartesian(v_mat).aggregateByKey(new ArrayBuffer[Double]())
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

  def printUsage(): Unit = {
    printf("Usage: SparkExp %s\n", params_.foldLeft("")((result, x) => result + x))
  }

  def consume(xs: Array[Double]): Unit = {
    printf("scaled_xs: [%s]\n", xs.foldLeft("") { (result, x) =>
      result + " " + x.toString
    })
  }

}
