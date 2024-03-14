#ifndef TARANTOOL_LAUNCHER_H
#define TARANTOOL_LAUNCHER_H

#include <common/common.h>
#include <stdint.h>

#if defined(__cplusplus)
extern "C"
{
#endif
DART_LEAF_FUNCTION void tarantool_launcher_launch(char* binary_path);
DART_LEAF_FUNCTION void tarantool_launcher_shutdown(int32_t code);
#if defined(__cplusplus)
}
#endif

#endif