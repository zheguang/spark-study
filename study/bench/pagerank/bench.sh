#!/bin/bash
set -e

#spark_master_url=spark://ginchi:7077
#num_executors=2
#$SPARK_HOME/bin/spark-submit --class org.apache.spark.examples.SparkPageRank --master $spark_master_url --num-executors $num_executors $SPARK_HOME/lib/spark-examples*.jar file:///usr/local/spark/data/mllib/pagerank_data.txt

cd /home/sam/devel/spark-study/study

/usr/local/spark/bin/spark-submit --class edu.brown.cs.sparkstudy.GraphxPageRank --master spark://ginchi:7077 --num-executors 2 target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar file:///usr/local/spark/data/mllib/pagerank_data.txt 10

/usr/local/spark/bin/spark-submit --class edu.brown.cs.sparkstudy.RddPageRank --master spark://ginchi:7077 --num-executors 2 target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar file:///usr/local/spark/data/mllib/pagerank_data.txt 10
