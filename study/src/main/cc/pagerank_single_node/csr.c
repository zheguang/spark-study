#include "graph.h"
#include "immintrin.h"
#if 0
void read_graph_binary(t_csr *graph, char* file){
    FILE *stream;
	char str[100];
	int color=0;
	int gene=0;
	int gene_num=0;
	int v_num;
	int e_num;

	int v_id=0;
	int v_to=0;
	int e_weight=0;
	int current_v_id=0;
	int current_e_idx=0;

	int vet_idx_idx=0;
	int edge_vet_to_idx=0;
	int edge_weight_idx=0;
	int vet_id_idx=0;
	int i,j,sum=0, rev_sum=0;

	int *v_idx_tmp;
	int *rev_v_idx_tmp;
    struct Triple {
        int src; int dst; int weight;
    };

	if((stream=fopen(file,"rb"))==NULL)
		printf("the file you input does not exist!");
    fread(&v_num, sizeof(int), 1, fp);
    fread(&v_num, sizeof(int), 1, fp);
    fread(&e_num, sizeof(int), 1, fp);
    struct Triple * Tmp = (struct Triple*)_mm_malloc((sizeof(struct Triple)*e_num), 64);
    fread(Tmp, sizeof(struct Triple), e_num, fp);

	graph->v_size = v_num;
	graph->e_size = e_num;

	graph->vet_idx = (int*)_mm_malloc(sizeof(int)*v_num, 64);
	graph->rev_vet_idx = (int*)_mm_malloc(sizeof(int)*v_num, 64);
	graph->vet_deg = (int*)_mm_malloc(sizeof(int)*v_num, 64);
	graph->vet_in_deg = (int*)_mm_malloc(sizeof(int)*v_num, 64);
	graph->vet_deg_reciprocal = (double*)_mm_malloc(sizeof(double)*v_num, 64);
	graph->edge_idx = (int*)_mm_malloc(sizeof(int)*e_num, 64);
	graph->edge_weight = (int*)_mm_malloc(sizeof(int)*e_num, 64);
	graph->vet_wr = (t_wr*)_mm_malloc(sizeof(t_wr)*v_num, 64);
	graph->rev_edge_idx = (int*)_mm_malloc(sizeof(int)*e_num, 64);
	graph->rev_edge_weight = (int*)_mm_malloc(sizeof(int)*e_num, 64);
	graph->vet_weight = (double*)_mm_malloc(sizeof(double)*v_num, 64);
	graph->vet_weight_back = (double*)_mm_malloc(sizeof(double)*v_num, 64);

    for(i=0;i<v_num;i++){
		graph->vet_deg[i] = 0;
		graph->vet_in_deg[i] = 0;
		graph->vet_idx[i]=0;		
		graph->rev_vet_idx[i]=0;		
    }

    for(i=0; i< e_num; i++)
    {
        int v_id = Tmp[i].src;
        int v_to = Tmp[i].dst;
        int e_weight = Tmp[i].weight;
    
        v_id--; v_to--;
		graph->edge_idx[i]=v_to;
		graph->edge_weight[i]=e_weight;
        graph->vet_deg[v_id]++;
        graph->vet_in_deg[v_to]++;
    }

    
		        graph->rev_edge_idx[rev_v_idx_tmp[v_to]]=v_id;
				graph->edge_weight[rev_v_idx_tmp[v_to]]=e_weight;
    
	for(i=0;i<v_num;i++){
		sum += graph->vet_deg[i];
		rev_sum += graph->vet_in_deg[i];
		graph->vet_deg_reciprocal[i]=1.0/(double)graph->vet_deg[i];
		if(i==1)
			printf("the degree for vertex 1 is: %d", graph->vet_deg[i]);
		//printf("Vertex: %d Reciprocal degree: %lf\n", i, graph->vet_deg_reciprocal[i]);
		graph->vet_idx[i]=sum;
		graph->rev_vet_idx[i]=rev_sum;
    }
    
    if(v_id!=0){
				v_id--;
				v_to--;
				graph->edge_idx[v_idx_tmp[v_id]]=v_to;
				graph->rev_edge_idx[rev_v_idx_tmp[v_to]]=v_id;
				graph->edge_weight[v_idx_tmp[v_id]]=e_weight;
				graph->edge_weight[rev_v_idx_tmp[v_to]]=e_weight;
				v_idx_tmp[v_id]++;
				rev_v_idx_tmp[v_to]++;
			}


}
#endif

