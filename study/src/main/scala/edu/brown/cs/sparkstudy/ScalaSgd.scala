package edu.brown.cs.sparkstudy

import java.lang.Math._

import scala.collection.mutable.ArrayBuffer
import scala.collection.parallel.ForkJoinTaskSupport
import scala.concurrent.forkjoin.ForkJoinPool
import scala.io.Source
import scala.util.Random

object ScalaSgd {

  val argNames = Array("<latent>", "<filename>", "<nusers>", "<nmovies>", "<nratings>", "<nthreads>")
  val MAXVAL = 1e+100
  val MINVAL = -1e+100
  val LAMBDA = 0.001
  val STEP_DEC = 0.9
  val randGen = new Random(4562727)

  case class Edge(user: Int, movie: Int, rating: Int)

  def printUsage() = {
    printf("Usage: ScalaSgd %s\n", argNames.foldLeft("")(_ + " " + _))
  }

  def readRatings(filename: String, num_ratings: Int): Array[Edge] = {
    Source.fromFile(filename).getLines().map { line =>
      val e = line.split(" ").map(_.toInt)
      Edge(user = e(0), e(1), e(2))
    }.toArray.take(num_ratings)
  }

  def randomMatrixOf(rows: Int, cols: Int): Array[Double] = {
    Array.tabulate(rows * cols)(_ => (-1) + 2 * randGen.nextDouble())
  }
  
  def hashEdgesToTiles(edges: Array[Edge], num_tiles_x: Int, num_tiles_y: Int, num_users: Int, num_movies: Int): Array[Array[Int]] = {
    def hash(e: Edge): Int = {
      val num_users_per_tile = floor(num_users.toDouble / num_tiles_x)
      val num_movies_per_tile = floor(num_movies.toDouble / num_tiles_y)
      val tile_x = min(
        floor((e.user - 1) / num_users_per_tile).toInt, // user_id starts from 1
        num_tiles_x - 1
      )
      val tile_y = min(
        floor((e.movie - 1) / num_movies_per_tile).toInt, // movie_id starts from 1
        num_tiles_y - 1
      )
      tile_x * num_tiles_x + tile_y
    }
    val tiles_table_ = Array.tabulate(num_tiles_x * num_tiles_y) {
      _ => new ArrayBuffer[Int]
    }
    //edges.map(e => tiles_table_(hash(e)) )
    //tiles_table_.map( b => b.toArray)
    var i = 0
    while (i < edges.length) {
      tiles_table_(hash(edges(i))).append(i)
      i += 1
    }
    tiles_table_.map(b => b.toArray)
  }

  def truncate(x: Double): Double = {
    max(MINVAL, min(MAXVAL, x))
  }

  def dotP(vector_len: Int, U_mat: Array[Double], u_start: Int, V_mat: Array[Double], v_start: Int): Double = {
    var result = 0.0
    var i = 0
    while (i < vector_len) {
      result += U_mat(u_start + i) * V_mat(v_start + i)
      i += 1
    }
    result
  }

  def main(args: Array[String]): Unit = {
    if (args.length < argNames.length) {
      printUsage()
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

    val tiles_mat = hashEdgesToTiles(
      user_movie_ratings,
      num_tiles_x = num_nodes * num_procs,
      num_tiles_y = num_nodes * num_procs,
      num_users,
      num_movies
    )

    //printf("[debug] tiles_mat:")
    //printf("[debug] tiles_mat:\n%s\n", tiles_mat.deep.mkString("\n"))
    //tiles_mat.foreach { x => println(x.length) }

    var gamma = 0.001
    val max_iter = 5
    (0 until max_iter).foreach { itr =>
      val tbegin = System.currentTimeMillis()
      (0 until num_nodes).foreach { l =>
        val rows = (0 until num_nodes).toArray
        val cols = (0 until num_nodes).map(x => (l + x) % num_nodes)
        /*println("[debug] rows and cols:")
        rows.foreach(x => print(x + " "))
        println()
        cols.foreach(x => print(x + " "))
        println()*/

        // This is the loop to be parallelized over all the nodes
        // #pragma omp parallel for
        (0 until num_nodes).foreach { k =>
          (0 until num_procs).foreach { pidx1 =>
            val rowsp = (0 until num_procs).toArray
            val colsp = (0 until num_procs).map(x => (pidx1 + x) % num_procs)

            /*println("[debug] rowsp and colsp:")
            rowsp.foreach(x => print(x + " "))
            println()
            colsp.foreach(x => print(x + " "))
            println()*/

            // This loop needs to be parallelized over cores
            val parCores = (0 until num_procs).par
            parCores.tasksupport = new ForkJoinTaskSupport(new ForkJoinPool(num_procs))
            parCores foreach { pidx2 =>
            //(0 until num_procs).toList foreach { pidx2 =>
              /*printf("[debug] tiles matrxi index: %d\n",
                rows(k) * num_procs * (num_nodes * num_procs) +
                cols(k) * num_procs +
                rowsp(pidx2) * (num_procs * num_nodes) +
                colsp(pidx2)
              )*/
              val v = tiles_mat(
                rows(k) * num_procs * (num_nodes * num_procs) +
                cols(k) * num_procs +
                rowsp(pidx2) * (num_procs * num_nodes) +
                colsp(pidx2)
              )

              v.foreach { i =>
                val e = user_movie_ratings(i)

                val pred = truncate(
                  dotP(num_latent, U_mat, (e.user - 1) * num_latent, V_mat, (e.movie - 1) * num_latent)
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
