package edu.brown.cs.sparkstudy

import java.io.{File, FileWriter, BufferedWriter}

import scala.io.Source

object NativeGraphConverter {

  def main(args: Array[String]) = {
    if (args.length < 2) {
      println("Usage: NativeGraphConverter <inputPath> <outputPath>")
      System.exit(123)
    }
    val inputPath = args(0)
    val outputPath = args(1)
    val writer = new BufferedWriter(new FileWriter(new File(outputPath)))
    Source.fromFile(inputPath).getLines().drop(1).foreach { line =>
      val edge = line.split("\\s+", 2)(1)
      writer.write(s"$edge\n")
    }
    writer.close()
  }
}