void read_graph_csr(t_csr *graph, char* file){
	FILE *stream;
	char str[100];
	int color=0;
	int gene=0;
	int gene_num=0;
	int v_num;
	int e_num;

	int v_id=0;
	int v_to=0;
	int e_weight=0;
	int current_v_id=0;
	int current_e_idx=0;

	int vet_idx_idx=0;
	int edge_vet_to_idx=0;
	int edge_weight_idx=0;
	int vet_id_idx=0;
	int i,j;

	int *v_idx_tmp;
	int *rev_v_idx_tmp;
	int e_num_read = 0;
	
	int e_self_loop = 0;

	if((stream=fopen(file,"r"))==NULL)
		printf("the file you input does not exist!");
	while(fscanf(stream, "%s", str) != EOF)
	{
		if(str[0]=='p' && str[1]=='\0'){
			fscanf(stream, "%s %d %d", str, &v_num, &e_num);
			v_idx_tmp = (int*) _mm_malloc(sizeof(int)*v_num, 64);
			v_idx_tmp[0] = 0;	
			rev_v_idx_tmp = (int*) _mm_malloc(sizeof(int)*v_num, 64);
			rev_v_idx_tmp[0] = 0;	
			for(i=1;i<v_num;i++){
				v_idx_tmp[i] = graph->vet_idx[i-1];
				rev_v_idx_tmp[i] = graph->rev_vet_idx[i-1];
			}
		}
		else if(str[0]=='a' && str[1]=='\0'){
			fscanf(stream, "%d %d %d",&v_id , &v_to, &e_weight);
#if 1
			if(v_id == v_to) { e_self_loop++; continue; }
			if(v_id!=0){
				v_id--;
				v_to--;
				graph->edge_idx[v_idx_tmp[v_id]]=v_to;
				graph->rev_edge_idx[rev_v_idx_tmp[v_to]]=v_id;
				graph->edge_weight[v_idx_tmp[v_id]]=e_weight;
				graph->edge_weight[rev_v_idx_tmp[v_to]]=e_weight;
				v_idx_tmp[v_id]++;
				rev_v_idx_tmp[v_to]++;
			}
#endif
			e_num_read++;
			if(e_num_read == e_num) 
				break;	
			if(e_num_read%1000000==0)
				printf("%d \n", e_num_read);
		}
	}
	_mm_free(v_idx_tmp);
	_mm_free(rev_v_idx_tmp);
        printf("Total number of edges: %d ::: self_loops = %d ::: e_num_read: %d\n", e_num, e_self_loop, e_num_read);
	fclose(stream);
}


