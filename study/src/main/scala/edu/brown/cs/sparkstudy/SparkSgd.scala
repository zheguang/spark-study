package edu.brown.cs.sparkstudy

import breeze.linalg.DenseMatrix
import edu.brown.cs.sparkstudy.CfSgdCommon._
import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}

object SparkSgd {

  def main(args: Array[String]): Unit = {
    if (args.length < argNames.length) {
      printUsage("SparkSgd")
      System.exit(123)
    }
    val sc = new SparkContext(new SparkConf().setAppName("Exp").setMaster("local[2]"))

    val num_latent = args(0).toInt
    val filename = args(1)
    val num_users = args(2).toInt
    val num_movies = args(3).toInt
    val num_user_movie_ratings = args(4).toInt
    val num_procs = args(5).toInt
    val num_nodes = 1

    println(s"nlatent=$num_latent")
    println(s"filename=$filename")
    println(s"num_users=$num_users")
    println(s"num_movies=$num_movies")
    println(s"num_user_movie_ratings=$num_user_movie_ratings")
    println(s"num_procs=$num_procs")
    println(s"num_nodes=$num_nodes")

    val tbegin_read = System.currentTimeMillis()
    val user_movie_ratings = readRatingsBreeze(filename, num_user_movie_ratings)
    val tend_read = System.currentTimeMillis()
    printf("Time in data read: %d (ms)\n", tend_read - tbegin_read)

    val tbegin_uvinit = System.currentTimeMillis()
    val U_mat = randomBreezeMatrixOf(num_latent, num_users)
    val V_mat = randomBreezeMatrixOf(num_latent, num_movies)
    val tend_uvinit = System.currentTimeMillis()
    printf("Time in U-V init: %d (ms)\n", tend_uvinit - tbegin_uvinit)

    val tiles_mat = hashEdgeDataToTiles(
      user_movie_ratings,
      num_tiles_x = num_nodes * num_procs,
      num_tiles_y = num_nodes * num_procs,
      num_users,
      num_movies
    )

    val U_mats = tiles_mat.map { tile =>
      // take submatrix of U_mat(:, user_id range)
      U_mat(::, tile.data.minBy(_.user).user to tile.data.maxBy(_.user).user)
    }

    val V_mats = tiles_mat.map { tile =>
      // take submatrix of V_mat(:, movie_id range)
      V_mat(::, tile.data.minBy(_.movie).movie to tile.data.maxBy(_.movie).movie)
    }

    // TODO: customize partition function
    val tiles_mat_rdd = sc.parallelize(tiles_mat).cache()
    val U_mat_rdd = sc.parallelize(U_mats).cache()
    val V_mat_rdd = sc.parallelize(V_mats).cache()
  }
}
