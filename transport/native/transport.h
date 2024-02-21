#ifndef TRANSPORT_H_INCLUDED
#define TRANSPORT_H_INCLUDED

#include <stdbool.h>

typedef struct io_uring transport_io_uring;

#if defined(__cplusplus)
extern "C"
{
#endif
    void transport_cqe_advance(transport_io_uring* ring, int count);

    void transport_close_descriptor(int fd);
#if defined(__cplusplus)
}
#endif

#endif
