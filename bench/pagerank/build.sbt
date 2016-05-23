name := "graphx-bench"
 
version := "1.0"
 
scalaVersion := "2.11.7"
 
libraryDependencies ++= Seq(
  "org.apache.spark" %% "spark-core" % "1.6.1",
  "org.apache.spark" %% "spark-graphx" % "1.6.1"
)
 
resolvers ++= Seq(
  "Akka Repository" at "http://repo.akka.io/releases/"
)
