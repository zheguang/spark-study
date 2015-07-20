package edu.brown.cs.sparkstudy

import org.apache.spark.graphx.lib.PageRank
import org.apache.spark.graphx.{PartitionStrategy, GraphLoader}
import org.apache.spark.storage.StorageLevel
import org.apache.spark.{Logging, SparkConf, SparkContext}

object GraphxPageRank extends Logging {

  def main(args: Array[String]): Unit = {
    if (args.length < 2) {
      System.err.println("Usage: GraphxPageRank <file> <num_iters>")
      System.exit(1)
    }

    val fname = args(0)
    val iters = args(1).toInt
    val sparkConf = new SparkConf().setAppName("GraphxPageRank(" + fname + ")")
    val ctx = new SparkContext(sparkConf)

    val numEPart = 2
    val edgeStorageLevel = StorageLevel.MEMORY_ONLY
    val vertexStorageLevel = StorageLevel.MEMORY_ONLY
    val partitionStrategy = PartitionStrategy.fromString("RandomVertexCut")
    val outFname = "file:///tmp/GraphxPagaeRank_" + fname + "_output"

    val unpartitionedGraph = GraphLoader.edgeListFile(ctx, fname,
      numEdgePartitions = numEPart,
      edgeStorageLevel = edgeStorageLevel,
      vertexStorageLevel = vertexStorageLevel).cache()
    val graph = unpartitionedGraph.partitionBy(partitionStrategy)

    val pr = PageRank.run(graph, iters).vertices.cache()

    printf("Total rank: %f\n", pr.map(_._2).reduce(_ + _))

    logWarning("Saving pageranks of pages to " + outFname)
    pr.map { case (id, r) => id + "\t" + r }.saveAsTextFile(outFname)

    ctx.stop()
  }
}
