
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

#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <math.h>
#include <algorithm>
#include <vector>
#include <set>
#include <omp.h>

#ifdef __GNUC__
#include "rdtsc.h"
#endif

#ifdef BLAS
#include <mkl.h>
#endif

#include "utils.h"

typedef struct {
    int user;
    int movie;
    int rating;
} edge;

unsigned int num_user_movie_rating = 99072112;
unsigned int num_users = 480189;
unsigned int num_movies = 17770;
#ifdef LATENT
const unsigned int NLATENT = LATENT;
#else
const unsigned int NLATENT = 20;
#endif
const double MAXVAL = 1e+100;
const double MINVAL = -1e+100;
const double LAMBDA = 0.001;
double GAMMA = 0.001;
const double STEP_DEC = 0.9;
const unsigned int max_iter = 5;
const double cpu_freq = 2.7e9;
const unsigned int num_nodes = 1;
unsigned int num_procs = 24;

const unsigned int num_user_movie_rating_test = 1408395;

inline
double dotP(const double *source1, const double *source2) 
{
    double result=0;
#ifdef BLAS
    result += cblas_ddot(NLATENT, source1, 1, source2, 1);
#else
    for (size_t i = 0; i < NLATENT; ++i) {
        result += source1[i] * source2[i];
    }
#endif

    return result;
}


