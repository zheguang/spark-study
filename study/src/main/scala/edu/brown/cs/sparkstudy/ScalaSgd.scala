package edu.brown.cs.sparkstudy

import java.lang.Math._

import breeze.linalg.DenseMatrix
import edu.brown.cs.sparkstudy.CfSgdCommon._

object ScalaSgd {

  def main(args: Array[String]): Unit = {
    if (args.length < argNames.length) {
      printUsage("ScalaSgd")
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
    val user_movie_ratings = readRatings(filename, num_user_movie_ratings)
    val tend_read = System.currentTimeMillis()
    printf("Time in data read: %d (ms)\n", tend_read - tbegin_read)

    val tbegin_uvinit = System.currentTimeMillis()
    val U_mat = randomMatrixOf(num_users, num_latent)
    val V_mat = randomMatrixOf(num_movies, num_latent)
    val tend_uvinit = System.currentTimeMillis()
    printf("Time in U-V init: %d (ms)\n", tend_uvinit - tbegin_uvinit)

    val tiles_mat = hashEdgeIndicesToTiles(
      user_movie_ratings,
      num_tiles_x = num_nodes * num_procs,
      num_tiles_y = num_nodes * num_procs,
      num_users,
      num_movies
    )

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
            val rowsp = (0 until num_procs).toArray
            val colsp = (0 until num_procs).map(x => (pidx1 + x) % num_procs)

            // This loop needs to be parallelized over cores
            parallelize(0 until num_procs, num_procs) foreach { pidx2 =>
              val v = tiles_mat(
                rows(k) * num_procs * (num_nodes * num_procs) +
                cols(k) * num_procs +
                rowsp(pidx2) * (num_procs * num_nodes) +
                colsp(pidx2)
              )

              v.data foreach { i =>
                val e = user_movie_ratings(i)

                val pred = truncate(
                  dotP(num_latent, U_mat, (e.user - 1) * num_latent, V_mat, (e.movie - 1) * num_latent)
                  //breezeDotP(new DenseMatrix(num_latent, num_users, U_mat), e.user - 1, new DenseMatrix(num_latent, num_movies, V_mat), e.movie - 1)
                )

                val err = pred - e.rating

                (0 until num_latent).foreach { j =>
                  U_mat((e.user - 1) * num_latent + j) +=
                    - gamma * (
                      err * V_mat((e.movie - 1) * num_latent + j) +
                      LAMBDA * U_mat((e.user - 1 ) * num_latent + j)
                    );
                }

                (0 until num_latent).foreach { j =>
                  V_mat((e.movie - 1) * num_latent + j) +=
                    - gamma * (
                      err * U_mat((e.user - 1) * num_latent + j) +
                      LAMBDA * V_mat((e.movie - 1) * num_latent + j)
                    );
                }
              }
            }
          }
        }
      }
      gamma *= STEP_DEC
      val tend = System.currentTimeMillis()
      printf("Time in iteration %d of sgd %d (ms)\n", itr, tend - tbegin)
    }

    // Calculate training error
    val sqerrs = user_movie_ratings.map { e =>
      val pred = truncate(
        dotP(num_latent, U_mat, (e.user - 1) * num_latent, V_mat, (e.movie - 1) * num_latent)
      )
      pow(pred - e.rating, 2)
    }
    val train_err = sqrt(sqerrs.sum / num_user_movie_ratings)
    printf("Training rmse %f\n", train_err)
  }
}
