
    /**  
 * Copyright (c) 2009 Carnegie Mellon University. 
 *     All rights reserved.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an "AS
 *  IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 *  express or implied.  See the License for the specific language
 *  governing permissions and limitations under the License.
 *
 * For more about this software visit:
 *
 *      http://www.graphlab.ml.cmu.edu
 *
 */

#include <mpi.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <math.h>
#include <algorithm>
#include <vector>
#include <set>
#include <omp.h>

typedef struct {
    int user;
    int movie;
    int rating;
} edge;

// const unsigned int num_user_movie_rating = 121061948;
const unsigned int num_user_movie_rating_test = 2468649;

//scale 23, nnodes = 8
const unsigned int num_users = 7952745;
const unsigned int num_movies = 167772;
const unsigned int num_user_movie_ratings[8] = {262526372, 261164267, 261562366, 260667535, 261491885, 262324829, 262254168, 260864485};
int users_starting_offsets[8] = {0, 994134, 1988332, 2982023, 3976012, 4970223, 5964466, 6958733 };
int users_ending_offsets[8] = {994134, 1988332, 2982023, 3976012, 4970223, 5964466, 6958733, 7952745 };

const unsigned int NLATENT = 20;
const double MAXVAL = 1e+100;
const double MINVAL = -1e+100;
const double LAMBDA = 0.001;
double GAMMA = 0.001;
const double STEP_DEC = 0.9;
const unsigned int max_iter = 5; //5;
const double cpu_freq = 2.7e9;
int num_nodes; //  = 1;
int node_id;
const unsigned int num_procs = 40;


inline
double dotP(const double *source1, const double *source2) 
{
    double result=0;
    for (size_t i = 0; i < NLATENT; ++i)
        result += source1[i] * source2[i];

    return result;
}


void Initialize_MPI(int argc, char **argv)
{

    MPI_Status stat;
    int provided;
    MPI_Init_thread(&argc, &argv, MPI_THREAD_MULTIPLE, &provided); /*START MPI */
    MPI_Comm_rank(MPI_COMM_WORLD, &node_id); /*DETERMINE RANK OF THIS PROCESSOR*/
    MPI_Comm_size(MPI_COMM_WORLD, &num_nodes); /*DETERMINE TOTAL NUMBER OF PROCESSORS*/
    MPI_Comm_set_errhandler(MPI_COMM_WORLD,MPI_ERRORS_ARE_FATAL);
}

void Finalize_MPI(void)
{
    MPI_Finalize();
}

