package edu.brown.cs.sparkstudy

import java.lang.Math._

import breeze.linalg.{DenseVector, DenseMatrix}

import scala.collection.mutable.ArrayBuffer
import scala.collection.parallel.ForkJoinTaskSupport
import scala.collection.parallel.immutable.ParRange
import scala.concurrent.forkjoin.ForkJoinPool
import scala.io.Source
import scala.util.Random

object CfSgdCommon {

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
    Source.fromFile(filename).getLines().map { line =>
      val e = line.split(" ").map(_.toInt)
      SimpleEdge(e(0), e(1), e(2)).asInstanceOf[Edge]
    }.toArray.take(num_ratings)
  }

  def readRatingsBreeze(filename: String, num_ratings: Int): Array[Edge] ={
    Source.fromFile(filename).getLines().map { line =>
      val e = line.split(" ").map(_.toInt)
      EdgeBreeze(e(0), e(1), e(2)).asInstanceOf[Edge]
    }.toArray.take(num_ratings)
  }

  def randomMatrixOf(rows: Int, cols: Int): Array[Double] = {
    Array.tabulate(rows * cols)(_ => (-1) + 2 * randGen.nextDouble())
  }

  def randomBreezeMatrixOf(rows: Int, cols: Int): DenseMatrix[Double] = {
    DenseMatrix.rand(rows, cols)
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

  def breezeDotP(U_mat: DenseMatrix[Double], u_idx: Int, V_mat: DenseMatrix[Double], v_idx: Int): Double = {
    U_mat(::, u_idx) dot V_mat(::, v_idx)
  }

  def parallelize(range: Range, parallel_level: Int): ParRange = {
    val result = range.par
    result.tasksupport = new ForkJoinTaskSupport(new ForkJoinPool(parallel_level))
    result
  }
}
