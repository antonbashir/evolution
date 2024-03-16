#ifndef CORE_SYSTEM_TIME_H
#define CORE_SYSTEM_TIME_H

#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#define NANOSECONDS_PER_SECOND 1000000000

#define time_now_real()                                     \
    ({                                                      \
        struct timespec _timeout##__LINE__;                 \
        clock_gettime(CLOCK_REALTIME, &_timeout##__LINE__); \
        _timeout##__LINE__;                                 \
    })

#define time_now_monotonic()                                 \
    ({                                                       \
        struct timespec _timeout##__LINE__;                  \
        clock_gettime(CLOCK_MONOTONIC, &_timeout##__LINE__); \
        _timeout##__LINE__;                                  \
    })

#define time_normalize(time)                                        \
    ({                                                              \
        while (time.tv_nsec >= NANOSECONDS_PER_SECOND)              \
        {                                                           \
            ++(time.tv_sec);                                        \
            time.tv_nsec -= NANOSECONDS_PER_SECOND;                 \
        }                                                           \
                                                                    \
        while (time.tv_nsec <= -NANOSECONDS_PER_SECOND)             \
        {                                                           \
            --(time.tv_sec);                                        \
            time.tv_nsec += NANOSECONDS_PER_SECOND;                 \
        }                                                           \
                                                                    \
        if (time.tv_nsec < 0)                                       \
        {                                                           \
            --(time.tv_sec);                                        \
            time.tv_nsec = (NANOSECONDS_PER_SECOND + time.tv_nsec); \
        }                                                           \
        time;                                                       \
    })

#define time_from_milliseconds(milliseconds)                  \
    ({                                                        \
        struct timespec _time_from_milliseconds##__LINE__ = { \
            .tv_sec = (milliseconds / 1000),                  \
            .tv_nsec = (milliseconds % 1000) * 1000000,       \
        };                                                    \
        time_normalize(_time_from_milliseconds##__LINE__);    \
    })

#define time_to_milliseconds(time)                       \
    ({                                                   \
        (time.tv_sec * 1000) + (time.tv_nsec / 1000000); \
    });

#define time_to_microseconds(time)                       \
    ({                                                   \
        (time.tv_sec * 1000000) + (time.tv_nsec / 1000); \
    });

#define time_add(result, adding)          \
    ({                                    \
        result = time_normalize(result);  \
        adding = time_normalize(adding);  \
                                          \
        result.tv_sec += adding.tv_sec;   \
        result.tv_nsec += adding.tv_nsec; \
                                          \
        time_normalize(result);           \
    })

#define time_sub(result, subtracting)              \
    ({                                             \
        result = time_normalize(result);           \
        subtracting = time_normalize(subtracting); \
                                                   \
        result.tv_sec -= subtracting.tv_sec;       \
        result.tv_nsec -= subtracting.tv_nsec;     \
                                                   \
        time_normalize(result);                    \
    })

#define timeout_seconds(seconds)                                                         \
    ({                                                                                   \
        struct timespec _timeout##__LINE__ = time_now_real();                            \
        struct timespec _timeout_add##__LINE__ = time_from_milliseconds(seconds * 1000); \
        time_add(_timeout##__LINE__, _timeout_add##__LINE__);                            \
    })

#define timeout_microseconds(microseconds)                                                    \
    ({                                                                                        \
        struct timespec _timeout##__LINE__ = time_now_real();                                 \
        struct timespec _timeout_add##__LINE__ = time_from_milliseconds(microseconds / 1000); \
        time_add(_timeout##__LINE__, _timeout_add##__LINE__);                                 \
    })

#define timeout_milliseconds(milliseconds)                                             \
    ({                                                                                 \
        struct timespec _timeout##__LINE__ = time_now_real();                          \
        struct timespec _timeout_add##__LINE__ = time_from_milliseconds(milliseconds); \
        time_add(_timeout##__LINE__, _timeout_add##__LINE__);                          \
    })

#define time_measure(name, runs, call)                                                                                     \
    do                                                                                                                     \
    {                                                                                                                      \
        struct timespec measure_start_time##__LINE__, measure_estimated_time##__LINE__;                                    \
        measure_start_time##__LINE__ = time_now_monotonic();                                                               \
        for (int i = 0; i < runs; i++)                                                                                     \
        {                                                                                                                  \
            call;                                                                                                          \
        }                                                                                                                  \
        measure_estimated_time##__LINE__ = time_now_monotonic();                                                           \
        time_normalize(measure_start_time##__LINE__);                                                                      \
        time_normalize(measure_estimated_time##__LINE__);                                                                  \
        struct timespec elapsed_time##__LINE__ = time_sub(measure_start_time##__LINE__, measure_estimated_time##__LINE__); \
        long elapsed##__LINE__ = time_to_microseconds(elapsed_time##__LINE__);                                             \
        printf("%s time: %ld micro seconds\n", name, elapsed##__LINE__ / runs);                                            \
    }                                                                                                                      \
    while (0);

#if defined(__cplusplus)
}
#endif

#endif