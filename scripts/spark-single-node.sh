# Spark single node set up

# All local input/output files should start with file:///.

# In $HADOOP_PREFIX/etc/core-site.xml, change default FS
# to use 'localhost' rather than 'node1'.

# In $HADOOP_PREFIX/etc/slaves, change 'node1' to 'localhost'.

# In $SPARK_PREFIX/conf/slaves, change 'node1' to 'localhost'.

