#include <stdlib.h>
#include <stdio.h>

int main() {
  int num_users = 1 << 5;
  int num_movies = 1 << 4;

  FILE* file = fopen("ratings.dat", "w");
  if (file == NULL) {
    perror("fopen");
    exit(1);
  }

  for (int i = 0; i < num_users; i++) {
    for (int j = 0; j < num_movies; j++) {
      fprintf(file, "%d %d %d\n", i, j, rand() % 10 + 1);
    }
  }

  fclose(file);

  return 0;
}
