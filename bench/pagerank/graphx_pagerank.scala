import org.apache.spark._
import org.apache.spark.graphx._
import org.apache.spark.rdd.RDD

object GraphXPageRank {

  def main(args: Array[String]): Unit = {

    val conf = new SparkConf().setAppName("graphx_pargerank")
    val sc = new SparkContext(conf)

    val fname = "s3n://closing-the-gap/facebookB.graphx"
    val graph = GraphLoader.edgeListFile(sc, fname).cache
    //val graph = GraphLoader.edgeListFile(sc, fname, numEdgePartitions=64).cache
    graph.vertices.count
    graph.edges.count

    val pr_start = System.currentTimeMillis
    //val ranks = graph.pageRank(0.0001).vertices
    //val ranks = org.apache.spark.graphx.lib.PageRank.run(graph, 1.toInt, 0.3.toDouble)
    //val ranks = org.apache.spark.graphx.lib.PageRank.run(graph, 50.toInt, 0.3.toDouble)
    val ranks = org.apache.spark.graphx.lib.PageRank.run(graph, 91.toInt, 0.3.toDouble)
    ranks.vertices.count
    val pr_end = System.currentTimeMillis
    val total_runtime = (pr_end - pr_start) / 1000.0

    val elt1 = ranks.vertices.flatMap(v=>if(v._1 == 1) Array(v._2).iterator else Array().iterator).collect
    val elt2 = ranks.vertices.flatMap(v=>if(v._1 == 2) Array(v._2).iterator else Array().iterator).collect
    val elt3 = ranks.vertices.flatMap(v=>if(v._1 == 3) Array(v._2).iterator else Array().iterator).collect

    println("Total runtime: " + total_runtime.toString)
    println("Elements: " + elt1(0).toString + " " + elt2(0).toString + " " + elt3(0).toString)
  }
}
