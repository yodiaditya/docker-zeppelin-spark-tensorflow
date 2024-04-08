export ZEPPELIN_SPARK_CONCURRENTSQL=true
export ZEPPELIN_INTP_MEM="-Xms1024m -Xmx24G -XX:MaxPermSize=1024m"
export ZEPPELIN_MEM="-Xms1024m -Xmx24G -XX:MaxPermSize=1024m"
 
export MASTER="spark://spark-master:7077"
export ZEPPELIN_JAVA_OPTS="-Dspark.driver.memory=5g -Dspark.executor.memory50g -Dspark.cores.max=16"
