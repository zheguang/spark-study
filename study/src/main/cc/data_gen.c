#include <string.h>
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char* argv[]) {
  if (argc - 1 != 3) {
    fprintf(stderr, "usage: data_gen.out <filename> <num_users> <num_movies>\n");
    exit(1);
  }

  const char* fname = argv[1];
  int num_users = atoi(argv[2]);
  int num_movies = atoi(argv[3]);

  FILE* file = fopen(fname, "w");
  if (file == NULL) {
    perror(fname);
    exit(1);
  }

  for (int i = 0; i < num_users; i++) {
    for (int j = 0; j < num_movies; j++) {
      fprintf(file, "%d %d %d\n", i+1, j+1, rand() % 10 + 1);
    }
  }

  fclose(file);

  return 0;
}
