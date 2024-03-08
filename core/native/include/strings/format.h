#ifndef CORE_STRINGS_FORMAT_H
#define CORE_STRINGS_FORMAT_H

#include <common/common.h>
#include <common/library.h>
#include <common/modules.h>
#include <system/time.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#define time_format_local(time)                                                                                                         \
    ({                                                                                                                                  \
        char _buffer##__LINE__[31];                                                                                                     \
        char* _buffer_pointer##__LINE__ = _buffer##__LINE__;                                                                            \
        struct tm* _temporary_time##__LINE__ = localtime(&time.tv_sec);                                                                 \
        char _zone##__LINE__[7];                                                                                                        \
        strftime(_zone##__LINE__, 7, "%Z", _temporary_time##__LINE__);                                                                  \
        int length##__LINE__ = strftime(_buffer##__LINE__, 31, "%d-%m-%Y %H:%M:%S", _temporary_time##__LINE__);                         \
        long _time_as_micros##__LINE__ = time.tv_nsec / 1000;                                                                           \
        length##__LINE__ += snprintf(_buffer##__LINE__ + length##__LINE__, 31 - length##__LINE__, ".%04ld", _time_as_micros##__LINE__); \
        snprintf(_buffer##__LINE__ + length##__LINE__, 31 - length##__LINE__, " %s", _zone##__LINE__);                                  \
        _buffer_pointer##__LINE__;                                                                                                      \
    })

#define time_format_utc(time)                                                                                                           \
    ({                                                                                                                                  \
        char _buffer##__LINE__[31];                                                                                                     \
        char* _buffer_pointer##__LINE__ = _buffer##__LINE__;                                                                            \
        struct tm _temporary_time##__LINE__;                                                                                            \
        gmtime_r(&time.tv_sec, &_temporary_time##__LINE__);                                                                             \
        char _zone##__LINE__[7];                                                                                                        \
        strftime(_zone##__LINE__, 7, "%Z", &_temporary_time##__LINE__);                                                                 \
        int length##__LINE__ = strftime(_buffer##__LINE__, 31, "%d-%m-%Y %H:%M:%S", &_temporary_time##__LINE__);                        \
        long _time_as_micros##__LINE__ = time.tv_nsec / 1000;                                                                           \
        length##__LINE__ += snprintf(_buffer##__LINE__ + length##__LINE__, 31 - length##__LINE__, ".%04ld", _time_as_micros##__LINE__); \
        snprintf(_buffer##__LINE__ + length##__LINE__, 31 - length##__LINE__, " %s", _zone##__LINE__);                                  \
        _buffer_pointer##__LINE__;                                                                                                      \
    })

#if defined(__cplusplus)
}
#endif

#endif