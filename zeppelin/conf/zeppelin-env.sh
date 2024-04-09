export ZEPPELIN_SPARK_CONCURRENTSQL=true
export ZEPPELIN_INTP_MEM="-Xms1024m -Xmx24G -XX:MaxPermSize=1024m"
export ZEPPELIN_MEM="-Xms1024m -Xmx24G -XX:MaxPermSize=1024m"
 
export ZEPPELIN_JAVA_OPTS="-Dspark.driver.memory=5g -Dspark.executor.memory60g -Dspark.cores.max=16"
export ZEPPELIN_INTERPRETER_DEP_MVNREPO="https://repo1.maven.org/maven2"
