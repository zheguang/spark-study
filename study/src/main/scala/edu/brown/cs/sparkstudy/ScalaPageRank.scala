package edu.brown.cs.sparkstudy

import java.util.concurrent.atomic.AtomicBoolean

import edu.brown.cs.sparkstudy.CfSgdCommon._
import edu.brown.cs.sparkstudy.JavaPageRank.Csr

object ScalaPageRank {
  val RDM_JMP = 0.3
  val THRESH = 0.000001

  def main(args: Array[String]) = {
    val file = args(0)
    val numThreads = args(1).toInt
    val graph = Csr.from(file)

    computePageRankCsr(graph, numThreads)


  }

  def computePageRankCsr(graph: Csr, numThreads: Int) = {
    var terminate = false
    val rand_jump = RDM_JMP
    val purpose_jump = 1 - RDM_JMP
    var iter = 0

    val start = System.currentTimeMillis()
    while (!terminate) {
      iter += 1
      terminate = true

      //#pragma omp parallel for num_threads(num_threads) shared(graph) schedule(guided,4096)
      val numVerticesPerThread = Math.ceil(graph.v_size.toDouble / numThreads.toDouble).toInt
      //for(int i=0;i<graph.v_size;i=(i+numVerticesPerThread)){
      val result = parallelize(0 until numThreads, numThreads) map { tid =>
        val startVertexId = tid * numVerticesPerThread
        val numVertices = Math.min((tid + 1) * numVerticesPerThread, graph.v_size) - startVertexId;
        processSubgraph(graph, rand_jump, purpose_jump, startVertexId, numVertices)
      }
      terminate = result.count(_ == true) > 0
    }
    val end = System.currentTimeMillis()
    printf("[info] Overall time = %d seconds\n", end - start)
    printf("[info] Iters = %d\n", iter)

    // todo: debug
    var sum = 0.0
    var i = 0
    while (i < graph.v_size) {
      sum += graph.vet_wr(i).weight
      i += 1
    }
    printf("[debug] sum = %f\n", sum);
  }

  def processSubgraph(graph: Csr, rand_jump: Double, purpose_jump: Double, startVertexId: Int, numVertices: Int): Boolean = {
    val result = (startVertexId until startVertexId + numVertices).map { i =>
      var terminate = true
      val rev_vet_idx_start = if (i == 0) 0 else graph.rev_vet_idx(i - 1)
      (rev_vet_idx_start until graph.rev_vet_idx(i)).foreach { j =>
        val source = i
        val target = graph.rev_edge_idx(j)
        //int target_2 = graph.rev_edge_idx[j+8];
        //printf("source %d target %d pr target %f rp target %f\n", source, target, graph.vet_wr[target].weight, graph.vet_wr[target].recip);
        graph.vet_weight_back(source) += graph.vet_wr(target).weight * graph.vet_wr(target).recip;
      }
      graph.vet_weight_back(i) = rand_jump + purpose_jump*graph.vet_weight_back(i);
      if(Math.abs(graph.vet_weight_back(i)-graph.vet_wr(i).weight)>THRESH)
        terminate = false
      graph.vet_wr(i).weight = graph.vet_weight_back(i)
      //printf("%f %f ", graph.vet_wr[i].weight, 1.0/graph.vet_wr[i].recip);
      graph.vet_weight_back(i) = 0.0

      terminate
    }

    result.count(_ == true) > 0
  }
}
