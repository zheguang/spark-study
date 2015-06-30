lazy val root = (project in file(".")).settings(
  name := "study",
  scalaVersion := "2.10.4",
  scalaHome := Some(file("../third_party/spark/build/scala-2.10.4"))
)
