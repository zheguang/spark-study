package edu.brown.cs.sparkstudy;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.Scanner;

/**
 * Created by sam on 8/18/15.
 */
public class JavaPageRank {

    static double RDM_JMP = 0.3;
    static double THRESH = 0.000001;

    static class Csr {
        int[] edge_idx;
        int[] edge_weight;
        WeightRecip[] vet_wr;
        int[] rev_edge_idx;
        int[] rev_edge_weight;
        int[] vet_idx;
        int[] rev_vet_idx;
        int[] vet_deg;
        int[] vet_in_deg;
        double[] vet_deg_reciprocal;
        double[] vet_weight;
        double[] vet_weight_back;

        int v_size;
        int e_size;


        static Csr from(String file) throws IOException {
            Csr graph = new Csr();
            scanCsrIdx(graph, file);
            System.out.println("[info] finished scan");

            readGraphCsr(graph, file);
            System.out.println("[info] finished read");

            initPageRankCsr(graph);
            System.out.println("[info] finished init");

            return graph;
        }

        private static void initPageRankCsr(Csr graph) {
            //#pragma omp parallel for num_threads(num_threads) shared(graph) schedule(guided,4096)
            for(int i=0; i<graph.v_size; i++){
                //for(; j<graph.vet_idx[i]; j++){
                //	graph.vet_weight[i]+=graph.edge_weight[j];
                //}
                //graph.vet_weight[i]=1.0/(double)graph.v_size;
                graph.vet_weight[i]=1.0;
                graph.vet_weight_back[i]=0.0;
                graph.vet_wr[i].weight = 1.0;
                graph.vet_wr[i].recip=graph.vet_deg_reciprocal[i];
                //max_sum+=graph.vet_weight[i];
            }
        }

        private static void readGraphCsr(Csr graph, String file) throws IOException {
            int[] v_idx_tmp;
            int[] rev_v_idx_tmp;

            Scanner s = null;
            try {
                s = new Scanner(new BufferedReader(new FileReader(file)));
                // first line is metadata
                if (s.hasNextLine()) {
                    String[] tokens = s.nextLine().split(" "); // todo: merge into scanCsrIdx
                    assert tokens.length > 0;
                    assert tokens[0].equals("p");
                    String str = tokens[1];
                    assert graph.v_size == Integer.parseInt(tokens[2]);
                    assert graph.e_size == Integer.parseInt(tokens[3]);

                    v_idx_tmp = new int[graph.v_size];
                    v_idx_tmp[0] = 0;
                    rev_v_idx_tmp = new int[graph.v_size];
                    rev_v_idx_tmp[0] = 0;
                    for(int i=1;i<graph.v_size;i++){
                        v_idx_tmp[i] = graph.vet_idx[i-1];
                        rev_v_idx_tmp[i] = graph.rev_vet_idx[i-1];
                    }
                } else {
                    throw new RuntimeException("[error] cannot find metadata in file.");
                }

                int e_num_read = 0;
                int e_self_loop = 0;
                while (s.hasNextLine()) {
                    String[] tokens = s.nextLine().split(" ");
                    assert tokens.length > 0;
                    assert tokens[0].equals("a");
                    int v_id = Integer.parseInt(tokens[1]);
                    int v_to = Integer.parseInt(tokens[2]);
                    int e_weight = Integer.parseInt(tokens[3]);

                    if(v_id == v_to) { e_self_loop++; continue; }
                    if(v_id!=0){
                        v_id--;
                        v_to--;
                        graph.edge_idx[v_idx_tmp[v_id]]=v_to;
                        graph.rev_edge_idx[rev_v_idx_tmp[v_to]]=v_id;
                        graph.edge_weight[v_idx_tmp[v_id]]=e_weight;
                        graph.edge_weight[rev_v_idx_tmp[v_to]]=e_weight;
                        v_idx_tmp[v_id]++;
                        rev_v_idx_tmp[v_to]++;
                    }
                    e_num_read++;
                    if(e_num_read == graph.e_size)
                        break;
                    if(e_num_read%1000000==0)
                        System.out.printf("%d \n", e_num_read);
                }
                System.out.printf("[info] Total number of edges: %d ::: self_loops = %d ::: e_num_read: %d\n", graph.e_size, e_self_loop, e_num_read);
            } finally {
                if (s != null) {
                    s.close();
                }
            }
        }

