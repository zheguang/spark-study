#include "./graph.h"
#include <unistd.h>
#include <time.h>
#include <sys/time.h>
//#include "ittnotify.h"

static clockid_t clockid;
static double last_tic = -1.0;
double toc (void);
void tic (void);
double timer (void);
int num_threads = 1;

int main(int argc, char *argv[])
{
  	//__itt_pause();
	int c;
	int adj = 0;
	int csr = 0;
	char *file;
	double time=0;
	double start=0, end=0;


	while ((c = getopt (argc, argv, "acp:f:")) != -1)
		switch (c)
		{
			case 'a':
				adj = 1;
				break;
			case 'c':
				csr = 1;
				break;
			case 'f':
				file = optarg;
				break;
			case 'p':
				num_threads = atoi(optarg);
				break;
			case '?':
				fprintf (stderr,
						"Unknown option character `\\x%x'.\n",
						optopt);
				return 1;
			default:
				abort ();
		}
	if(adj==1)
	{
		t_adj * graph = (t_adj*)malloc(sizeof(t_adj));
		scan_adj_size(graph, file);
		read_graph_adj(graph, file);
		tic();
		init_pagerank_adj(graph);
		//print_pr_adj(graph);
		compute_pagerank_adj(graph);
		//print_pr_adj(graph);
		//vis_graph_adj(graph);
		end = toc();
	}
	else if(csr==1)
	{
		t_csr * graph = (t_csr*)malloc(sizeof(t_csr));
		scan_csr_idx(graph, file);
		printf("finished scan\n");
		read_graph_csr(graph, file);
		printf("finished read\n");
		init_pagerank_csr(graph);
		printf("finished init\n");
		//print_pr_csr(graph);
		tic();
  		//__itt_resume();
		compute_pagerank_csr(graph);
  		//__itt_pause();
		printf("finished compute\n");
		//print_pr_csr(graph);
		//vis_graph_csr(graph);
		end = toc();
	}
	
	time = (end-start);
	printf("page rank time is %f seconds.\n", time);
	return 0;

}

double
timer (void)
{
  struct timespec tp;
  clock_gettime (clockid, &tp);
  clock_gettime (clockid, &tp);
  return (double) tp.tv_sec + 1.0e-9 * (double) tp.tv_nsec;
}


void
tic (void)
{
  last_tic = timer ();
}

double
toc (void)
{
  const double t = timer ();
  const double out = t - last_tic;
  last_tic = t;
  return out;
}
