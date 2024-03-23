#include "time/time.h"
#define SIMPLE_MAP_SOURCE
#include "maps.h"

void reverse(char s[])
{
    int i, j;
    char c;

    for (i = 0, j = strlen(s) - 1; i < j; i++, j--)
    {
        c = s[i];
        s[i] = s[j];
        s[j] = c;
    }
}

void itoa(int n, char* s)
{
    int i, sign;

    if ((sign = n) < 0) /* record sign */
        n = -n;         /* make n positive */
    i = 0;
    do
    {                          /* generate digits in reverse order */
        s[i++] = n % 10 + '0'; /* get next digit */
    }
    while ((n /= 10) > 0); /* delete it */
    if (sign < 0)
        s[i++] = '-';
    s[i] = '\0';
    reverse(s);
}

static void FORCEINLINE bench()
{
    struct simple_map_strings_t* map = simple_map_strings_new();
    for (size_t i = 0; i < 100000; i++)
    {
        char key[16];
        char value[16];
        itoa(i, key);
        itoa(i + 1, value);
        struct strings_pair node = {.key = strdup(key), .value = strdup(value)};
        simple_map_strings_put_copy(map, &node, NULL, NULL);
        simple_map_int_t slot = simple_map_strings_find(map, key, NULL);
        const char* found = simple_map_strings_node(map, slot)->value;
    }

    double elapsed = time_measure(100, {
        const char* key = "0";
        simple_map_int_t slot = simple_map_strings_find(map, key, NULL);
        while (slot != simple_map_end(map))
        {
            key = simple_map_strings_node(map, slot)->value;
            slot = simple_map_strings_find(map, key, NULL);
        }
    });
    printf("elapsed: %.15f [ns]\n", (elapsed * 1000) / (100000));
}

int main(int argc, char const* argv[])
{
    bench();
    return 0;
}