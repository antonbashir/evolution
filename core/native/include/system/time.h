#ifndef CORE_SYSTEM_TIME_H
#define CORE_SYSTEM_TIME_H

#include <stdio.h>     // IWYU pragma: export
#include <sys/time.h>  // IWYU pragma: export

#if defined(__cplusplus)
extern "C"
{
#endif

    __thread struct timeval measure_start_time, measure_estimated_time;
    __thread char* measure_name;
    __thread int measure_runs;

#define start_measure(name, runs)            \
    measure_name = name;                     \
    measure_runs = runs;                     \
    gettimeofday(&measure_start_time, NULL); \
    for (int i = 0; i < measure_runs; i++)

#define end_measure()                                                                                                                                                       \
    gettimeofday(&measure_estimated_time, NULL);                                                                                                                            \
    int elapsed = (((measure_estimated_time.tv_sec - measure_start_time.tv_sec) * 1000000) + (measure_estimated_time.tv_usec - measure_start_time.tv_usec)) / measure_runs; \
    printf("%s time: %d micro seconds\n", measure_name, elapsed);

#if defined(__cplusplus)
}
#endif

#endif