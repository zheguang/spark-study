package edu.brown.cs.sparkstudy

import breeze.linalg.{Matrix, DenseMatrix}
import edu.brown.cs.sparkstudy.CfSgdCommon._
import org.apache.spark.mllib.linalg.SparseMatrix

object BreezeSgd {

  def main(args: Array[String]): Unit = {
    if (args.length < argNames.length) {
      printUsage("BreezeSgd")
      System.exit(123)
    }

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
    val U_mat = randomBreezeMatrixOf(num_latent, num_users) // A: column major for latent dimension
    val V_mat = randomBreezeMatrixOf(num_latent, num_movies) // WARNING: column major for latent dimension
    val tend_uvinit = System.currentTimeMillis()
    printf("Time in U-V init: %d (ms)\n", tend_uvinit - tbegin_uvinit)

    val num_tiles_x = num_nodes * num_procs
    val num_tiles_y = num_nodes * num_procs
    val tiles = hashEdgeIndicesToTiles(
      user_movie_ratings,
      num_tiles_x,
      num_tiles_y,
      num_users,
      num_movies
    )
    val tiles_mat = new DenseMatrix(num_tiles_x, num_tiles_y, tiles)

    train(num_procs, num_nodes, user_movie_ratings, U_mat, V_mat, num_latent, tiles_mat)

    computeTrainingError(num_user_movie_ratings, user_movie_ratings, U_mat, V_mat)
  }

  def train(num_procs: Int, num_nodes: Int, user_movie_ratings: Array[Edge], U_mat: DenseMatrix[Double], V_mat: DenseMatrix[Double], num_latent: Int, tiles_mat: DenseMatrix[Tile[Int]]): Unit = {
    var gamma = 0.001
    val max_iter = 5
    (0 until max_iter).foreach { itr =>
      val tbegin = System.currentTimeMillis()
      (0 until num_nodes).foreach { l =>
        val rows = (0 until num_nodes).toArray
        val cols = (0 until num_nodes).map(x => (l + x) % num_nodes)

        // This is the loop to be parallelized over all the nodes
        // #pragma omp parallel for
        (0 until num_nodes).foreach { k =>
          (0 until num_procs).foreach { pidx1 =>
            // diagnoal participating tiles per iter
            val rowsp = (0 until num_procs).toArray
            val colsp = (0 until num_procs).map(x => (pidx1 + x) % num_procs)

            // This loop needs to be parallelized over cores
            parallelize(0 until num_procs, num_procs) foreach { pidx2 =>
            //(0 until num_procs).foreach { pidx2 =>
              // skip k nodes worth of procs, and skip to my proc
              // tile = per proc work
              //val v = tiles_mat(
              //  rows(k) * num_procs * (num_nodes * num_procs) +
              //    cols(k) * num_procs +
              //    rowsp(pidx2) * (num_procs * num_nodes) +
              //    colsp(pidx2)
              //)
              val v = tiles_mat(
                rows(k) * num_procs + rowsp(pidx2),
                cols(k) * num_procs + colsp(pidx2)
              )

              v.data foreach { i =>
                val e = user_movie_ratings(i)

                val pred = truncate(
                  breezeDotP(U_mat, e.user - 1, V_mat, e.movie - 1)
                  //dotP(20, U_mat.data, (e.user - 1)*20, V_mat.data, (e.movie - 1)*20)
                )

                val err = pred - e.rating

                /*(0 until num_latent).foreach { j =>
                  U_mat.unsafeUpdate(j, e.user - 1, U_mat(j, e.user - 1)
                    -gamma * (
                      err * V_mat(j, e.movie - 1) +
                        LAMBDA * U_mat(j, e.user - 1)
                      )
                  );
                }*/
                /*U_mat(::, e.user - 1) :+= -gamma * (
                  err * V_mat(::, e.movie - 1) + LAMBDA * U_mat(::, e.user - 1)
                )*/
                val u_ = -gamma * (err * V_mat(::, e.movie - 1) + LAMBDA * U_mat(::, e.user - 1))
                U_mat(::, e.user - 1) :+= u_

                /*(0 until num_latent).foreach { j =>
                  V_mat.unsafeUpdate(j, e.movie - 1, V_mat(j, e.movie - 1)
                    -gamma * (
                      err * U_mat(j, e.user - 1) +
                        LAMBDA * V_mat(j, e.movie - 1)
                      )
                  );
                }*/
                /*V_mat(::, e.movie - 1) :+= -gamma * (
                  err * U_mat(::, e.user - 1) + LAMBDA * V_mat(::, e.movie - 1)
                )*/
                val v_ = -gamma * (err * U_mat(::, e.user - 1) + LAMBDA * V_mat(::, e.movie - 1))
                V_mat(::, e.movie - 1) :+= v_
              }
            }
          }
        }
      }
      gamma *= STEP_DEC
      val tend = System.currentTimeMillis()
      printf("Time in iteration %d of sgd %d (ms)\n", itr, tend - tbegin)
    }
  }

  def computeTrainingError(num_user_movie_ratings: Int, user_movie_ratings: Array[Edge], U_mat: DenseMatrix[Double], V_mat: DenseMatrix[Double]): Unit = {
    // Calculate training error
    val sqerrs = user_movie_ratings.par map { e =>
      val pred = truncate(
        breezeDotP(U_mat, e.user - 1, V_mat, e.movie - 1)
      )
      Math.pow(pred - e.rating, 2)
    }
    val train_err = Math.sqrt(sqerrs.sum / num_user_movie_ratings)
    printf("Training rmse %f\n", train_err)
  }
}

