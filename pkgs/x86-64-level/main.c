#ifndef __GNUC__
#error "The GCC compiler is required!"
#endif

#include <stdio.h>

// We use fputs because it doesn't append a newline character.

int main() {
    if (__builtin_cpu_supports("x86-64-v4")) {
        fputs("4", stdout);
    } else if (__builtin_cpu_supports("x86-64-v3")) {
        fputs("3", stdout);
    } else if (__builtin_cpu_supports("x86-64-v2")) {
        fputs("2", stdout);
    } else if (__builtin_cpu_supports("x86-64")) {
        fputs("1", stdout);
    } else {
        fputs("unknown", stderr);
        return 1;
    }
}
