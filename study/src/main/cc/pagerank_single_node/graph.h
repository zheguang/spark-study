#pragma once

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <omp.h>

#ifndef _H_GRAPH
#define _H_GRAPH

#define FALSE 0
#define TRUE 1
#define RDM_JMP 0.3
#define THRESH 0.000001

extern int num_threads;

struct weight_recip
{
	double weight;
	double recip;
};
typedef struct weight_recip t_wr;
typedef struct weight_recip *p_wr;

struct CSR
{
	int *edge_idx;
	int *edge_weight;
	t_wr *vet_wr;	
	int *rev_edge_idx;
	int *rev_edge_weight;
	int *vet_idx;
	int *rev_vet_idx;
	int *vet_deg;
	int *vet_in_deg;
	double *vet_deg_reciprocal;
	double *vet_weight;
	double *vet_weight_back;

	int v_size;
	int e_size;
};
typedef struct CSR t_csr;
typedef struct CSR *p_csr;


struct ADJ 
{
	int **adj;
	int **edge_weight;
	int **rev_adj;
	int **rev_edge_weight;
	double *vet_deg_reciprocal;
	double *vet_weight;
	double *vet_weight_back;
	int *vet_deg;
	int v_size;
	int e_size;
};
typedef struct ADJ t_adj;
typedef struct ADJ *p_adj;

void read_graph_csr(t_csr *graph, char* file);
void scan_csr_idx(t_csr *graph, char* file);
void init_pagerank_csr(t_csr *graph);
void compute_pagerank_csr(t_csr *graph);
void print_pr_csr(t_csr *graph);
void vis_graph_csr(t_csr *graph);

void read_graph_adj(t_adj *graph, char* file);
void scan_adj_size(t_adj *graph, char* file);
void init_pagerank_adj(t_adj *graph);
void compute_pagerank_adj(t_adj *graph);
void print_pr_adj(t_adj *graph);
void vis_graph_adj(t_adj *graph);
#endif
