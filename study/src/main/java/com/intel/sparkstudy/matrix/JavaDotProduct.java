package com.intel.sparkstudy.matrix;

public class JavaDotProduct {

    public double dot(double[] as, double[] bs) {
        double result = 0;
        for (int i = 0; i < as.length; i++) {
            result += as[i] * bs[i];
        }
        return result;
    }
}
