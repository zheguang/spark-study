package com.intel.sparkstudy.matrix

/**
 * Created by sam on 7/2/15.
 */
object DotProduct {

  def dot_v1(as: Seq[Double], bs: Seq[Double]) = {
    as.zip(bs).map(x => x._1 * x._2).sum
  }

  def dot_v2(as: Seq[Double], bs: Seq[Double]) = {
    (for ((a, b) <- as.zip(bs))
      yield a * b
    ).sum
  }

  def dot_v3(as: Seq[Double], bs: Seq[Double]) = {
    as.zip(bs).map {
      case (x, y) => x * y
    }.sum
  }

  def dot_v4(as: Seq[Double], bs: Seq[Double]): Double = {
    var result = 0.0
    for (i <- as.indices) {
      result += as(i) * bs(i)
    }
    result
  }

  def warmup(as: Array[Double], bs: Array[Double]) = {
    printf("warming up...\n\n")
    dot_v1(as, bs)
    dot_v2(as, bs)
    dot_v3(as, bs)
    dot_v4(as, bs)
  }

  /*def main(args: Array[String]) = {
    val numTrials = 5
    val dim = 1000 * 1000 * 2
    val seed = 3
    val randGen = new Random(seed)
    val as = Array.fill(dim) { randGen.nextDouble() }
    val bs = Array.fill(dim) { randGen.nextDouble() }

    // Warm up
    warmup(as, bs)

    for (i <- 1 to numTrials) {
      bench_dot(as, bs, dot_v1, name="dot_v1")
      bench_dot(as, bs, dot_v2, name="dot_v2")
      bench_dot(as, bs, dot_v3, name="dot_v3")
      bench_dot(as, bs, dot_v4, name="dot_v4")
      printf("\n")
    }
  }*/

  def bench_dot(as: Array[Double], bs: Array[Double], dot: (Seq[Double], Seq[Double]) => Double, name: String = ""): Unit = {
    val startTime = System.currentTimeMillis()
    val result = dot(as, bs)
    val endTime = System.currentTimeMillis()
    printf("%s result: %f. Time: %d ms\n", name, result, endTime - startTime)
  }
}
