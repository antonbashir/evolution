#include <events/events.h>
#include <system/system.h>

struct t
{
};

NOINLINE void func()
{
    struct error* err = core_error(error_new("test",
                                             error_field("test 0", false),
                                             error_field("test b", true),
                                             error_field("test 1", 123),
                                             error_field("test 2", 456),
                                             error_field("test 3", -456),
                                             error_field("test 4", 456.135),
                                             error_field("test 5", "test")));
    printf("test 5: %s\n", error_get_string(err, "test 5"));
    printf("%s", error_format(err));
    error_print(core_error(error_system(ENOMEM)));
    error_raise(err);
}

int main(int argc, char const* argv[])
{
    func();
    return 0;
}
