package edu.brown.cs.sparkstudy

import org.apache.spark.{SparkConf, SparkContext}

import scala.collection.parallel.ForkJoinTaskSupport
import scala.collection.parallel.immutable.ParVector
import scala.concurrent.forkjoin.ForkJoinPool

object SparkExp {

  val params_ = Array("<array_size>", "<parallel_level>")

  def main(args: Array[String]) = {
    if (args.length < params_.length) {
      printUsage()
      System.exit(123)
    }
    val array_size = args(0).toInt
    val parallel_level = args(1).toInt
    val sc = new SparkContext(new SparkConf().setAppName("Exp").setMaster("local[2]"))

    consume(scalarMultiplicationScala(array_size, parallel_level))

    consume(scalarMultiplicationSpark(sc, array_size, parallel_level))
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