void scan_csr_idx(t_csr *graph, char* file)
{
	FILE *stream;
	char str[100];
	int v_num;
	int e_num;

	int v_id=0;
	int v_to=0;
	int e_weight=0;
	int i,j,sum=0, rev_sum=0;
	int e_num_read = 0;
	
	int e_self_loop = 0;
	if((stream=fopen(file,"r"))==NULL)
		printf("the file you input does not exist!");
	while(fscanf(stream, "%s", str) != EOF)
	{
		if(str[0]=='p' && str[1]=='\0'){
			fscanf(stream, "%s %d %d", str, &v_num, &e_num);
			//printf("v_num: %d e_num: %d\n", v_num, e_num);
			graph->v_size = v_num;
			graph->e_size = e_num;
			graph->vet_idx = (int*)_mm_malloc(sizeof(int)*v_num, 64);
			graph->rev_vet_idx = (int*)_mm_malloc(sizeof(int)*v_num, 64);
			graph->vet_deg = (int*)_mm_malloc(sizeof(int)*v_num, 64);
			graph->vet_in_deg = (int*)_mm_malloc(sizeof(int)*v_num, 64);
			graph->vet_deg_reciprocal = (double*)_mm_malloc(sizeof(double)*v_num, 64);
			graph->edge_idx = (int*)_mm_malloc(sizeof(int)*e_num, 64);
			graph->edge_weight = (int*)_mm_malloc(sizeof(int)*e_num, 64);
			graph->vet_wr = (t_wr*)_mm_malloc(sizeof(t_wr)*v_num, 64);
			graph->rev_edge_idx = (int*)_mm_malloc(sizeof(int)*e_num, 64);
			graph->rev_edge_weight = (int*)_mm_malloc(sizeof(int)*e_num, 64);
			graph->vet_weight = (double*)_mm_malloc(sizeof(double)*v_num, 64);

			graph->vet_weight_back = (double*)_mm_malloc(sizeof(double)*v_num, 64);
			for(i=0;i<v_num;i++){
				graph->vet_deg[i] = 0;
				graph->vet_in_deg[i] = 0;
				graph->vet_idx[i]=0;		
			}
		}
		else if(str[0]=='a' && str[1]=='\0'){
			fscanf(stream, "%d %d %d",&v_id , &v_to, &e_weight);
			if(v_id == v_to) { e_self_loop++; continue; }
			//printf("%d %d %d\n",v_id , v_to, e_weight);
			if(v_id!=0){
				v_id--;
				v_to--;
				graph->vet_deg[v_id]++;		
				graph->vet_in_deg[v_to]++;		
				//printf("Vertex: %d Updating deg to : %d\n", v_id, graph->vet_deg[v_id]);
			}
			e_num_read++;
			if(e_num_read == e_num) 
				break;
			if(e_num_read%100000==0)
				printf("%d \n", e_num_read);
		}
	}
	for(i=0;i<v_num;i++){
		sum += graph->vet_deg[i];
		rev_sum += graph->vet_in_deg[i];
		graph->vet_deg_reciprocal[i]=1.0/(double)graph->vet_deg[i];
		if(i==1)
			printf("the degree for vertex 1 is: %d", graph->vet_deg[i]);
		//printf("Vertex: %d Reciprocal degree: %lf\n", i, graph->vet_deg_reciprocal[i]);
		graph->vet_idx[i]=sum;
		graph->rev_vet_idx[i]=rev_sum;
	}
        printf("Total number of edges: %d ::: self_loops = %d ::: e_num_read: %d\n", e_num, e_self_loop, e_num_read);
	fclose(stream);
}

void init_pagerank_csr(t_csr *graph){
	double max_sum=0;
	int i=0,j=0;
#pragma omp parallel for num_threads(num_threads) shared(graph) schedule(guided,4096)
	for(i=0; i<graph->v_size; i++){
		//for(; j<graph->vet_idx[i]; j++){
		//	graph->vet_weight[i]+=graph->edge_weight[j];	
		//}
		//graph->vet_weight[i]=1.0/(double)graph->v_size;
		graph->vet_weight[i]=1.0;
		graph->vet_weight_back[i]=0.0;
		graph->vet_wr[i].weight = 1.0;
		graph->vet_wr[i].recip=graph->vet_deg_reciprocal[i];
		//max_sum+=graph->vet_weight[i];
	}
	//for(i=0; i<graph->v_size; i++)
	//	graph->vet_weight[i] = graph->vet_weight[i]/max_sum;
}