int main(int argc, char* argv[]) {

    Initialize_MPI(argc, argv);
    printf("MPI initialized\n");
    fflush(stdout);

    FILE *fp;
    //fp = fopen("sgd_datagen/Rating_S19_s_train", "ro");
    //printf("File opened\n");
    fflush(stdout);

    // unsigned int num_user_movie_rating = 121061948;
    unsigned int num_user_movie_rating;
    char filename[100];
    sprintf(filename, "sgd_datagen/Rating_S23.%d_%d", num_nodes, node_id);
    fp = fopen(filename, "ro");
    num_user_movie_rating = num_user_movie_ratings[node_id];
29900509;
    // else
        // exit(1);

    edge *user_movie_ratings;
    user_movie_ratings = (edge *) malloc(num_user_movie_rating * sizeof(edge));

    // Read in data
    unsigned long long tbegin, tend;
    unsigned long long compute_tbegin, compute_tend;
    unsigned long long comm_tbegin, comm_tend;
    unsigned long long compute_time, comm_time;

    tbegin = __rdtsc();
    for (size_t i = 0; i < num_user_movie_rating; ++i)
        fscanf(fp, "%d %d %d\n", &(user_movie_ratings[i].user),
               &(user_movie_ratings[i].movie), 
               &(user_movie_ratings[i].rating));
    tend = __rdtsc();
    printf("Time in data read %f (ms)\n",  ((tend - tbegin)/cpu_freq) * 1000);

    int * movies_starting_offsets = (int *)malloc(sizeof(int)*num_nodes);
    int * movies_ending_offsets = (int *)malloc(sizeof(int)*num_nodes);

    // exit(1);


#if 0
    // DEBUG: dump output to check if we read it correctly
    for (size_t i = 0; i < num_user_movie_rating; ++i)
        printf("%d %d  %d\n", (user_movie_ratings[i].user),
               (user_movie_ratings[i].movie), 
               (user_movie_ratings[i].rating));
#endif
   
 
    fclose(fp);

    // These are 2D matrices - num users/num movies x NLATENT
    double *U_mat; // Users in latent space
    double *V_mat; // Movies in latent space
    double *U_mat_new; // Users in latent space
    double *V_mat_new; // Movies in latent space
 
    U_mat = (double *) malloc(NLATENT * num_users * sizeof(double));
    V_mat = (double *) malloc(NLATENT * num_movies * sizeof(double));
    U_mat_new = (double *) malloc(NLATENT * num_users * sizeof(double));
    V_mat_new = (double *) malloc(NLATENT * num_movies * sizeof(double));

#if 0
    omp_lock_t *U_lock;
    omp_lock_t *V_lock;

    U_lock = (omp_lock_t *) malloc(NLATENT * num_users * sizeof(omp_lock_t));
    V_lock = (omp_lock_t *) malloc(NLATENT * num_movies * sizeof(omp_lock_t));
#endif

    std::srand(4562727);

    tbegin = __rdtsc();
    // Generate random numbers between -1 and 1 just like Eigen's setRandom()
    for (size_t i = 0; i < num_users; ++i)
    {
        // omp_init_lock(&(U_lock[i]));
        for (size_t j = 0; j < NLATENT; ++j)
            U_mat[i*NLATENT + j] = (-1) + 2 * (std::rand()/float(RAND_MAX));
    }

    for (size_t i = 0; i < num_movies; ++i)
    {
        // omp_init_lock(&(V_lock[i]));
        for (size_t j = 0; j < NLATENT; ++j)
            V_mat[i*NLATENT + j] = (-1) + 2 * (std::rand()/float(RAND_MAX));
    }
    tend = __rdtsc();

    printf("Time in U-V mat init %f (ms)\n",  ((tend - tbegin)/cpu_freq) * 1000);

    // Sepearate edges into tiles. Each tile is a vector which
    // stores the edge ids (indices in the user_movie_ratings array)
    // that belong to it
    std::vector<std::vector<unsigned int> > 
        tiles(num_procs * num_nodes * num_procs);

#if 0
    std::vector<int> pi_row(num_users);
    std::vector<int> pi_col(num_movies);

    for (size_t i = 0; i < pi_row.size(); ++i)
        pi_row[i] = i;

    for (size_t i = 0; i < pi_col.size(); ++i)
        pi_col[i] = i;

    // printf("Hello1\n");
    // Now shuffle values in both pi_row and pi_col vectors
    for (size_t i = 0; i < (pi_row.size()-1); ++i)
    {
        const size_t last_idx = pi_row.size()-1;
        const size_t first_idx = i+1;
        const int length = last_idx - first_idx + 1;

        const int random_idx = rand() % length;

        std::swap(pi_row[i], pi_row[i+random_idx+1]);
    }

    // printf("Hello2\n");
    for (size_t i = 0; i < (pi_col.size()-1); ++i)
    {
        const size_t last_idx = pi_col.size()-1;
        const size_t first_idx = i+1;
        const int length = last_idx - first_idx + 1;

        const int random_idx = rand() % length;

        std::swap(pi_col[i], pi_col[i+random_idx+1]);
    }
   
    // Random shuffle doesn't yet work with MPI
// #ifdef RANDOM_SHUFFLE
    edge *user_movie_ratings_s;
    user_movie_ratings_s = (edge *) malloc(num_user_movie_rating * sizeof(edge));

    for (size_t i = 0; i < num_user_movie_rating; ++i)
    {
        const unsigned int user_id = user_movie_ratings[i].user;
        const unsigned int movie_id = user_movie_ratings[i].movie;

        const unsigned int new_user_id = pi_row[user_id-1] + 1;
        const unsigned int new_movie_id = pi_col[movie_id-1] + 1;

        user_movie_ratings_s[i].user = new_user_id;
        user_movie_ratings_s[i].movie = new_movie_id;
        user_movie_ratings_s[i].rating = user_movie_ratings[i].rating;
    }
    free(user_movie_ratings);
    user_movie_ratings = user_movie_ratings_s;
#endif

    // const int num_users_in_tile = int(floor(num_users / float(num_nodes * num_procs)));
    const int num_users_in_tile = int(floor(num_users / float(1 * num_procs)));
    const int num_movies_in_tile = int(floor(num_movies / float(num_nodes * num_procs)));


    for(size_t i = 0; i < num_nodes; i++)
    {
        // users_starting_offsets[i] = num_users_in_tile * num_procs *i;
        // users_ending_offsets[i] = users_starting_offsets[i] + num_users_in_tile * num_procs;
        // if(i == (num_nodes-1)) users_ending_offsets[i] = num_users;
        movies_starting_offsets[i] = num_movies_in_tile * num_procs *i;
        movies_ending_offsets[i] = movies_starting_offsets[i] + num_movies_in_tile * num_procs;
        if(i == (num_nodes-1)) movies_ending_offsets[i] = num_movies;

        // printf("%d %d\n", users_starting_offsets[i], users_ending_offsets[i]);
    }

    for (size_t i = 0; i < num_user_movie_rating; ++i)
    {
        // const unsigned int user_id = user_movie_ratings[i].user;
        // const unsigned int movie_id = user_movie_ratings[i].movie;

        const unsigned int user_id = 
            user_movie_ratings[i].user - users_starting_offsets[node_id];
	//if(user_id < 1) { printf("node: %d ::: user_id: %d -- ERROR\n", node_id, user_id); fflush(stdout);}
        const unsigned int movie_id = user_movie_ratings[i].movie;

        const int tile_x =
            std::min(int(floor((user_id - 1) / float(num_users_in_tile))), int(1 * num_procs - 1));
            // std::min(int(floor((user_id - 1) / float(num_users_in_tile))), int(num_nodes * num_procs - 1));
        const int tile_y =
            std::min(int(floor((movie_id - 1) / float(num_movies_in_tile))),int(num_nodes * num_procs - 1));
        // if((tile_x * num_nodes + tile_y) > ((num_nodes * num_nodes)-1))
        //             // printf("%d %d\n", tile_x, tile_y);
        tiles[tile_x * (num_nodes * num_procs) + tile_y].push_back(i);
	if(tile_x < 0 || tile_x >= num_procs) { printf("ERROR::: Node: %d ::: tile_x: %d num_procs: %d\n", node_id, tile_x, num_procs); }
     }
     // printf("Length %ld\n", tiles.size());

    // Print some stats about how many ratings in each tile
#if 0
    // for (size_t i = 0; i < (num_nodes * num_procs); ++i)
    for (size_t i = 0; i < (1 * num_procs); ++i)
        for (size_t j = 0; j < (num_nodes * num_procs); ++j)
            printf("tile (%ld, %ld): %ld, %f\n", i, j, 
                   tiles[i * (num_nodes * num_procs) + j].size(),
                   (tiles[i * (num_nodes * num_procs) + j].size()/float(num_user_movie_rating)) * 100);

    // exit(1);
#endif
    MPI_Barrier(MPI_COMM_WORLD);
    omp_set_num_threads(num_procs);
    for (size_t itr = 0; itr < max_iter; itr++)
    {
     printf("iteration %ld\n", itr);
    tbegin = __rdtsc();
    compute_time = comm_time = 0;
    for (size_t l = 0; l < num_nodes; ++l)
    {
        
        // int row = 0;
        int col = l;
        // printf("node step %ld\n", l);

// #ifdef DEBUG
#if 0
        std::vector<std::set<int> > u_t(num_nodes);
        std::vector<std::set<int> > m_t(num_nodes);
#endif

        // Geneate the tile ids outside the loop 
        // Makes parallelization easier
        // int rows[num_nodes];
        int cols[num_nodes];

        // rows[0] = row;
        cols[0] = col;
        
        for (size_t k = 1; k < num_nodes; ++k)
        {
            // row = (++row) % num_nodes;
            col = (++col) % num_nodes;
            // rows[k] = row;
            cols[k] = col;
        }

        // for (size_t k = 0; k < num_nodes; ++k)
            // printf("%d %d\n", node_id, cols[k]);
         

        // This is the loop to be parallelized over all the nodes
        // #pragma omp parallel for
        // for (size_t k = 0; k < num_nodes; ++k)
        size_t k = node_id;
        {
            compute_tbegin = __rdtsc();
            for(size_t pidx1 = 0; pidx1 < num_procs; ++pidx1) 
            {
// #ifdef DEBUG
#if 0
                std::vector<std::set<int> > u_tn(num_procs);
                std::vector<std::set<int> > m_tn(num_procs);
#endif
                int rowp = 0;
                int colp = pidx1;

                int rowsp[num_procs];
                int colsp[num_procs];

                rowsp[0] = rowp;
                colsp[0] = colp;
        
                for (size_t idx = 1; idx < num_procs; ++idx)
                {
                    rowp = (++rowp) % num_procs;
                    colp = (++colp) % num_procs;
                    rowsp[idx] = rowp;
                    colsp[idx] = colp;
                }

		//printf("Node: %d pidx1: %d ::: says HI\n", node_id, pidx1, num_procs); fflush(stdout);
                // This loop needs to be parallelized ovre cores
                #pragma omp parallel for
                for(size_t pidx2 = 0; pidx2 < num_procs; ++pidx2) 
                {
                // printf("Threads %d\n", omp_get_num_threads());
                    //assert((cols[k] * num_procs + 
                    //        rowsp[pidx2] * (num_procs * num_nodes) + 
                    //        colsp[pidx2]) < (num_procs * num_nodes * num_procs));
                    // printf("%d %d\n", node_id, (cols[k] * num_procs + 
                            // rowsp[pidx2] * (num_procs * num_nodes) + 
                            // colsp[pidx2]) );
                    std::vector<unsigned int> &v = 
                    tiles[/*rows[k] * num_procs * num_nodes * num_procs +*/
                          cols[k] * num_procs +
                          rowsp[pidx2] * (num_procs * num_nodes) + 
                          colsp[pidx2]];

                    // printf("%d %d %d %d %d\n",
                           // rows[k], cols[k], rowsp[pidx2], colsp[pidx2],
                           // rows[k] * num_procs * num_nodes * num_procs +
                           // cols[k] * num_procs +
                           // rowsp[pidx2] * (num_procs * num_nodes) + 
                           // colsp[pidx2]);
                           

#if 1
                    for(size_t idx = 0; idx < v.size(); ++idx)
                    {
                        const unsigned int i = v[idx];            
                        int user_id = user_movie_ratings[i].user;
                        int movie_id = user_movie_ratings[i].movie;

// #ifdef DEBUG
#if 0
                        u_t[k].insert(user_id);
                        m_t[k].insert(movie_id);
                        u_tn[pidx2].insert(user_id);
                        m_tn[pidx2].insert(movie_id);
#endif


                        double pred = dotP(&(U_mat[(user_id-1) * NLATENT]), 
                                           &(V_mat[(movie_id-1) * NLATENT]));
  
            // Truncate pred
                        pred = std::min(MAXVAL, pred);
                        pred = std::max(MINVAL, pred);

                        const float err = (pred - user_movie_ratings[i].rating);
        
                        for (size_t j = 0; j < NLATENT; ++j)
                            U_mat_new[(user_id-1) * NLATENT + j] +=
                                -GAMMA * (err*V_mat[(movie_id-1) * NLATENT + j] + 
                                          LAMBDA * U_mat[(user_id-1) * NLATENT + j]);

                        for (size_t j = 0; j < NLATENT; ++j)
                            V_mat_new[(movie_id-1) * NLATENT + j] +=
                                -GAMMA * (err*U_mat[(user_id-1) * NLATENT + j] + 
                                          LAMBDA * V_mat[(movie_id-1) * NLATENT + j]);
                    }
#endif

                }
		//printf("Node: %d says HI2\n", node_id); fflush(stdout);
// #ifdef DEBUG
#if 0
                for (size_t i1 = 0; i1 < (num_procs-1); ++i1)
                    for (size_t i2 = i1+1; i2 < num_procs; ++i2)
                {
                    std::set<int> s;
                    std::set_intersection(u_tn[i1].begin(), u_tn[i1].end(),
                                          u_tn[i2].begin(), u_tn[i2].end(),
                                          std::inserter(s, s.begin()));
                    assert(s.size() == 0);

                    std::set_intersection(m_tn[i1].begin(), m_tn[i1].end(),
                                          m_tn[i2].begin(), m_tn[i2].end(),
                                          std::inserter(s, s.begin()));
                    assert(s.size() == 0);
                }
#endif
            }
            compute_tend = __rdtsc();
            compute_time += compute_tend - compute_tbegin;

            comm_tbegin = __rdtsc();
            for(int n = 0; n < num_nodes; n++)
            {
                // MPI_Bcast(U_mat + users_starting_offsets[rows[n]]*NLATENT, NLATENT*(users_ending_offsets[rows[n]] - users_starting_offsets[rows[n]]), MPI_DOUBLE, n, MPI_COMM_WORLD);
                MPI_Bcast(V_mat + movies_starting_offsets[cols[n]]*NLATENT, NLATENT*(movies_ending_offsets[cols[n]] - movies_starting_offsets[cols[n]]), MPI_DOUBLE, n, MPI_COMM_WORLD);
            }
            comm_tend = __rdtsc();
            comm_time += comm_tend - comm_tbegin;
        }

// #ifdef DEBUG
#if 0
        for (size_t i1 = 0; i1 < (num_nodes-1); ++i1)
            for (size_t i2 = i1+1; i2 < num_nodes; ++i2)
            {
                std::set<int> s;
                std::set_intersection(u_t[i1].begin(), u_t[i1].end(),
                                      u_t[i2].begin(), u_t[i2].end(),
                                      std::inserter(s, s.begin()));
                assert(s.size() == 0);

                std::set_intersection(m_t[i1].begin(), m_t[i1].end(),
                                      m_t[i2].begin(), m_t[i2].end(),
                                      std::inserter(s, s.begin()));
                assert(s.size() == 0);
            }
#endif

    }
    GAMMA *= STEP_DEC;
    tend = __rdtsc();
    printf("Compute time in iteration %ld of node id %d is %f (ms) \n", itr, node_id, ((compute_time)/cpu_freq)* 1000);
    printf("Comm time in iteration %ld of node id %d is %f (ms) \n", itr, node_id, ((comm_time)/cpu_freq)* 1000);
    printf("Total time in iteration %ld of node id %d is %f (ms) \n", itr, node_id, ((tend - tbegin)/cpu_freq)* 1000);
    }


    // exit(1);
#if 1
    for(int n = 0; n < num_nodes; n++)
    {
        MPI_Bcast(U_mat + users_starting_offsets[n]*NLATENT, NLATENT*(users_ending_offsets[n] - users_starting_offsets[n]), MPI_DOUBLE, n, MPI_COMM_WORLD);
    }
#endif
 
    // Calculate training error
    double train_err = 0;
#if 1
    for (size_t i = 0; i < num_user_movie_rating; ++i)
    {
        int user_id = user_movie_ratings[i].user;
        int movie_id = user_movie_ratings[i].movie;

        double pred = dotP(&(U_mat[(user_id-1) * NLATENT]), 
                           &(V_mat[(movie_id-1) * NLATENT]));
  
        // Truncate pred
        pred = std::min(MAXVAL, pred);
        pred = std::max(MINVAL, pred);

        const float rmse = (pred - user_movie_ratings[i].rating)*
                           (pred - user_movie_ratings[i].rating);
  
        train_err += rmse;
    }
    train_err = sqrt(train_err/num_user_movie_rating);
    printf("Training rmse %f\n", train_err);
#endif

    // Now calculate test error
    fp = fopen("sgd_datagen/Rating_S19_s_test", "ro");

    edge *user_movie_ratings_test;
    user_movie_ratings_test = (edge *) malloc(num_user_movie_rating_test * sizeof(edge));
    // Read in data
    tbegin = __rdtsc();
    for (size_t i = 0; i < num_user_movie_rating_test; ++i)
        fscanf(fp, "%d %d %d\n", &(user_movie_ratings_test[i].user),
               &(user_movie_ratings_test[i].movie), 
               &(user_movie_ratings_test[i].rating));
    tend = __rdtsc();
    printf("Time in test data read %f (ms)\n",  ((tend - tbegin)/cpu_freq) * 1000);

// #ifdef RANDOM_SHUFFLE
#if 0
    edge *user_movie_ratings_test_s;
    user_movie_ratings_test_s = (edge *) malloc(num_user_movie_rating_test * sizeof(edge));

    for (size_t i = 0; i < num_user_movie_rating_test; ++i)
    {
        const unsigned int user_id = user_movie_ratings_test[i].user;
        const unsigned int movie_id = user_movie_ratings_test[i].movie;

        const unsigned int new_user_id = pi_row[user_id-1] + 1;
        const unsigned int new_movie_id = pi_col[movie_id-1] + 1;

        user_movie_ratings_test_s[i].user = new_user_id;
        user_movie_ratings_test_s[i].movie = new_movie_id;
        user_movie_ratings_test_s[i].rating = user_movie_ratings_test[i].rating;
    }
    free(user_movie_ratings_test);
    user_movie_ratings_test = user_movie_ratings_test_s;
#endif

    // Calculate test error
    double test_err = 0;
    for (size_t i = 0; i < num_user_movie_rating_test; ++i)
    {
        int user_id = user_movie_ratings_test[i].user;
        int movie_id = user_movie_ratings_test[i].movie;

        double pred = dotP(&(U_mat[(user_id-1) * NLATENT]), 
                           &(V_mat[(movie_id-1) * NLATENT]));
  
        // Truncate pred
        pred = std::min(MAXVAL, pred);
        pred = std::max(MINVAL, pred);

        // printf("%d, %d, %f, %d\n", user_id, movie_id, pred, 
        //       user_movie_ratings_test[i].rating);
        const float rmse = (pred - user_movie_ratings_test[i].rating)*
                           (pred - user_movie_ratings_test[i].rating);
  
        test_err += rmse;
    }
    test_err = sqrt(test_err/num_user_movie_rating_test);
    printf("Test rmse %f\n", test_err);
    

    // Free memory
    free(user_movie_ratings);
    free(user_movie_ratings_test);
    free(U_mat);      
    free(V_mat); 

#ifndef RANDOM_SHUFFLE
    free(users_starting_offsets);
    free(users_ending_offsets);
    free(movies_starting_offsets);
    free(movies_ending_offsets);
#endif

    // free(U_lock);      
    // free(V_lock); 
    Finalize_MPI();
}




