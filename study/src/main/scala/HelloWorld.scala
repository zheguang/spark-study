import org.apache.spark.SparkConf

class HelloWorld
{
  def greet() =
  {
    println("Hey there!")
  }
}

object Main
{
  def main(args: Array[String]) =
  {
    val h = new HelloWorld()
    h.greet()
  }
}
