package edu.brown.cs.sparkstudy

import java.lang.Math._
import java.util.concurrent.{ThreadPoolExecutor, Executors, ConcurrentHashMap}

import breeze.linalg.{DenseVector, DenseMatrix}
import org.apache.spark.SparkContext
import org.apache.spark.rdd.RDD

import scala.collection.mutable
import scala.collection.mutable.ArrayBuffer
import scala.collection.parallel.{ThreadPoolTaskSupport, ForkJoinTaskSupport}
import scala.collection.parallel.immutable.ParRange
import scala.concurrent.forkjoin
import scala.concurrent.forkjoin.ForkJoinPool
import scala.io.Source
import scala.reflect.ClassTag
import scala.util.Random

object CfSgdCommon {

  val algebrans = Map("none" -> new Algebran(), "dotptime" -> new TimerAlgebran())

  // TODO: create Tile data type, internally being a sparse matrix
  // When doing so, need to reserve this Array-based Tile for ScalaSgd
  case class Tile[T: ClassTag](data: Array[T])

  trait Edge {
    def user: Int
    def movie: Int
    def rating: Int
  }

  case class SimpleEdge(user: Int, movie: Int, rating: Int) extends Edge

  case class EdgeBreeze(user_movie_rating_triplet: DenseVector[Int]) extends Edge {
    override def user = user_movie_rating_triplet(0)
    override def movie = user_movie_rating_triplet(1)
    override def rating = user_movie_rating_triplet(2)
  }

  object EdgeBreeze {
    def apply(user: Int, movie: Int, rating: Int) = new EdgeBreeze(DenseVector(user, movie, rating))
  }

  val MAXVAL = 1e+100
  val MINVAL = -1e+100
  val LAMBDA = 0.001
  val STEP_DEC = 0.9
  val randGen = new Random(4562727)

  val argNames = Array("<latent>", "<filename>", "<nusers>", "<nmovies>", "<nratings>", "<nthreads>")

  def printUsage(exe: String) = {
    printf("Usage: %s %s\n", exe, argNames.foldLeft("")(_ + " " + _))
  }

  def readRatings(filename: String, num_ratings: Int): Array[Edge] = {
    Source.fromFile(filename).getLines().take(num_ratings).map { line =>
      val e = line.split(" ").map(_.toInt)
      SimpleEdge(e(0), e(1), e(2)).asInstanceOf[Edge]
    }.toArray
  }

  def readRatingsBreeze(filename: String, num_ratings: Int): Array[Edge] ={
    Source.fromFile(filename).getLines().map { line =>
      val e = line.split(" ").map(_.toInt)
      //EdgeBreeze(e(0), e(1), e(2)).asInstanceOf[Edge]
      SimpleEdge(e(0), e(1), e(2)).asInstanceOf[Edge]
    }.toArray
  }

  def randomMatrixOf(rows: Int, cols: Int): Array[Double] = {
    Array.tabulate(rows * cols)(_ => (-1) + 2 * randGen.nextDouble())
  }

  def randomMatrixOfVectors(rows: Int, cols: Int): Array[Array[Double]] = {
    Array.tabulate(rows, cols){
      case (_, _) => (-1) + 2 * randGen.nextDouble()
    }
  }

  def randomBreezeMatrixOf(rows: Int, cols: Int): DenseMatrix[Double] = {
    DenseMatrix.rand(rows, cols)
  }

  def hashEdgeIndicesToTiles(edges: Array[Edge], num_tiles_x: Int, num_tiles_y: Int, num_users: Int, num_movies: Int): Array[Tile[Int]] = {
    hashEdgesToTiles(edges, num_tiles_x, num_tiles_y, num_users, num_movies, i => i)
  }

  def hashEdgeDataToTiles(edges: Array[Edge], num_tiles_x: Int, num_tiles_y: Int, num_users: Int, num_movies: Int): Array[Tile[Edge]] = {
    hashEdgesToTiles(edges, num_tiles_x, num_tiles_y, num_users, num_movies, i => edges(i))
  }

  private def hashEdgesToTiles[T: ClassTag](edges: Array[Edge], num_tiles_x: Int, num_tiles_y: Int, num_users: Int, num_movies: Int, filler: (Int) => T): Array[Tile[T]] = {
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
      tile_x * num_tiles_y + tile_y
    }

