package com.intel.sparkstudy.matrix;

/**
 * Created by sam on 7/3/15.
 */
public class MatrixOps {

    static class Matrix {
        double[][] m;

        Matrix(int numRows, int numCols) {
            m = new double[numRows][numCols];
        }

        Matrix(double[][] m) {
            this.m = m;
        }

        int numRows() {
            return m.length;
        }
        int numCols() {
            return m[0].length;
        }
        double at(int r, int c) {
            return m[r][c];
        }
        void set(int r, int c, double val) {
            m[r][c] = val;
        }
    }

    static Matrix mult_iter(Matrix m1, Matrix m2) {
        assert(m1.numCols() == m2.numRows());
        Matrix result = new Matrix(m1.numRows(), m2.numCols());
        for (int r = 0; r < m1.numRows(); r++) {
            for (int c = 0; c < m2.numCols(); c++) {
                double temp = 0;
                for (int k = 0; k < m1.numCols(); k++) {
                    temp += m1.at(r, k) * m2.at(k, c);
                }
                result.set(r, c, temp);
            }
        }

        return result;
    }

//    static double[][] mult_iter(double[][] m1, double[][] m2) {
//        assert(m1[0].length == m2.length);
//        double[][] result = new double[m1.length][m2[0].length];
//        for (int r = 0; r < m1.length; r++) {
//            for (int c = 0; c < m2[0].length; c++) {
//                double temp = 0;
//                for (int k = 0; k < m1[r].length; k++) {
//                    temp += m1[r][k] * m2[k][c];
//                }
//                result[r][c] = temp;
//            }
//        }
//
//        return result;
//    }

    public static void main(String[] args) {
        double[][] m1_ = {
                {1, 2, 3},
                {4, 5, 6},
        };
        double[][] m2_ = {
                {1, 2},
                {3, 4},
                {5, 6}
        };
        Matrix m1 = new Matrix(m1_);
        Matrix m2 = new Matrix(m2_);
        Matrix result = mult_iter(m1, m2);

        StringBuilder strBuilder = new StringBuilder();
        for (int r = 0; r < result.numRows(); r++) {
            for (int c = 0; c < result.numCols(); c++) {
                strBuilder.append(result.at(r, c)).append(" ");
            }
            strBuilder.append("\n");
        }
        String resultStr = strBuilder.toString();
        System.out.println(resultStr);
    }
}
