.syntax unified
.cpu cortex-m4

.global load_littleendian
.type load_littleendian, %function
load_littleendian:
    // =============== load_littleendian Somewhat more efficient implementation =====================
    // Our function header in C: extern uint32 load_littleendian(const unsigned char *x);
    // r0 contains &x

    // Argument is placed in r0, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12}
    // push {lr} //push link register to the stack


    // use a pointer to load value from memory:
    // load data of pointer r0 in to r1
    ldr r1, [r0] // r1 = x


    ldrb r2, [r1, #0] //load x[0] in to r2 from array r1 position 0
    ldrb r3, [r1, #1] //load x[1] in to r3 from array r1 position 1
    ldrb r4, [r1, #2] //load x[2] in to r4 from array r1 position 2
    ldrb r5, [r1, #3] //load x[3] in to r5 from array r1 position 3

    lsl r3, #8  //logical shift left r3 x[1] with 8
    lsl r4, #16 //logical shift left r4 x[2] with 16
    lsl r5, #24 //logical shift left r5 x[3] with 24

    orr r2, r3  //bitwise or r2 x[0] with r3 x[1]
    orr r2, r4  //bitwise or r2|r3 x[0]|x[1] with r4 x[2]
    orr r2, r5  //bitwise or r2|r3|r4 x[0]|x[1]|x[2] with r5 x[3]

    mov r1, r2

    // write the result back to memory:
    str r1, [r0]

    // restore address pointers
    // pop {lr}

    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr
