lazy val root = (project in file("study")).settings(
  name := "study",
  scalaVersion := "2.10.4",
  scalaHome := Some(file("third_party/spark/build/scala-2.10.4"))
)

// Tasks
lazy val copySparkJars = taskKey[Unit]("Copies spark jars to development tree")
copySparkJars := {
 "bash scripts/copy-spark-jars.sh" !
}
