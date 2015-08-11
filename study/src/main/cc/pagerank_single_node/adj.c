#include "graph.h"

void read_graph_adj(t_adj *graph, char* file){
	
	FILE *stream;
	int i,j;
	char str[100];
	int v_num;
	int e_num;

	int v_id=0;
	int v_to=0;
	int e_weight=0;

	int *v_idx_tmp;

	if((stream=fopen(file,"r"))==NULL)
		printf("the file you input does not exist!");
	while(!feof(stream))
	{
		fscanf(stream, "%s", str);
		if(str[0]=='p' && str[1]=='\0'){
			fscanf(stream, "%s %d %d", str, &v_num, &e_num);
			v_idx_tmp = (int*)_mm_malloc(sizeof(int)*v_num, 64);
			for(i=0;i<v_num;i++)
				v_idx_tmp[i]=0;		
		}
		else if(str[0]=='a' && str[1]=='\0'){
			fscanf(stream, "%d %d %d",&v_id , &v_to, &e_weight);
			if(v_id!=0){
				v_id--;
				v_to--;
				graph->adj[v_id][v_idx_tmp[v_id]]=v_to;
				graph->edge_weight[v_id][v_idx_tmp[v_id]]=e_weight;
				v_idx_tmp[v_id]++;
			}
		}
	}
	_mm_free(v_idx_tmp);
	fclose(stream);
}


void scan_adj_size(t_adj *graph, char* file)
{
	FILE *stream;
	char str[100];
	int v_num;
	int e_num;

	int v_id=0;
	int v_to=0;
	int e_weight=0;
	int i,j,sum=0;


	if((stream=fopen(file,"r"))==NULL)
		printf("the file you input does not exist!");
	while(!feof(stream))
	{
		fscanf(stream, "%s", str); 
		if(str[0]=='p' && str[1]=='\0'){
			fscanf(stream, "%s %d %d", str, &v_num, &e_num);
			graph->v_size = v_num;
			graph->e_size = 0;
			graph->vet_deg = (int*)_mm_malloc(sizeof(int)*v_num, 64);
			graph->vet_deg_reciprocal = (double*)_mm_malloc(sizeof(double)*v_num, 64);
		}
		else if(str[0]=='a' && str[1]=='\0'){
			fscanf(stream, "%d %d %d",&v_id , &v_to, &e_weight);
			if(v_id!=0){
				v_id-=1;
				v_to-=1;
				graph->vet_deg[v_id]++;	
				graph->e_size++;
			}	
		}
	}
	graph->adj = (int**)_mm_malloc(sizeof(int*)*v_num, 64);
	graph->edge_weight = (int**)_mm_malloc(sizeof(int*)*v_num, 64);
	graph->vet_weight = (double*)_mm_malloc(sizeof(double)*v_num, 64);
	graph->vet_weight_back = (double*)_mm_malloc(sizeof(double)*v_num, 64);

	for(i=0;i<v_num;i++){
		graph->adj[i] = (int*)_mm_malloc(sizeof(int)*graph->vet_deg[i], 64);
		graph->edge_weight[i] = (int*)_mm_malloc(sizeof(int)*graph->vet_deg[i], 64);
	}
	for(i=0;i<graph->v_size;i++){
		sum += graph->vet_deg[i];
		graph->vet_deg_reciprocal[i]=1.0/(double)graph->vet_deg[i];
	}
	fclose(stream);
}

void init_pagerank_adj(t_adj *graph){
	double max_sum=0;
	int i=0,j=0;
	for(i=0; i<graph->v_size; i++){
		//for(j=0; j<graph->vet_deg[i]; j++){
		//	graph->vet_weight[i]+=graph->edge_weight[i][j];	
		//}
		//graph->vet_weight[i]=1.0/(double)graph->v_size;
		graph->vet_weight[i]=1.0;
		//if(graph->vet_weight[i]>max_sum)
		//	max_sum=graph->vet_weight[i];
	}
	//for(i=0; i<graph->v_size; i++)
	//	graph->vet_weight[i] = graph->vet_weight[i]/max_sum;
}

void compute_pagerank_adj(t_adj *graph){
	int i=0,j=0;
	int terminate = FALSE;
	double rand_jump = RDM_JMP/(double)graph->v_size;
	double purpose_jump = 1-RDM_JMP;
	int iter_count=0;
	while(terminate  == FALSE){
		iter_count++;
		terminate = TRUE;
		for(i=0;i<graph->v_size;i++){
			graph->vet_weight_back[i]=0;
			for(j=0; j<graph->vet_deg[i]; j++){
				if(graph->vet_deg[graph->adj[i][j]]>0)
				graph->vet_weight_back[i]+=graph->vet_weight[graph->adj[i][j]]*graph->vet_deg_reciprocal[graph->adj[i][j]];
			}
			graph->vet_weight_back[i] = rand_jump + purpose_jump*graph->vet_weight_back[i];
			if(fabs(graph->vet_weight_back[i]-graph->vet_weight[i])>THRESH)
				terminate = FALSE;
		}
		for(i=0;i<graph->v_size;i++){
			graph->vet_weight[i]=graph->vet_weight_back[i];
		}
	}
	printf("num iter %d\n", iter_count);
}

void print_pr_adj(t_adj *graph){
	int i;
	for(i=0;i<graph->v_size;i++)
		printf("%f ", graph->vet_weight[i]);
	printf("\n");
}

void vis_graph_adj(t_adj *graph)
{
	int idx=0;
	int vet;
	FILE *f;
	if((f=fopen("./vis/adj.vis", "w"))==NULL)
		printf("the file you input does not exist!");
	fprintf(f, "digraph G {\n");
	for(vet=0; vet<graph->v_size; vet++){
		for(idx=0; idx<graph->vet_deg[vet]; idx++){
			fprintf(f, "%d -> %d;\n", vet, graph->adj[vet][idx]);
		}
	}
	fprintf(f, "}\n");
	fclose(f);
}

