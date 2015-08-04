package com.intel.sparkstudy.matrix

import breeze.linalg.{DenseMatrix, DenseVector}


import scala.util.Random

/**
 * Created by sam on 7/2/15.
 */
object DotProduct {

  def dot_v1(as: Array[Double], bs: Array[Double]) = {
    as.zip(bs).map(x => x._1 * x._2).sum
  }

  def dot_v2(as: Array[Double], bs: Array[Double]) = {
    (for ((a, b) <- as.zip(bs))
      yield a * b
    ).sum
  }

  def dot_v3(as: Array[Double], bs: Array[Double]) = {
    as.zip(bs).map {
      case (x, y) => x * y
    }.sum
  }

  def dot_v4(as: Array[Double], bs: Array[Double]): Double = {
    var result = 0.0
    //for (i <- as.indices) {
    //  result += as(i) * bs(i)
    //}
    //result
    var i = 0
    while (i < as.length) {
      result += as(i) * bs(i)
      i += 1
    }
    result
  }

  def dot_v5(as: DenseVector[Double], bs: DenseVector[Double]): Double = {
    as dot bs
  }

  def dot_v6_1(a_mat: DenseMatrix[Double], b_mat: DenseMatrix[Double]): Double = {
//    printf("[debug] vector length: %d\n", a_mat(::, a_mat.cols / 2).length)
    a_mat(::, a_mat.cols / 2) dot b_mat(::, b_mat.cols / 2)
  }

  def dot_v6_2(a_mat: DenseMatrix[Double], b_mat: DenseMatrix[Double]): Double = {
    var result = 0.0
    var i = a_mat.cols / 2
//    printf("[debug] vector length: %d\n", a_mat.rows)
    while (i < a_mat.rows) {
      result += a_mat.data(i) * b_mat.data(i)
      i += 1
    }
    result
  }

  //val numTrials = 1024 * 512
  val numTrials = 1024
  val seed = 3
  val randGen = new Random(seed)

  def main(args: Array[String]) = {
    val dims = Seq(20, 2000, 2000 * 1000)
    //val dims = Seq(20)
    val shortWidth = 200
    val longWidth = 2000 * 1000

    dims.foreach { dim =>
      println(s"\n[info] dim = $dim")
      val as = Array.fill(dim) { randGen.nextDouble() }
      val bs = Array.fill(dim) { randGen.nextDouble() }

      val a_vec = new DenseVector(as)
      val b_vec = new DenseVector(bs)

      val a_mat = DenseMatrix.rand(dim, shortWidth)
      val b_mat = DenseMatrix.rand(dim, shortWidth)

      // Warm up
      def warmupAll = {
        warmup_dot(as, bs, dot_v1, name="dot_v1")
        warmup_dot(as, bs, dot_v2, name="dot_v2")
        warmup_dot(as, bs, dot_v3, name="dot_v3")
        warmup_dot(as, bs, dot_v4, name="dot_v4")

        warmup_dot(a_vec, b_vec, dot_v5, name="dot_v5")

        warmup_dot(a_mat, b_mat, dot_v6_1, name="dot_v6_1")
        warmup_dot(a_mat, b_mat, dot_v6_2, name="dot_v6_2")
      }

      def benchAll(numTrials: Int) = {
        bench_dot(as, bs, dot_v1, numTrials, name="dot_v1")
        bench_dot(as, bs, dot_v2, numTrials, name="dot_v2")
        bench_dot(as, bs, dot_v3, numTrials, name="dot_v3")
        bench_dot(as, bs, dot_v4, numTrials, name="dot_v4")

        bench_dot(a_vec, b_vec, dot_v5, numTrials, name="dot_v5")

        bench_dot(a_mat, b_mat, dot_v6_1, numTrials, name="dot_v6_1")
        bench_dot(a_mat, b_mat, dot_v6_2, numTrials, name="dot_v6_2")
      }

      warmupAll
      benchAll(numTrials)
    }
  }

  def warmup_dot[T](as: T, bs: T, dot: (T, T) => Double, name: String = ""): Unit = {
    val result = dot(as, bs)
    System.err.println(s"[warmup] $name result: $result")
  }

  def bench_dot[T](as: T, bs: T, dot: (T, T) => Double, numTrials: Int, name: String = ""): Unit = {
    val startTime = System.currentTimeMillis()
    val results = (0 until numTrials).map { _ =>
      dot(as, bs)
    }
    val endTime = System.currentTimeMillis()
    printf("[bench] %s result: %f. Time: %d ms\n", name, results.sum, endTime - startTime)
  }
}
