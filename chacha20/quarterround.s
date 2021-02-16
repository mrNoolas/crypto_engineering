.syntax unified
.cpu cortex-m4

rotate:
    # rotate function in asm
    # function header in c: uint32 rotate(uint32 a, int d)
    mov r2, r0        // duplicate input a into r2
    mov r3, #32       // prepare 32 for rotate
    sub r3, r1        // 32 - d

    lsr r0, r3        // t = a >> 32-d
    lsl r2, r1        // a <<= d

    orr r0, r2         // t | a  (== a | t)
    bx lr             // return r0


.global quarterround
.type quarterround, %function
quarterround:
    # =============== Quarter Round Somewhat more efficient implementation =====================
    # Our function header in C: void quarterround(uint32 *a, uint32 *b, uint32 *c, uint32 *d);
    # r0 contains &a 
    # r1 contains &b    
    # r2 contains &c
    # r3 contains &d

    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}

    # use pointers to load values from memory:
    ldr r4, [r0] // r4 = a
    ldr r5, [r1] // r5 = b
    ldr r6, [r2] // r6 = c
    ldr r7, [r3] // r7 = d

    push {r0-r3} // make r0 to r3 free for calling the rotate function. Not used by this function itself.
    push {lr}
    
    # first part of quarterround:
    add r4, r5  // *a = *a + *b
    eor r7, r4  // *d = *d ^ a

    # Call rotate(d, 16):
    mov r0, r7
    mov r1, #16
    bl rotate 

    mov r7, r0 // save return value in d 

    # second part of quarterround:
    add r6, r7 // *c = *c + *d
    eor r5, r6 // *b = *b ^ c

    # Call rotate(b, 12):
    mov r0, r5
    mov r1, #12
    bl rotate

    mov r5, r0 // save return value in d 



    # third part of quarterround:
    add r4, r5  // *a = *a + *b
    eor r7, r4  // *d = *d ^ a

    # Call rotate(d, 8):
    mov r0, r7
    mov r1, #8
    bl rotate

    mov r7, r0 // save return value in d 


    # fourth part of quarterround:
    add r6, r7 // *c = *c + *d
    eor r5, r6 // *b = *b ^ c

    # Call rotate(b, 7):
    mov r0, r5
    mov r1, #7
    bl rotate

    mov r5, r0 // save return value in d 


    # restore address pointers
    pop {lr}
    pop {r0-r3} 

    # write the results back to memory:
    str r4, [r0]
    str r5, [r1]
    str r6, [r2]
    str r7, [r3] 

    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

