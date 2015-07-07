package com.intel.sparkstudy.matrix

import java.util.Random

import org.apache.spark.mllib.linalg.{DenseMatrix, Matrices, Matrix}

object Learn {

  def main(args: Array[String]): Unit = {
    val seed = 1
    val randGen = new Random(seed)
    val m1 = Matrices.dense(3, 2, Array(1,2,3,4,5,6))
    val m2 = Matrices.dense(2, 3, Array(6,7,8,9,10,11))
    println(m1.toString())
    println()
    println(m2.toString())

    val m3 = m1.multiply(m2.asInstanceOf[DenseMatrix])
    println(m3)
  }
}
