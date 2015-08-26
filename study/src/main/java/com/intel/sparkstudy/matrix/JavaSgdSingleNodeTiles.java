package com.intel.sparkstudy.matrix;

import com.github.fommil.netlib.BLAS;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.util.*;
import java.util.concurrent.*;

import static java.lang.Integer.parseInt;
import static java.lang.Math.*;

/**
 * Created by sam on 7/13/15.
 */
public class JavaSgdSingleNodeTiles {

    static final int max_iter = 5;
    static final double MAXVAL = 1e+100;
    static final double MINVAL = -1e+100;
    static final double LAMBDA = 0.001;
    static final double STEP_DEC = 0.9;
    static final int mb = 1024 * 1024;

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
        abstract double dotP(int vectorLen, double[] u_mat, int u_start, double[] v_mat, int v_start);

        static Algebran of(String measure, String mode) {
            switch (mode.toLowerCase()) {
                case "java":
                    switch (measure.toLowerCase()) {
                        case "none":
                            return new JavaAlgebran();
                        case "dotptime":
                            return new TimerJavaAlgebran();
                        default:
                            throw new RuntimeException("Unsupported: " + measure);
                    }
                case "blas":
                    switch (measure.toLowerCase()) {
                        case "none":
                            return new BlasAlgebran();
                        case "dotptime":
                            return new TimerBlasAlgebran();
                        default:
                            throw new RuntimeException("Unsupported: " + measure);
                    }
                default:
                    throw new SparkStudyError("Unsupported dot product mode: " + mode);
            }
        }

