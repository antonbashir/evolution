#ifndef EXECUTOR_CONSTANTS_H
#define EXECUTOR_CONSTANTS_H

#if defined(__cplusplus)
extern "C"
{
#endif

#define EXECUTOR_CALL 1 << 0
#define EXECUTOR_CALLBACK 1 << 1

#define EXECUTOR_STATE_PAUSED 1 << 0
#define EXECUTOR_STATE_IDLE 1 << 1
#define EXECUTOR_STATE_WAKING 1 << 2
#define EXECUTOR_STATE_STOPPING 1 << 3
#define EXECUTOR_STATE_STOPPED 1 << 4

#define EXECUTOR_ERROR_RING_FULL -1

#define EXECUTOR_SCOPE_SCHEDULER_POLLIN "scheduler.pollin"
#define EXECUTOR_SCOPE_SCHEDULER_UNREGISTER "scheduler.unregister"

#if defined(__cplusplus)
}
#endif

#endif