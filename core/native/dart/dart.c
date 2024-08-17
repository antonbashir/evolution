#include "dart.h"
#include <dart_api.h>
#include "printer/printer.h"

Dart_Handle dart_from_string(const char* native)
{
    Dart_Handle result = Dart_NewStringFromUTF8((const uint8_t*)native, strlen(native));
    if (!dart_check_with_null(result)) return NULL;
    return result;
}

Dart_Handle dart_from_signed(int64_t native)
{
    Dart_Handle result = Dart_NewInteger(native);
    if (!dart_check_with_null(result)) return NULL;
    return result;
}

Dart_Handle dart_from_unsigned(uint64_t native)
{
    Dart_Handle result = Dart_NewIntegerFromUint64(native);
    if (!dart_check_with_null(result)) return NULL;
    return result;
}

Dart_Handle dart_from_bool(bool native)
{
    Dart_Handle result = Dart_NewBoolean(native);
    if (!dart_check_with_null(result)) return NULL;
    return result;
}

Dart_Handle dart_from_double(double native)
{
    Dart_Handle result = dart_from_double(native);
    if (!dart_check_with_null(result)) return NULL;
    return result;
}

const char* dart_to_string(Dart_Handle value, bool* ok)
{
    intptr_t length;
    Dart_StringUTF8Length(value, &length);
    if (!length) return NULL;
    const char* string = calloc(length, 1);
    if (!(*ok = dart_check(Dart_StringToCString(value, &string))))
    {
        free((void*)string);
        return NULL;
    }
    return string;
}

int64_t dart_to_signed(Dart_Handle value, bool* ok)
{
    int64_t result;
    *ok = dart_check(Dart_IntegerToInt64(value, &result));
    return result;
}

uint64_t dart_to_unsigned(Dart_Handle value, bool* ok)
{
    uint64_t result;
    *ok = dart_check(Dart_IntegerToUint64(value, &result));
    return result;
}

bool dart_to_bool(Dart_Handle value, bool* ok)
{
    bool result;
    *ok = dart_check(Dart_BooleanValue(value, &result));
    return result;
}

double dart_to_double(Dart_Handle value, bool* ok)
{
    double result;
    *ok = dart_check(Dart_DoubleValue(value, &result));
    return result;
}

Dart_Handle dart_get_file(const char* path)
{
    Dart_Handle library = Dart_LookupLibrary(dart_from_string(path));
    if (!dart_check_with_null(library)) return NULL;
    return library;
}

Dart_Handle dart_get_class(const char* file, const char* name)
{
    Dart_Handle library = dart_get_file(file);
    if (library == NULL) return NULL;
    Dart_Handle class = Dart_GetClass(library, dart_from_string(name));
    if (!dart_check_with_null(class)) return NULL;
    return class;
}

Dart_Handle dart_find_class(const char* name)
{
    intptr_t librariesCount;
    Dart_Handle libraries = Dart_GetLoadedLibraries();
    Dart_ListLength(libraries, &librariesCount);
    for (int libraryIndex = 0; libraryIndex < librariesCount; libraryIndex++)
    {
        Dart_Handle library = Dart_ListGetAt(libraries, libraryIndex);
        if (!dart_check_with_null(library)) continue;
        Dart_Handle class = Dart_GetClass(library, dart_from_string(name));
        if (Dart_IsNull(class) || Dart_IsError(class)) continue;
        return class;
    }
    return NULL;
}

Dart_Handle dart_call_static(const char* file, const char* class, const char* member, Dart_Handle* arguments)
{
    Dart_Handle type = dart_get_class(file, class);
    if (type == NULL) return NULL;
    Dart_Handle result = Dart_Invoke(type, dart_from_string(member), length_of(arguments), arguments);
    if (!dart_check(result)) return NULL;
    return result;
}

Dart_Handle dart_invoke(Dart_Handle owner, const char* member, Dart_Handle* arguments)
{
    Dart_Handle result = Dart_Invoke(owner, dart_from_string(member), length_of(arguments), arguments);
    if (!dart_check(result)) return NULL;
    return result;
}

Dart_Handle dart_call_constructor(Dart_Handle class, const char* constructor, Dart_Handle* arguments)
{
    Dart_Handle result = Dart_New(class, dart_from_string(constructor), length_of(arguments), arguments);
    if (!dart_check(result)) return NULL;
    return result;
}

Dart_Handle dart_new(Dart_Handle class, Dart_Handle* arguments, size_t arguments_count)
{
    Dart_Handle result = Dart_New(class, Dart_Null(), arguments_count, arguments);
    if (!dart_check(result)) return NULL;
    return result;
}

bool dart_check(Dart_Handle handle)
{
    if (Dart_IsError(handle))
    {
        Dart_PropagateError(handle);
        return false;
    }
    return true;
}

bool dart_check_with_null(Dart_Handle handle)
{
    if (Dart_IsError(handle))
    {
        Dart_PropagateError(handle);
        return false;
    }
    return !Dart_IsNull(handle);
}