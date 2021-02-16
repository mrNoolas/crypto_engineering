.syntax unified
.cpu cortex-m4

.global load_test
.type load_test, %function
load_test:
    // =============== load_littleendian Somewhat more efficient implementation =====================
    // Our function header in C: extern uint32 load_test(const unsigned char *x);
    // r0 contains &x

    // Argument is placed in r0, the return value should go in r0.

    // use a pointer to load value from memory:
    // load data of pointer r0 in to r1
    ldr r1, [r0] // r1 = x


    ldrb r2, [r1, #0] //load x[0] in to r2 from array r1 position 0

    add r2, #1

    mov r1, r2

    // write the result back to memory:
    str r1, [r0]

    bx lr