void compute_pagerank_csr(t_csr *graph){
	int i=0,j=0;
	int terminate = FALSE;
	//double rand_jump = RDM_JMP/(double)graph->v_size;
	double rand_jump = RDM_JMP;
	double purpose_jump = 1-RDM_JMP;
	int iter=0;
#ifdef USE_OMP
//	omp_set_num_threads(num_threads);	
#endif
	double beg = omp_get_wtime();
	while(terminate  == FALSE){
		//printf("\n");
		iter++;
		terminate = TRUE;
#ifdef USE_OMP
#pragma omp parallel for num_threads(num_threads) shared(graph) schedule(guided,4096)
#endif
		for(i=0;i<graph->v_size;i++){
			//graph->vet_weight_back[i]=0;
			int j;
			for(j=(i==0?0:graph->rev_vet_idx[i-1]); j<graph->rev_vet_idx[i]; j++){
				int source = i;
				int target = graph->rev_edge_idx[j];
				int target_2 = graph->rev_edge_idx[j+8];
				_mm_prefetch((char *)(graph->vet_wr + target_2), _MM_HINT_T0);
				//printf("source %d target %d pr target %f rp target %f\n", source, target, graph->vet_wr[target].weight, graph->vet_wr[target].recip);
				graph->vet_weight_back[source]+=graph->vet_wr[target].weight*graph->vet_wr[target].recip;
			}
			graph->vet_weight_back[i] = rand_jump + purpose_jump*graph->vet_weight_back[i];
			if(fabs(graph->vet_weight_back[i]-graph->vet_wr[i].weight)>THRESH)
                                terminate = FALSE;
			graph->vet_wr[i].weight = graph->vet_weight_back[i];
			//printf("%f %f ", graph->vet_wr[i].weight, 1.0/graph->vet_wr[i].recip);
			graph->vet_weight_back[i] = 0.0;

		}
//#ifdef USE_DEBUG
		//for(i=0; i<10; i++)
		//	printf("%.6lf|%.6lf ", graph->vet_wr[i].weight, graph->vet_wr[i].recip);
		//printf("\n");
//#endif
#if 0
#pragma omp parallel for num_threads(num_threads) shared(graph) 
	for(i=0;i<graph->v_size;i++){
			graph->vet_weight_back[i] = rand_jump + purpose_jump*graph->vet_weight_back[i];
			if(fabs(graph->vet_weight_back[i]-graph->vet_wr[i].weight)>THRESH)
				terminate = FALSE;
#ifdef USE_DEBUG
			if( 0 /*(iter > 49) && (fabs(graph->vet_weight_back[i]-graph->vet_wr[i].weight)>THRESH)*/ )
			{
				printf("%d|%.6lf --> %.6lf ", i, graph->vet_wr[i].weight, graph->vet_weight_back[i]);
			}
#endif

			graph->vet_wr[i].weight = graph->vet_weight_back[i];
			//printf("%f %f ", graph->vet_wr[i].weight, 1.0/graph->vet_wr[i].recip);
			graph->vet_weight_back[i] = 0.0;
		}
#endif
		//printf("\n");
	}
	double end = omp_get_wtime();
	printf("Overall time = %lf seconds\n", (end-beg));
	printf("Iters = %d\n", iter);
	printf("Time/iter = %lf seconds\n", (end-beg)*1.0/iter);
#ifdef USE_DEBUG
        double sum = 0.;
	printf("Final pagerank values: \n");
	for(i=0;i<graph->v_size;i++){
			//printf("%lf ", graph->vet_wr[i].weight/graph->v_size);
			//printf("%.6lf ", graph->vet_wr[i].weight);
			sum += graph->vet_wr[i].weight;
	}
	
	//printf("\n");
	printf("sum = %.6lf\n", sum);
#endif
	//printf("iterations taken: %d\n", iter);
}

void print_pr_csr(t_csr *graph){
	int i;
	for(i=0;i<graph->v_size;i++)
		printf("%f ", graph->vet_weight[i]);
	printf("\n");
}

void vis_graph_csr(t_csr *graph)
{
	int idx=0;
	int vet;
	FILE *f;
	if((f = fopen("./vis/csr.vis", "w"))==NULL)
		printf("the file you input does not exist!");

	fprintf(f, "digraph G {\n");
	for(vet=0;vet<graph->v_size;vet++){
		for(; idx<graph->vet_idx[vet]; idx++){
			fprintf(f, "%d -> %d;\n", vet, graph->edge_idx[idx]);
		}
	}
	fprintf(f, "}\n");
	fclose(f);
}

