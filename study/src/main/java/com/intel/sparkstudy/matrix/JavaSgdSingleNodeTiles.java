package com.intel.sparkstudy.matrix;

import com.github.fommil.netlib.BLAS;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.Random;
import java.util.Scanner;

import static java.lang.Integer.parseInt;
import static java.lang.Math.*;

/**
 * Created by sam on 7/13/15.
 */
public class JavaSgdSingleNodeTiles {

    static final int NLATENT = 20;
    static final int max_iter = 5;
    static final double MAXVAL = 1e+100;
    static final double MINVAL = -1e+100;
    static final double LAMBDA = 0.001;
    static final double STEP_DEC = 0.9;
    static final double cpu_freq = 2.7e9;


    static class Edge {
        final int user;
        final int movie;
        final int rating;

        Edge(int user, int movie, int rating) {
            this.user = user;
            this.movie = movie;
            this.rating = rating;
        }
    }

    static abstract class Algebran {
        abstract double dotP(double[] u_mat, int u_start, double[] v_mat, int v_start);

        static Algebran of(String mode) {
            switch (mode.toLowerCase()) {
                case "java":
                    return new JavaAlgebran();
                case "blas":
                    return new BlasAlgebran();
                default:
                    throw new SparkStudyError("Unsupported dot product mode: " + mode);
            }
        }
    }

    static class JavaAlgebran extends Algebran {
        @Override
        double dotP(double[] u_mat, int u_start, double[] v_mat, int v_start) {
            double result = 0;
            for (int i = 0; i < NLATENT; i++) {
                result += u_mat[u_start + i] * v_mat[v_start + i];
            }
            return result;
        }
    }

    static class BlasAlgebran extends Algebran {
        @Override
        double dotP(double[] u_mat, int u_start, double[] v_mat, int v_start) {
            return BLAS.getInstance().ddot(NLATENT, u_mat, u_start, 1, v_mat, v_start, 1);
        }
    }

