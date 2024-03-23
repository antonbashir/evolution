#ifndef CORE_STRINGS_FORMAT_H
#define CORE_STRINGS_FORMAT_H

#include <common/common.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#define time_format_local(time)                                                                                                     \
    ({                                                                                                                              \
        char _buffer##__LINE__[31];                                                                                                 \
        char* _buffer_pointer##__LINE__ = _buffer##__LINE__;                                                                        \
        struct tm* _temporary_time##__LINE__ = localtime(&time.tv_sec);                                                             \
        char _zone##__LINE__[7];                                                                                                    \
        strftime(_zone##__LINE__, 7, TIMEZONE_FORMAT, _temporary_time##__LINE__);                                                   \
        int length##__LINE__ = strftime(_buffer##__LINE__, 31, DATE_TIME_FORMAT, _temporary_time##__LINE__);                        \
        long _time_as_micros##__LINE__ = time.tv_nsec / 1000;                                                                       \
        snprintf(_buffer##__LINE__ + length##__LINE__, 31 - length##__LINE__, TIME_MICROSECONDS_FORMAT, _time_as_micros##__LINE__); \
        _buffer_pointer##__LINE__;                                                                                                  \
    })

#define time_format_utc(time)                                                                                                       \
    ({                                                                                                                              \
        char _buffer##__LINE__[31];                                                                                                 \
        char* _buffer_pointer##__LINE__ = _buffer##__LINE__;                                                                        \
        struct tm _temporary_time##__LINE__;                                                                                        \
        gmtime_r(&time.tv_sec, &_temporary_time##__LINE__);                                                                         \
        char _zone##__LINE__[7];                                                                                                    \
        strftime(_zone##__LINE__, 7, TIMEZONE_FORMAT, &_temporary_time##__LINE__);                                                  \
        int length##__LINE__ = strftime(_buffer##__LINE__, 31, DATE_TIME_FORMAT, &_temporary_time##__LINE__);                       \
        long _time_as_micros##__LINE__ = time.tv_nsec / 1000;                                                                       \
        snprintf(_buffer##__LINE__ + length##__LINE__, 31 - length##__LINE__, TIME_MICROSECONDS_FORMAT, _time_as_micros##__LINE__); \
        _buffer_pointer##__LINE__;                                                                                                  \
    })

#define time_format_local_with_zone(time)                                                                                                               \
    ({                                                                                                                                                  \
        char _buffer##__LINE__[31];                                                                                                                     \
        char* _buffer_pointer##__LINE__ = _buffer##__LINE__;                                                                                            \
        struct tm* _temporary_time##__LINE__ = localtime(&time.tv_sec);                                                                                 \
        char _zone##__LINE__[7];                                                                                                                        \
        strftime(_zone##__LINE__, 7, TIMEZONE_FORMAT, _temporary_time##__LINE__);                                                                       \
        int length##__LINE__ = strftime(_buffer##__LINE__, 31, DATE_TIME_FORMAT, _temporary_time##__LINE__);                                            \
        long _time_as_micros##__LINE__ = time.tv_nsec / 1000;                                                                                           \
        length##__LINE__ += snprintf(_buffer##__LINE__ + length##__LINE__, 31 - length##__LINE__, TIME_MICROSECONDS_FORMAT, _time_as_micros##__LINE__); \
        snprintf(_buffer##__LINE__ + length##__LINE__, 31 - length##__LINE__, SPACE STRING_FORMAT, _zone##__LINE__);                                    \
        _buffer_pointer##__LINE__;                                                                                                                      \
    })

#define time_format_utc_with_zone(time)                                                                                                                 \
    ({                                                                                                                                                  \
        char _buffer##__LINE__[31];                                                                                                                     \
        char* _buffer_pointer##__LINE__ = _buffer##__LINE__;                                                                                            \
        struct tm _temporary_time##__LINE__;                                                                                                            \
        gmtime_r(&time.tv_sec, &_temporary_time##__LINE__);                                                                                             \
        char _zone##__LINE__[7];                                                                                                                        \
        strftime(_zone##__LINE__, 7, TIMEZONE_FORMAT, &_temporary_time##__LINE__);                                                                      \
        int length##__LINE__ = strftime(_buffer##__LINE__, 31, DATE_TIME_FORMAT, &_temporary_time##__LINE__);                                           \
        long _time_as_micros##__LINE__ = time.tv_nsec / 1000;                                                                                           \
        length##__LINE__ += snprintf(_buffer##__LINE__ + length##__LINE__, 31 - length##__LINE__, TIME_MICROSECONDS_FORMAT, _time_as_micros##__LINE__); \
        snprintf(_buffer##__LINE__ + length##__LINE__, 31 - length##__LINE__, SPACE STRING_FORMAT, _zone##__LINE__);                                    \
        _buffer_pointer##__LINE__;                                                                                                                      \
    })

static inline char* unsigned_to_string(unsigned long long int val)
{
    static __thread char buf[22];
    snprintf(buf, sizeof(buf), "%lld", val);
    return buf;
}

static inline char* signed_to_string(long long int val)
{
    static __thread char buf[22];
    snprintf(buf, sizeof(buf), "%lld", val);
    return buf;
}



#if defined(__cplusplus)
}
#endif

#endif