        private static void scanCsrIdx(Csr graph, String file) throws IOException {
            Scanner s = null;
            try {
                s = new Scanner(new BufferedReader(new FileReader(file)));

                // first line is metadata
                if (s.hasNextLine()) {
                    String[] tokens = s.nextLine().split(" ");
                    assert tokens.length > 0;
                    assert tokens[0].equals("p");
                    String str = tokens[1];
                    graph.v_size = Integer.parseInt(tokens[2]);
                    graph.e_size = Integer.parseInt(tokens[3]);

                    // indexes
                    graph.vet_idx = new int[graph.v_size];
                    graph.rev_vet_idx = new int[graph.v_size];
                    graph.vet_deg = new int[graph.v_size];
                    graph.vet_in_deg = new int[graph.v_size];
                    graph.vet_deg_reciprocal = new double[graph.v_size];

                    graph.edge_idx = new int[graph.e_size];
                    graph.edge_weight = new int[graph.e_size];

                    graph.vet_wr = new WeightRecip[graph.v_size];
                    for (int i = 0; i < graph.v_size; i++) {
                        graph.vet_wr[i] = new WeightRecip();
                        graph.vet_wr[i].recip = 0;
                        graph.vet_wr[i].weight = 0;
                    }

                    graph.rev_edge_idx = new int[graph.e_size];
                    graph.rev_edge_weight = new int[graph.e_size];

                    graph.vet_weight = new double[graph.v_size];
                    graph.vet_weight_back = new double[graph.v_size];

                    for(int i = 0; i < graph.v_size; i++){
                        graph.vet_deg[i] = 0;
                        graph.vet_in_deg[i] = 0;
                        graph.vet_idx[i] = 0;
                    }
                } else {
                    throw new RuntimeException("[error] cannot find metadata in file.");
                }

                int e_self_loop = 0;
                int e_num_read = 0;
                while (s.hasNextLine()) {
                    String[] tokens = s.nextLine().split(" ");
                    assert tokens.length > 0;
                    assert tokens[0].equals("a");
                    int v_id = Integer.parseInt(tokens[1]);
                    int v_to = Integer.parseInt(tokens[2]);
                    int e_weight = Integer.parseInt(tokens[3]);
                    if (v_id == v_to) {
                        e_self_loop++;
                        continue;
                    }
                    if (v_id != 0) {
                        v_id--;
                        v_to--;
                        graph.vet_deg[v_id]++;
                        graph.vet_in_deg[v_to]++;
                    }
                    e_num_read++;
                    if (e_num_read == graph.e_size) {
                        break;
                    }
                    if(e_num_read%100000==0) {
                        System.out.printf("%d \n", e_num_read);
                    }
                }
                int sum = 0;
                int rev_sum = 0;
                for(int i=0;i<graph.v_size;i++){
                    sum += graph.vet_deg[i];
                    rev_sum += graph.vet_in_deg[i];
                    graph.vet_deg_reciprocal[i] = 1.0 / (double)graph.vet_deg[i];
                    if(i==1) {
                        System.out.printf("the degree for vertex 1 is: %d", graph.vet_deg[i]);
                    }
                    //printf("Vertex: %d Reciprocal degree: %lf\n", i, graph.vet_deg_reciprocal[i]);
                    graph.vet_idx[i] = sum;
                    graph.rev_vet_idx[i] = rev_sum;
                }
                System.out.printf("[info] Total number of edges: %d ::: self_loops = %d ::: e_num_read: %d\n", graph.e_size, e_self_loop, e_num_read);
            } finally {
                if (s != null) {
                    s.close();
                }
            }
        }

        static class WeightRecip {
            double weight;
            double recip;
        }
    }

    public static void main(String[] args) throws IOException {
        String file = args[0];
        Csr graph = Csr.from(file);

        computePageRankCsr(graph);
        System.out.println("[info] done");
    }

    private static void computePageRankCsr(Csr graph) {
        boolean terminate = false;
        double rand_jump = RDM_JMP;
        double purpose_jump = 1 - RDM_JMP;
        int iter = 0;

        double start = System.currentTimeMillis();
        while (!terminate) {
           iter++;
            terminate = true;

            //#pragma omp parallel for num_threads(num_threads) shared(graph) schedule(guided,4096)
            for(int i=0;i<graph.v_size;i++){
                //graph.vet_weight_back[i]=0;
                for(int j=(i==0?0:graph.rev_vet_idx[i-1]); j<graph.rev_vet_idx[i]; j++){
                    int source = i;
                    int target = graph.rev_edge_idx[j];
                    //int target_2 = graph.rev_edge_idx[j+8];
                    //printf("source %d target %d pr target %f rp target %f\n", source, target, graph.vet_wr[target].weight, graph.vet_wr[target].recip);
                    graph.vet_weight_back[source]+= graph . vet_wr[target].weight * graph . vet_wr[target].recip;
                }
                graph.vet_weight_back[i] = rand_jump + purpose_jump*graph.vet_weight_back[i];
                if(Math.abs(graph.vet_weight_back[i]-graph.vet_wr[i].weight)>THRESH)
                    terminate = false;
                graph.vet_wr[i].weight = graph.vet_weight_back[i];
                //printf("%f %f ", graph.vet_wr[i].weight, 1.0/graph.vet_wr[i].recip);
                graph.vet_weight_back[i] = 0.0;
            }
        }

        double end = System.currentTimeMillis();
        System.out.printf("[info] Overall time = %f seconds\n", end - start);
        System.out.printf("[info] Iters = %d\n", iter);

        // todo: debug
        double sum = 0;
        for (int i = 0; i < graph.v_size; i++) {
            sum += graph.vet_wr[i].weight;
        }
        System.out.printf("[debug] sum = %f\n", sum);
    }
}