int main(int argc, char** argv) {

    if(argc < 6)
    {
        printf("Syntax: %s <filename> <nusers> <nmovies> <nratings> <nthreads>\n", argv[0]);
        exit(123);
    }

    FILE *fp;
    fp = fopen(argv[1], "ro");

    num_users = atoi(argv[2]);
    num_movies = atoi(argv[3]);
    num_user_movie_rating = atoi(argv[4]);
    num_procs = atoi(argv[5]);

#ifdef BLAS
    printf("algebra_mode=BLAS\n");
#else
    printf("algebra_mode=CPP\n");
#endif
    printf("nlatent=%d\n", NLATENT);
    printf("filename=%s\n", argv[1]);
    printf("num_users=%d\n", num_users);
    printf("num_movies=%d\n", num_movies);
    printf("num_user_movie_rating=%d\n", num_user_movie_rating);
    printf("num_procs=%d\n", num_procs);
    printf("num_nodes=%d\n", num_nodes);

    edge *user_movie_ratings;
    user_movie_ratings = (edge *) malloc(num_user_movie_rating * sizeof(edge));

    // Read in data
    unsigned long long tbegin, tend;
#ifdef __GNUC__
    tbegin = rdtsc();
#else
    tbegin = __rdtsc();
#endif
    for (size_t i = 0; i < num_user_movie_rating; ++i)
        fscanf(fp, "%d %d %d\n", &(user_movie_ratings[i].user),
               &(user_movie_ratings[i].movie), 
               &(user_movie_ratings[i].rating));
#ifdef __GNUC__
    tend = rdtsc();
#else
    tend = __rdtsc();
#endif
    printf("Time in data read %f (ms)\n",  ((tend - tbegin)/cpu_freq) * 1000);


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
 
    U_mat = (double *) malloc(NLATENT * num_users * sizeof(double));
    V_mat = (double *) malloc(NLATENT * num_movies * sizeof(double));

#if 0
    omp_lock_t *U_lock;
    omp_lock_t *V_lock;

    U_lock = (omp_lock_t *) malloc(NLATENT * num_users * sizeof(omp_lock_t));
    V_lock = (omp_lock_t *) malloc(NLATENT * num_movies * sizeof(omp_lock_t));
#endif

    std::srand(4562727);

#ifdef __GNUC__
    tbegin = rdtsc();
#else
    tbegin = __rdtsc();
#endif
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
#ifdef __GNUC__
    tend = rdtsc();
#else
    tend = __rdtsc();
#endif

    printf("Time in U-V mat init %f (ms)\n",  ((tend - tbegin)/cpu_freq) * 1000);

    // Sepearate edges into tiles. Each tile is a vector which
    // stores the edge ids (indices in the user_movie_ratings array)
    // that belong to it
    //std::vector<std::vector<unsigned int> > 
    //    tiles(num_nodes * num_procs * num_nodes * num_procs);
    std::vector<std::vector<edge> > 
        tiles(num_nodes * num_procs * num_nodes * num_procs);

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
   
#ifdef RANDOM_SHUFFLE
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

    const int num_users_in_tile = int(floor(num_users / float(num_nodes * num_procs)));
    const int num_movies_in_tile = int(floor(num_movies / float(num_nodes * num_procs)));

    for (size_t i = 0; i < num_user_movie_rating; ++i)
    {
        const unsigned int user_id = user_movie_ratings[i].user;
        const unsigned int movie_id = user_movie_ratings[i].movie;

        const int tile_x =
            std::min(int(floor((user_id - 1) / float(num_users_in_tile))), int(num_nodes * num_procs -1));
        const int tile_y =
            std::min(int(floor((movie_id - 1) / float(num_movies_in_tile))),int(num_nodes * num_procs -1));
        // if((tile_x * num_nodes + tile_y) > ((num_nodes * num_nodes)-1))
        //             // printf("%d %d\n", tile_x, tile_y);
        tiles[tile_x * (num_nodes * num_procs) + tile_y].push_back(user_movie_ratings[i]);
     }

    // Print some stats about how many ratings in each tile
    //for (size_t i = 0; i < (num_nodes * num_procs); ++i)
    //    for (size_t j = 0; j < (num_nodes * num_procs); ++j)
    //        printf("tile (%ld, %ld): %ld, %f\n", i, j, 
    //               tiles[i * (num_nodes * num_procs) + j].size(),
    //               (tiles[i * (num_nodes * num_procs) + j].size()/float(num_user_movie_rating)) * 100);

    printf("[info] VM usage before training: %lld (b)\n", getVmUsed());

    // exit(1);
    for (size_t itr = 0; itr < max_iter; itr++)
    {
#ifdef DOTPTIME
      double dotp_times_per_proc[num_procs];
      for (int i = 0; i < num_procs; i++) {
        dotp_times_per_proc[i] = 0;
      }
#endif
#ifdef __GNUC__
    tbegin = rdtsc();
#else
    tbegin = __rdtsc();
#endif
    for (size_t l = 0; l < num_nodes; ++l)
    {
        int row = 0;
        int col = l;

#ifdef DEBUG
        std::vector<std::set<int> > u_t(num_nodes);
        std::vector<std::set<int> > m_t(num_nodes);
#endif

        // Geneate the tile ids outside the loop 
        // Makes parallelization easier
        int rows[num_nodes];
        int cols[num_nodes];

        rows[0] = row;
        cols[0] = col;
        
        for (size_t k = 1; k < num_nodes; ++k)
        {
            row = (++row) % num_nodes;
            col = (++col) % num_nodes;
            rows[k] = row;
            cols[k] = col;
        }

        // This is the loop to be parallelized over all the nodes
        // #pragma omp parallel for
        for (size_t k = 0; k < num_nodes; ++k)
        {
            for(size_t pidx1 = 0; pidx1 < num_procs; ++pidx1) 
            {
#ifdef DEBUG
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

                // This loop needs to be parallelized ovre cores
                #pragma omp parallel for num_threads(num_procs)
                for(size_t pidx2 = 0; pidx2 < num_procs; ++pidx2) 
                {
                    //std::vector<unsigned int> &v = 
                    std::vector<edge> &v = 
                    tiles[rows[k] * num_procs * num_nodes * num_procs +
                          cols[k] * num_procs +
                          rowsp[pidx2] * (num_procs * num_nodes) + 
                          colsp[pidx2]];

                    // printf("%d %d %d %d %d\n",
                           // rows[k], cols[k], rowsp[pidx2], colsp[pidx2],
                           // rows[k] * num_procs * num_nodes * num_procs +
                           // cols[k] * num_procs +
                           // rowsp[pidx2] * (num_procs * num_nodes) + 
                           // colsp[pidx2]);
                           

                    for(size_t idx = 0; idx < v.size(); ++idx)
                    {
                        //const unsigned int i = v[idx];            
                        //int user_id = user_movie_ratings[i].user;
                        //int movie_id = user_movie_ratings[i].movie;
                        int user_id = v[idx].user;
                        int movie_id = v[idx].movie;

#ifdef DEBUG
                        u_t[k].insert(user_id);
                        m_t[k].insert(movie_id);
                        u_tn[pidx2].insert(user_id);
                        m_tn[pidx2].insert(movie_id);
#endif

#ifdef DOTPTIME
#ifdef __GNUC__
                        double tbegin_dotp = rdtsc();
#else
                        double tbegin_dotp = __rdtsc();
#endif
#endif
                        double pred = dotP(&(U_mat[(user_id-1) * NLATENT]), 
                                           &(V_mat[(movie_id-1) * NLATENT]));
#ifdef DOTPTIME
#ifdef __GNUC__
                        double tend_dotp = rdtsc();
#else
                        double tend_dotp = __rdtsc();
#endif
                        dotp_times_per_proc[pidx2] += tend_dotp - tbegin_dotp;
#endif
  
            // Truncate pred
                        pred = std::min(MAXVAL, pred);
                        pred = std::max(MINVAL, pred);

                        //const float err = (pred - user_movie_ratings[i].rating);
                        const float err = (pred - v[idx].rating);
        
                        for (size_t j = 0; j < NLATENT; ++j)
                            U_mat[(user_id-1) * NLATENT + j] +=
                                -GAMMA * (err*V_mat[(movie_id-1) * NLATENT + j] + 
                                          LAMBDA * U_mat[(user_id-1) * NLATENT + j]);

                        for (size_t j = 0; j < NLATENT; ++j)
                            V_mat[(movie_id-1) * NLATENT + j] +=
                                -GAMMA * (err*U_mat[(user_id-1) * NLATENT + j] + 
                                          LAMBDA * V_mat[(movie_id-1) * NLATENT + j]);
                    }

                }
#ifdef DEBUG
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
        }

#ifdef DEBUG
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
#ifdef __GNUC__
    tend = rdtsc();
#else
    tend = __rdtsc();
#endif
#ifdef DOTPTIME
    double avg = 0;
    for (int i = 0; i < num_procs; i++) {
      avg += dotp_times_per_proc[i];
    }
    avg /= num_procs;
    avg = avg / cpu_freq * 1000;
    double dev = 0;
    for (int i = 0; i < num_procs; i++) {
      dev += pow(dotp_times_per_proc[i] / cpu_freq * 1000 - avg, 2);
    }
    dev = sqrt(dev / num_procs);
    printf("Time in iteration %ld of sgd %f (ms) dotP %f (ms) std %f (ms)\n", itr, (tend - tbegin) / cpu_freq * 1000, avg, dev);
#else
    printf("Time in iteration %ld of sgd %f (ms)\n", itr, (tend - tbegin) / cpu_freq * 1000);
#endif
    }

    printf("[info] VM usage after training: %lld (b)\n", getVmUsed());

    // exit(1);
    
    // Calculate training error
    double train_err = 0;
    for (size_t i = 0; i < num_user_movie_rating; ++i)
    {
        int user_id = user_movie_ratings[i].user;
        int movie_id = user_movie_ratings[i].movie;

        double pred = dotP(&(U_mat[(user_id-1) * NLATENT]), 
                           &(V_mat[(movie_id-1) * NLATENT]));
  
        // Truncate pred
        pred = std::min(MAXVAL, pred);
        pred = std::max(MINVAL, pred);

        const float rmse = abs(
                            (pred - user_movie_ratings[i].rating)*
                            (pred - user_movie_ratings[i].rating));
  
        train_err += rmse;
    }
    train_err = sqrt(train_err/num_user_movie_rating);
    printf("Training rmse %f\n", train_err);

#if 0
    // Now calculate test error
    fp = fopen("netflix/netflix_mm.validate", "ro");

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

#ifdef RANDOM_SHUFFLE
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
    //
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
    free(user_movie_ratings_test);
#endif 

    // Free memory
    free(user_movie_ratings);
    free(U_mat);      
    free(V_mat); 
    // free(U_lock);      
    // free(V_lock); 
}




