
lazy val commonSettings = Seq(
  // Pick the specified scala version
  ivyScala := ivyScala.value map { _.copy(overrideScalaVersion = true) }
)

lazy val root = (project in file("."))
  .settings(commonSettings: _*)
  .settings(
    name := "study",
    scalaVersion := "2.11.7",
    scalaHome := Some(file("/usr/local/scala")))

libraryDependencies ++= Seq(
  "edu.brown.cs.sam" % "spark" % "1.4.0" % "provided",
  "edu.brown.cs.sam" % "spark-assembly" % "1.4.0" % "provided",
  "edu.brown.cs.sam" % "spark-examples" % "1.4.0" % "provided",
  "org.scalanlp" %% "breeze" % "0.11.2",
  // native libraries are not included by default. add this if you want them (as of 0.7)
  // native libraries greatly improve performance, but increase jar sizes.
  // It also packages various blas implementations, which have licenses that may or may not
  // be compatible with the Apache License. No GPL code, as best I know.
  "org.scalanlp" %% "breeze-natives" % "0.11.2",
  // the visualization library is distributed separately as well.
  // It depends on LGPL code.
  "org.scalanlp" %% "breeze-viz" % "0.11.2"
  //https://spark.apache.org/docs/1.1.0/mllib-guide.html
  //"com.github.fommil.netlib" %% "all" % "1.1.2"
)

resolvers ++= Seq(
  "Local Maven Repository" at "file://"+Path.userHome.absolutePath+"/.m2/repository",
  // if you want to use snapshot builds (currently 0.12-SNAPSHOT), use this.
  "Sonatype Snapshots" at "https://oss.sonatype.org/content/repositories/snapshots/",
  "Sonatype Releases" at "https://oss.sonatype.org/content/repositories/releases/"
)

scalacOptions ++= Seq("-Xmax-classfile-name","240")
