#ifndef MEDIATOR_CONSTANTS_H
#define MEDIATOR_CONSTANTS_H

#if defined(__cplusplus)
extern "C"
{
#endif

#define MEDIATOR_BUFFER_USED -1

#define MEDIATOR_DART_CALLBACK 1 << 0
#define MEDIATOR_NATIVE_CALLBACK 1 << 1
#define MEDIATOR_DART_CALL 1 << 2
#define MEDIATOR_NATIVE_CALL 1 << 3

#if defined(__cplusplus)
}
#endif

#endif