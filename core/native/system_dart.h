#ifndef SYSTEM_DART__H
#define SYSTEM_DART__H

#if defined(__cplusplus)
extern "C"
{
#endif
    const char* system_dart_error_to_string(int error);
    void system_dart_close_descriptor(int fd);
#if defined(__cplusplus)
}
#endif

#endif