    public static void main(String[] args) {
        if (args.length < 6) {
            System.out.println("Syntax: JavaSgdSingleNodeTiles [java|blas] <filename> <nusers> <nmovies> <nratings> <nthreads>");
            System.exit(123);
        }
        final String algebra_mode = args[0];
        final Algebran algebran = Algebran.of(algebra_mode);
        final String filename = args[1];
        final int num_users = parseInt(args[2]);
        final int num_movies = parseInt(args[3]);
        final int num_user_movie_ratings = parseInt(args[4]);
        //final int num_user_movie_ratings = (int) (num_users * num_movies * 0.10);  // 10% filled ratings matrix.
        final int num_procs = parseInt(args[5]);
        final int num_nodes = 2;
        final Edge[] user_movie_ratings = new Edge[num_user_movie_ratings];
        final Random randGen = new Random(4562727);

        System.out.println("algebra_mode=" + algebra_mode);
        System.out.println("filename=" + filename);
        System.out.println("num_users=" + num_users);
        System.out.println("num_movies=" + num_movies);
        System.out.println("num_user_movie_ratings=" + num_user_movie_ratings);
        System.out.println("num_procs=" + num_procs);
        System.out.println("num_nodes=" + num_nodes);

        Scanner scanner = null;
        try {
            scanner = new Scanner(new BufferedReader(new FileReader(filename)));
            for (int i = 0; i < num_user_movie_ratings; i++) {
                int user = scanner.nextInt();
                int movie = scanner.nextInt();
                int rating = scanner.nextInt();
                user_movie_ratings[i] = new Edge(user, movie, rating);
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } finally {
            if (scanner != null) {
                scanner.close();
            }
        }

        double[] U_mat = new double[NLATENT * num_users];
        double[] V_mat = new double[NLATENT * num_movies];
        for (int i = 0; i < num_users; i++) {
            for (int j = 0; j < NLATENT; j++) {
                U_mat[i * NLATENT + j] = (-1) + 2 * randGen.nextDouble();
            }
        }
        for (int i = 0; i < num_movies; i++) {
            for (int j = 0; j < NLATENT; j++) {
                V_mat[i * NLATENT + j] = (-1) + 2 * randGen.nextDouble();
            }
        }

        final int numTilesOneDim = num_nodes * num_procs;
        ArrayList<ArrayList<Integer>> tilesMat = new ArrayList<>(numTilesOneDim * numTilesOneDim);
        for (int i = 0; i < numTilesOneDim * numTilesOneDim; i++) {
            tilesMat.add(new ArrayList<>());
        }
        final int num_users_in_tile = (int) floor(num_users / (float) numTilesOneDim);
        final int num_movies_in_tile = (int) floor(num_movies / (float) numTilesOneDim);
        for (int i = 0; i < num_user_movie_ratings; i++) {
            int user_id = user_movie_ratings[i].user;
            int movie_id = user_movie_ratings[i].movie;
            int tile_x = min(
                    (int) floor((user_id - 1) / (float) num_users_in_tile),
                    numTilesOneDim - 1
            );
            int tile_y = min(
                    (int) floor((movie_id - 1) / (float) num_movies_in_tile),
                    numTilesOneDim - 1
            );
            tilesMat.get(tile_x * numTilesOneDim + tile_y).add(i);
        }

        // training
        double GAMMA = 0.001;
        for (int itr = 0; itr < max_iter; itr++)
        {
            double tbegin = System.nanoTime();
            for (int l = 0; l < num_nodes; ++l)
            {
                int row = 0;
                int col = l;

                // Geneate the tile ids outside the loop
                // Makes parallelization easier
                int[] rows = new int[num_nodes];
                int[] cols = new int[num_nodes];

                rows[0] = row;
                cols[0] = col;

                for (int k = 1; k < num_nodes; ++k)
                {
                    row = (++row) % num_nodes;
                    col = (++col) % num_nodes;
                    rows[k] = row;
                    cols[k] = col;
                }

                // This is the loop to be parallelized over all the nodes
                // #pragma omp parallel for
                for (int k = 0; k < num_nodes; ++k)
                {
                    for(int pidx1 = 0; pidx1 < num_procs; ++pidx1)
                    {
                        int rowp = 0;
                        int colp = pidx1;

                        int[] rowsp = new int[num_procs];
                        int[] colsp = new int[num_procs];

                        rowsp[0] = rowp;
                        colsp[0] = colp;

                        for (int idx = 1; idx < num_procs; ++idx)
                        {
                            rowp = (++rowp) % num_procs;
                            colp = (++colp) % num_procs;
                            rowsp[idx] = rowp;
                            colsp[idx] = colp;
                        }

                        // This loop needs to be parallelized ovre cores
                        for(int pidx2 = 0; pidx2 < num_procs; ++pidx2)
                        {
                            ArrayList<Integer> v =
                                tilesMat.get(rows[k] * num_procs * num_nodes * num_procs +
                                        cols[k] * num_procs +
                                        rowsp[pidx2] * (num_procs * num_nodes) +
                                        colsp[pidx2]);

                            // printf("%d %d %d %d %d\n",
                            // rows[k], cols[k], rowsp[pidx2], colsp[pidx2],
                            // rows[k] * num_procs * num_nodes * num_procs +
                            // cols[k] * num_procs +
                            // rowsp[pidx2] * (num_procs * num_nodes) +
                            // colsp[pidx2]);


                            for(int idx = 0; idx < v.size(); ++idx)
                            {
                                final int i = v.get(idx);
                                int user_id = user_movie_ratings[i].user;
                                int movie_id = user_movie_ratings[i].movie;

                                double pred = algebran.dotP(U_mat, (user_id-1) * NLATENT,
                                V_mat, (movie_id-1) * NLATENT);

                                // Truncate pred
                                pred = min(MAXVAL, pred);
                                pred = max(MINVAL, pred);

                                double err = (pred - user_movie_ratings[i].rating);

                                for (int j = 0; j < NLATENT; ++j)
                                    U_mat[(user_id-1) * NLATENT + j] +=
                                            -GAMMA * (err*V_mat[(movie_id-1) * NLATENT + j] +
                                                    LAMBDA * U_mat[(user_id-1) * NLATENT + j]);

                                for (int j = 0; j < NLATENT; ++j)
                                    V_mat[(movie_id-1) * NLATENT + j] +=
                                            -GAMMA * (err*U_mat[(user_id-1) * NLATENT + j] +
                                                    LAMBDA * V_mat[(movie_id-1) * NLATENT + j]);
                            }
                        }
                    }
                }
            }
            GAMMA *= STEP_DEC;
            double tend = System.nanoTime();
            System.out.printf("Time in iteration %d of sgd %f (ms) \n", itr, ((tend - tbegin)/cpu_freq)* 1000);
        }

        // Calculate training error
        double train_err = 0;
        for (int i = 0; i < num_user_movie_ratings; i++) {
            int user_id = user_movie_ratings[i].user;
            int movie_id = user_movie_ratings[i].movie;

            double pred = algebran.dotP(U_mat, (user_id - 1) * NLATENT, V_mat, (movie_id - 1) * NLATENT);
            pred = min(MAXVAL, pred);
            pred = max(MINVAL, pred);

            double rmse = pow(pred - user_movie_ratings[i].rating, 2);
            train_err += rmse;
        }
        train_err = sqrt(train_err / num_user_movie_ratings);
        System.out.printf("Training rmse %f\n", train_err);
    }
}
