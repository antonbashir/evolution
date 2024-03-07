#ifndef CORE_SYSTEM_TIME_H
#define CORE_SYSTEM_TIME_H

#include <stdio.h>
#include <sys/time.h>
#include <time.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#define measure(name, runs, call)                                                                                                                                                                               \
    do                                                                                                                                                                                                          \
    {                                                                                                                                                                                                           \
        struct timeval measure_start_time##__LINE__, measure_estimated_time##__LINE__;                                                                                                                          \
        gettimeofday(&measure_start_time##__LINE__, NULL);                                                                                                                                                      \
        for (int i = 0; i < runs; i++)                                                                                                                                                                          \
        {                                                                                                                                                                                                       \
            call;                                                                                                                                                                                               \
        }                                                                                                                                                                                                       \
        gettimeofday(&measure_estimated_time##__LINE__, NULL);                                                                                                                                                  \
        int elapsed = (((measure_estimated_time##__LINE__.tv_sec - measure_start_time##__LINE__.tv_sec) * 1000000) + (measure_estimated_time##__LINE__.tv_usec - measure_start_time##__LINE__.tv_usec)) / runs; \
        printf("%s time: %d micro seconds\n", name, elapsed);                                                                                                                                                   \
    }                                                                                                                                                                                                           \
    while (0);

#define now()                                        \
    ({                                               \
        struct timespec _timeout##__LINE__;          \
        timespec_get(&_timeout##__LINE__, TIME_UTC); \
        _timeout##__LINE__;                          \
    })

#define timeout_seconds(seconds)                     \
    ({                                               \
        struct timespec _timeout##__LINE__;          \
        timespec_get(&_timeout##__LINE__, TIME_UTC); \
        timeout.tv_sec += (seconds);                 \
        _timeout##__LINE__;                          \
    })

#if defined(__cplusplus)
}
#endif

#endif