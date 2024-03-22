#ifndef CORE_DART_H
#define CORE_DART_H

#include <common/common.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

typedef struct _Dart_Handle* Dart_Handle;

#define DART_CORE_LOCAL_FILE "package:core/core/local.dart"
#define DART_CORE_LOCAL_EVENT_CLASS "LocalEvent"
#define DART_LOAD_FUNCTION "_load"
#define DART_PRODUCE_FUNCTION "_produce"

Dart_Handle dart_from_string(const char* native);
Dart_Handle dart_from_signed(int64_t native);
Dart_Handle dart_from_unsigned(uint64_t native);
Dart_Handle dart_from_bool(bool native);
Dart_Handle dart_from_double(double native);

const char* dart_to_string(Dart_Handle value, bool* ok);
int64_t dart_to_signed(Dart_Handle value, bool* ok);
uint64_t dart_to_unsigned(Dart_Handle value, bool* ok);
bool dart_to_bool(Dart_Handle value, bool* ok);
double dart_to_double(Dart_Handle value, bool* ok);

Dart_Handle dart_get_file(const char* path);
Dart_Handle dart_get_class(const char* file, const char* name);
Dart_Handle dart_find_class(const char* name);
Dart_Handle dart_call_static(const char* file, const char* class, const char* member, Dart_Handle* arguments, size_t arguments_count);
Dart_Handle dart_invoke(Dart_Handle owner, const char* member, Dart_Handle* arguments, size_t arguments_count);
Dart_Handle dart_call_constructor(Dart_Handle class, const char* constructor, Dart_Handle* arguments, size_t arguments_count);
Dart_Handle dart_new(Dart_Handle class, Dart_Handle* arguments, size_t arguments_count);
bool dart_check(Dart_Handle handle);
bool dart_check_with_null(Dart_Handle handle);

#if defined(__cplusplus)
}
#endif

#endif