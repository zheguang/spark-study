package com.intel.sparkstudy.matrix

import breeze.linalg.{norm, DenseVector, DenseMatrix}
import breeze.optimize.DiffFunction


/**
 * Created by sam on 7/6/15.
 */
object LearnBreeze {

  def main(args: Array[String]): Unit = {
    val x = DenseVector(0.1, 0.2, 0.3, 0.4, 0.5)
    x(0 to 1) := DenseVector(0.11, 0.22)
    printf("%s\n", x.toString())
  }
}
