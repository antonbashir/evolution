#include <errors/error.h>
#include <system/system.h>

struct t
{
};

int main(int argc, char const* argv[])
{
    struct error* err = core_error(error_new("test",
                                             error_field("test 0", false),
                                             error_field("test b", true),
                                             error_field("test 1", 123),
                                             error_field("test 2", 456),
                                             error_field("test 3", -456),
                                             error_field("test 4", 456.135),
                                             error_field("test 5", "test")));
    const char* fmt = error_format(err);
    printf("%s\n", fmt);
    error_print(core_error(error_system(ENOMEM)));
    error_raise(err);
    return 0;
}
