#ifndef EXECUTOR_CONSTANTS_H
#define EXECUTOR_CONSTANTS_H

#if defined(__cplusplus)
extern "C"
{
#endif

#define EXECUTOR_DART_CALLBACK 1 << 0
#define EXECUTOR_NATIVE_CALLBACK 1 << 1
#define EXECUTOR_DART_CALL 1 << 2
#define EXECUTOR_NATIVE_CALL 1 << 3

#define EXECUTOR_STATE_STOPPED 1 << 0
#define EXECUTOR_STATE_IDLE 1 << 1
#define EXECUTOR_STATE_WAKING 1 << 2

#define EXECUTOR_ERROR_NOTIFIER_POST 0
#define EXECUTOR_ERROR_RING_FULL -1

#define EXECUTOR_SCOPE_NOTIFIER "notifier"

#if defined(__cplusplus)
}
#endif

#endif