    val tiles_table_ = Array.tabulate(num_tiles_x * num_tiles_y) {
      _ => mutable.ArrayBuilder.make[T]
    }
    var i = 0
    while (i < edges.length) {
      tiles_table_(hash(edges(i))) += filler(i)
      i += 1
    }
    tiles_table_.map(b => Tile(b.result()))
  }

  def toEdgeTileRdds(edgePartitionTiles: Array[Array[Edge]], sc: SparkContext): Array[RDD[Edge]] = {
    edgePartitionTiles.map { tile =>
      sc.parallelize(tile, 1) // No parallelism, because each core takes exactly one tile (=RDD) at a time.
    }
  }

  def truncate(x: Double): Double = {
    max(MINVAL, min(MAXVAL, x))
  }

  class Algebran extends Serializable {
    //val timers = collection.mutable.Map[Int, Int]
    def dotP(vector_len: Int, U_mat: Array[Double], u_start: Int, V_mat: Array[Double], v_start: Int): Double = {
      var result = 0.0
      var i = 0
      while (i < vector_len) {
        result += U_mat(u_start + i) * V_mat(v_start + i)
        i += 1
      }
      result
    }

    def breezeDotP(U_mat: DenseMatrix[Double], u_idx: Int, V_mat: DenseMatrix[Double], v_idx: Int): Double = {
      U_mat(::, u_idx) dot V_mat(::, v_idx)
    }
  }

  class TimerAlgebran extends Algebran {
    val timers = new ConcurrentHashMap[Long, Long]()

    override def dotP(vector_len: Int, U_mat: Array[Double], u_start: Int, V_mat: Array[Double], v_start: Int): Double = {
      val start = System.currentTimeMillis()
      val result = super.dotP(vector_len, U_mat, u_start, V_mat, v_start)
      val end = System.currentTimeMillis()
      val tid = Thread.currentThread().getId
      timers.put(tid, timers.getOrDefault(tid, 0l) + end - start)
      result
    }

    override def breezeDotP(U_mat: DenseMatrix[Double], u_idx: Int, V_mat: DenseMatrix[Double], v_idx: Int): Double = {
      val start = System.currentTimeMillis()
      val result = super.breezeDotP(U_mat, u_idx, V_mat, v_idx)
      val end = System.currentTimeMillis()
      val tid = Thread.currentThread().getId
      timers.put(tid, timers.getOrDefault(tid, 0l) + end - start)
      result
    }

    def getTimes(): Array[Long] = {
      val vs = timers.values()
      val result = mutable.ArrayBuilder.make[Long]()
      val iter = vs.iterator()
      while (iter.hasNext) {
        result += iter.next()
      }
      result.result()
    }

    def clear() = {
      timers.clear()
    }
  }

  def printDotpTimeIfNeeded(algebran: Algebran): Unit = {
    algebran match {
      case algebran1: TimerAlgebran =>
        val ts = algebran1.getTimes()
        println(s"[info] dotptime avg: ${ts.sum / ts.length} ms, std: ${Math.sqrt(ts.foldLeft(0.0)((s, x) => s + Math.pow(x - ts.sum / ts.length, 2)) / ts.length)}, number of threads: ${ts.length} ")
      case _ =>
    }
  }

  def resetAlgebranTimerIfNeeded(algebran: Algebran) = {
    algebran match {
      case algebran1: TimerAlgebran =>
        algebran1.clear()
      case _ =>
    }
  }

  def matrixMultiply(u_mat: RDD[Array[Double]], v_mat: RDD[Array[Double]]): RDD[Double] = {
    u_mat.cartesian(v_mat).map { case (u, v) =>
      var result = 0.0
      var i = 0
      while (i < u.length) {
        result += u(i) * v(i)
        i += 1
      }
      truncate(result)
    }
  }

  //def breezeDotP(U_mat: DenseMatrix[Double], u_idx: Int, V_mat: DenseMatrix[Double], v_idx: Int): Double = {
  //  U_mat(::, u_idx) dot V_mat(::, v_idx)
  //}

  def parallelize(range: Range, parallel_level: Int): ParRange = {
    val result = range.par
    //result.tasksupport = new ThreadPoolTaskSupport(Executors.newFixedThreadPool(parallel_level).asInstanceOf[ThreadPoolExecutor]) //new ForkJoinTaskSupport(new forkjoin.ForkJoinPool(parallel_level)) //(Executors.newFixedThreadPool(parallel_level).asInstanceOf[ThreadPoolExecutor])
    result.tasksupport = new ForkJoinTaskSupport(new forkjoin.ForkJoinPool(parallel_level))
    result
  }

  def numUniqueIn(tile: Tile[Edge], idOf: (Edge) => Int): Int = {
    tile.data.map(idOf(_)).toSet.size
  }
}
