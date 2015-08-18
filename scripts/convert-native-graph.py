#!/usr/bin/python

import sys

def main(args):
    inputPath = args[1]
    outputPath = args[2]
    with open(inputPath, 'r') as inf:
        with open(outputPath, 'w') as ouf:
            #print(i.readline().split(" ", 1))
            inf.readline() # burn first line which is metadata
            for line in inf:
                ouf.write(line.split(" ", 1)[1])


if __name__ == '__main__':
    main(sys.argv)