        abstract List<Long> getTimes();
        abstract void clear();
    }

    static class JavaAlgebran extends Algebran {
        @Override
        double dotP(int vectorLen, double[] u_mat, int u_start, double[] v_mat, int v_start) {
            double result = 0;
            for (int i = 0; i < vectorLen; i++) {
                result += u_mat[u_start + i] * v_mat[v_start + i];
            }
            return result;
        }

        @Override
        List<Long> getTimes() {
            throw new RuntimeException("Not implemented");
        }

        @Override
        void clear() {
            throw new RuntimeException("Not implemented");
        }
    }

    static class TimerJavaAlgebran extends JavaAlgebran {
        ConcurrentHashMap<Long, Long> timers = new ConcurrentHashMap<>();
        @Override
        double dotP(int vectorLen, double[] u_mat, int u_start, double[] v_mat, int v_start) {
            long start = System.currentTimeMillis();
            double result = super.dotP(vectorLen, u_mat, u_start, v_mat, v_start);
            long end = System.currentTimeMillis();
            long tid = Thread.currentThread().getId();
            timers.put(tid, timers.getOrDefault(tid, 0l) + end - start);
            return result;
        }

        @Override
        List<Long> getTimes() {
            return new ArrayList<>(timers.values());
        }

        @Override
        void clear() {
            timers.clear();
        }
    }

    static class BlasAlgebran extends Algebran {
        @Override
        double dotP(int vectorLen, double[] u_mat, int u_start, double[] v_mat, int v_start) {
            return BLAS.getInstance().ddot(vectorLen, u_mat, u_start, 1, v_mat, v_start, 1);
        }

        @Override
        List<Long> getTimes() {
            throw new RuntimeException("Not implemented");
        }

        @Override
        void clear() {
            throw new RuntimeException("Not implemented");
        }
    }

    static class TimerBlasAlgebran extends BlasAlgebran {
        ConcurrentHashMap<Long, Long> timers = new ConcurrentHashMap<>();
        @Override
        double dotP(int vectorLen, double[] u_mat, int u_start, double[] v_mat, int v_start) {
            long start = System.currentTimeMillis();
            double result = super.dotP(vectorLen, u_mat, u_start, v_mat, v_start);
            long end = System.currentTimeMillis();
            long tid = Thread.currentThread().getId();
            timers.put(tid, timers.getOrDefault(tid, 0l) + end - start);
            return result;
        }

        @Override
        List<Long> getTimes() {
            return new ArrayList<>(timers.values());
        }

        @Override
        void clear() {
            timers.clear();
        }
    }

    public static void main(String[] args) {
        if (args.length < 6) {
            System.err.println("Syntax: JavaSgdSingleNodeTiles [java|blas] <latent> <filename> <nusers> <nmovies> <nratings> <nthreads>");
            System.exit(123);
        }
        final String measure = args[0].toLowerCase();
        final String algebra_mode = args[1];
        final Algebran algebran = Algebran.of(measure, algebra_mode);
        final int NLATENT = parseInt(args[2]);
        final String filename = args[3];
        final int num_users = parseInt(args[4]);
        final int num_movies = parseInt(args[5]);
        final int num_user_movie_ratings = parseInt(args[6]);
        final int num_procs = parseInt(args[7]);
        final int num_nodes = 1;
        final Edge[] user_movie_ratings = new Edge[num_user_movie_ratings];
        final Random randGen = new Random(4562727);
        final ExecutorService procsPool = Executors.newFixedThreadPool(num_procs);

        System.out.println("algebra_mode=" + algebra_mode);
        System.out.println("nlatent=" + NLATENT);
        System.out.println("filename=" + filename);
        System.out.println("num_users=" + num_users);
        System.out.println("num_movies=" + num_movies);
        System.out.println("num_user_movie_ratings=" + num_user_movie_ratings);
        System.out.println("num_procs=" + num_procs);
        System.out.println("num_nodes=" + num_nodes);

        double tbegin = System.currentTimeMillis();
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
        double tend = System.currentTimeMillis();
        System.out.printf("Time in data read: %f (ms)\n", tend - tbegin);

        tbegin = System.currentTimeMillis();
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
        tend = System.currentTimeMillis();
        System.out.printf("Time in U-V init: %f (ms)\n", tend - tbegin);


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

        Runtime runtime = Runtime.getRuntime();
        System.out.printf("[info] Used memory before training: %d\n", (runtime.totalMemory() - runtime.freeMemory()) / mb);
        // training
        double GAMMA = 0.001;
        for (int itr = 0; itr < max_iter; itr++)
        {
            tbegin = System.currentTimeMillis();
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
                        List<Callable<Boolean>> tasks = new ArrayList<>(num_procs);
                        for(int pidx2 = 0; pidx2 < num_procs; ++pidx2) {
                            final int PIDX2 = pidx2;
                            final int K = k;
                            final double Gamma = GAMMA;
                            tasks.add(() -> {
                                processOneTile(
                                        algebran,
                                        tilesMat.get(
                                                rows[K] * num_procs * num_nodes * num_procs +
                                                        cols[K] * num_procs +
                                                        rowsp[PIDX2] * (num_procs * num_nodes) +
                                                        colsp[PIDX2]),
                                        user_movie_ratings, U_mat, V_mat, Gamma, NLATENT);
                                return true;
                            });
                        }
                        try {
                            List<Future<Boolean>> procsFutures = procsPool.invokeAll(tasks);
                            for (Future<Boolean> f : procsFutures) {
                                boolean status = f.get();
                                if (!status) {
                                    throw new SparkStudyError("Unexpected error in per tile work.");
                                }
                            }
                        } catch (InterruptedException | ExecutionException e) {
                            e.printStackTrace();
                            System.exit(123);
                        }
                    }
                }
            }
            GAMMA *= STEP_DEC;
            tend = System.currentTimeMillis();
            System.out.printf("[info] Time in iteration %d of sgd %f (ms)\n", itr, tend - tbegin);
            switch (measure.toLowerCase()) {
                case "none":
                    break;
                case "dotptime":
                    List<Long> vs = algebran.getTimes();
                    /*switch (algebra_mode.toLowerCase()) {
                        case "java":
                            vs = ((TimerJavaAlgebran) algebran).getTimes();
                            break;
                        case "blas":
                            vs = ((TimerBlasAlgebran) algebran).getTimes();
                            break;
                        default:
                            throw new RuntimeException("unsupported");
                    }*/
                    long sum = 0;
                    for (Long v : vs) {
                        sum += v;
                    }
                    double avg = sum / (double) vs.size();
                    double std = 0f;
                    for (Long v : vs) {
                        std += Math.pow(v - avg, 2f);
                    }
                    std = Math.sqrt(std / vs.size());
                    System.out.printf("[info] dotptime avg: %f ms, std: %f ms, num threads: %d\n", avg, std, vs.size());

                    algebran.clear();
                    break;
            }
        }
        System.out.printf("[info] Used memory before training: %d\n", (runtime.totalMemory() - runtime.freeMemory()) / mb);

        // Calculate training error
        double train_err = 0;
        for (int i = 0; i < num_user_movie_ratings; i++) {
            int user_id = user_movie_ratings[i].user;
            int movie_id = user_movie_ratings[i].movie;

            double pred = algebran.dotP(NLATENT, U_mat, (user_id - 1) * NLATENT, V_mat, (movie_id - 1) * NLATENT);
            pred = min(MAXVAL, pred);
            pred = max(MINVAL, pred);

            double rmse = pow(pred - user_movie_ratings[i].rating, 2);
            train_err += rmse;
        }
        train_err = sqrt(train_err / num_user_movie_ratings);
        System.out.printf("Training rmse %f\n", train_err);

        procsPool.shutdown();
        assert procsPool.isTerminated();
    }

    private static void processOneTile(Algebran algebran, ArrayList<Integer> tile, Edge[] user_movie_ratings, double[] u_mat, double[] v_mat, double GAMMA, int NLATENT) {
        ArrayList<Integer> v =
                tile;

        for(int idx = 0; idx < v.size(); ++idx)
        {
            final int i = v.get(idx);
            int user_id = user_movie_ratings[i].user;
            int movie_id = user_movie_ratings[i].movie;

            double pred = algebran.dotP(NLATENT, u_mat, (user_id-1) * NLATENT,
                    v_mat, (movie_id-1) * NLATENT);

            // Truncate pred
            pred = min(MAXVAL, pred);
            pred = max(MINVAL, pred);

            double err = (pred - user_movie_ratings[i].rating);

            for (int j = 0; j < NLATENT; ++j)
                u_mat[(user_id-1) * NLATENT + j] +=
                        -GAMMA * (err* v_mat[(movie_id-1) * NLATENT + j] +
                                LAMBDA * u_mat[(user_id-1) * NLATENT + j]);

            for (int j = 0; j < NLATENT; ++j)
                v_mat[(movie_id-1) * NLATENT + j] +=
                        -GAMMA * (err* u_mat[(user_id-1) * NLATENT + j] +
                                LAMBDA * v_mat[(movie_id-1) * NLATENT + j]);
        }
    }
}
