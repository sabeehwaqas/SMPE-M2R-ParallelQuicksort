#ifndef __QUICK__
#define __QUICK__

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include <string.h>

#define DNUM 1000000
#define THREAD_LEVEL 10

struct thread_data {
  double *lyst;
  int low;
  int high;
  int level;
};
//thread_data should be thread-safe, since while lyst is 
//shared, [low, high] will not overlap among threads.

//for sequential and parallel implementation
int isSorted(double lyst[], int size);
int partition(double lyst[], int lo, int hi);

void swap(double lyst[], int i, int j);
void quicksort(double lyst[], int size);
void quicksortHelper(double lyst[], int lo, int hi);

//for parallel implementation
void parallelQuicksort(double lyst[], int size, int tlevel);
void *parallelQuicksortHelper(void *threadarg) __attribute__ ((noreturn));

//for the builtin qsort, for fun:
int compare_doubles(const void *a, const void *b);

#endif
