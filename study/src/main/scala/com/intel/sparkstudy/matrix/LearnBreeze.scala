package com.intel.sparkstudy.matrix

import breeze.linalg.{norm, DenseVector, DenseMatrix}
import breeze.optimize.DiffFunction


/**
 * Created by sam on 7/6/15.
 */
object LearnBreeze {

  def main(args: Array[String]): Unit = {
//    val f = new DiffFunction[DenseVector[Double]] {
//      override def calculate(x: DenseVector[Double]): (Double, DenseVector[Double]) = {
//        (norm((x - 3d) :^ 2d, 1d), (x * 2d) - 6d)
//      }
//    }
    val x = DenseVector(0.1, 0.2, 0.3, 0.4, 0.5)
    x(0 to 1) := DenseVector(0.11, 0.22)
    printf("%s\n", x.toString())
  }
}
