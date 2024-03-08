#include <system/system.h>

struct t
{
};

int main(int argc, char const* argv[])
{
    struct t* pt = core_new(t);
    return 0;
}
