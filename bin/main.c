#include "../src/parallelQuicksort.h"

/*
Main method:
-generate random list
-time sequential quicksort
-time parallel quicksort
-time standard qsort
*/
int main(int argc, char *argv[])
{
  struct timeval start, end;
  double diff;

  srand(time(NULL));            //seed random

  int NUM = DNUM;
  if (argc == 2)                //user specified list size.
  {
    NUM = atoi(argv[1]);
  }
  //Want to compare sorting on the same list,
  //so backup.
  double *lystbck = (double *) malloc(NUM * sizeof(double));
  double *lyst = (double *) malloc(NUM * sizeof(double));

  //Populate random original/backup list.
  for (int i = 0; i < NUM; i++) {
    lystbck[i] = 1.0 * rand() / RAND_MAX;
  }

  //copy list.
  memcpy(lyst, lystbck, NUM * sizeof(double));


  //Sequential mergesort, and timing.
  gettimeofday(&start, NULL);
  quicksort(lyst, NUM);
  gettimeofday(&end, NULL);

  if (!isSorted(lyst, NUM)) {
    printf("Oops, lyst did not get sorted by quicksort.\n");
  }
  //Compute time difference.
  diff = ((end.tv_sec * 1000000 + end.tv_usec)
          - (start.tv_sec * 1000000 + start.tv_usec)) / 1000000.0;
  printf("Sequential quicksort took: %lf sec.\n", diff);



  //Now, parallel quicksort.

  //copy list.
  memcpy(lyst, lystbck, NUM * sizeof(double));

  gettimeofday(&start, NULL);
  parallelQuicksort(lyst, NUM, THREAD_LEVEL);
  gettimeofday(&end, NULL);

  if (!isSorted(lyst, NUM)) {
    printf("Oops, lyst did not get sorted by parallelQuicksort.\n");
  }
  //Compute time difference.
  diff = ((end.tv_sec * 1000000 + end.tv_usec)
          - (start.tv_sec * 1000000 + start.tv_usec)) / 1000000.0;
  printf("Parallel quicksort took: %lf sec.\n", diff);



  //Finally, built-in for reference:
  memcpy(lyst, lystbck, NUM * sizeof(double));
  gettimeofday(&start, NULL);
  qsort(lyst, NUM, sizeof(double), compare_doubles);
  gettimeofday(&end, NULL);

  if (!isSorted(lyst, NUM)) {
    printf("Oops, lyst did not get sorted by qsort.\n");
  }
  //Compute time difference.
  diff = ((end.tv_sec * 1000000 + end.tv_usec)
          - (start.tv_sec * 1000000 + start.tv_usec)) / 1000000.0;
  printf("Built-in quicksort took: %lf sec.\n", diff);

  free(lyst);
  free(lystbck);
  pthread_exit(NULL);
}

