#ifndef EXECUTOR_CONSTANTS_H
#define EXECUTOR_CONSTANTS_H

#if defined(__cplusplus)
extern "C"
{
#endif

#define EXECUTOR_CALL 1 << 0
#define EXECUTOR_CALLBACK 1 << 1

#define EXECUTOR_STATE_STOPPED 1 << 0
#define EXECUTOR_STATE_IDLE 1 << 1
#define EXECUTOR_STATE_WAKING 1 << 2

#define EXECUTOR_ERROR_RING_FULL -1

#define EXECUTOR_SCOPE_SCHEDULER "scheduler"

#if defined(__cplusplus)
}
#endif

#endif