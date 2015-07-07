lazy val root = (project in file(".")).settings(
  name := "study",
  scalaVersion := "2.11.7",
  scalaHome := Some(file("/usr/local/scala"))
)

libraryDependencies ++= Seq(
  // https://github.com/scalanlp/breeze/wiki/Installation
  "org.scalanlp" %% "breeze" % "0.10",
  // native libraries are not included by default. add this if you want them (as of 0.7)
  // native libraries greatly improve performance, but increase jar sizes.
  "org.scalanlp" %% "breeze-natives" % "0.10"
)

resolvers ++= Seq(
  // other resolvers here
  "Sonatype Releases" at "https://oss.sonatype.org/content/repositories/releases/"
)
