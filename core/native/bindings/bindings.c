#define DART_EXPORT
#include <context/context.h>

extern struct context* context_get();
extern void system_shutdown_descriptor(int32_t fd);

#undef DART_EXPORT