#ifndef TARANTOOL_LAUNCHER_H
#define TARANTOOL_LAUNCHER_H

#if defined(__cplusplus)
extern "C"
{
#endif
    void tarantool_launcher_launch(char* binary_path);
    void tarantool_launcher_shutdown(int code);
#if defined(__cplusplus)
}
#endif

#endif