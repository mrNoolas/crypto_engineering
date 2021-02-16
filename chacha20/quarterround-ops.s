.syntax unified
.cpu cortex-m4

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

    # move the pointers out of the way for now (TODO: optimise this for less moves)
    mov r4, r0
    mov r5, r1
    mov r6, r2
    mov r7, r3

    # use pointers to load values from memory:
    ldr r0, [r4]
    ldr r1, [r5]
    ldr r2, [r6]
    ldr r3, [r7] 

    add r0, r1  // *a = *a + *b
    eor r3, r0  // *d = *d ^ *a
    
    # Call rotate(*d, 16):
    push {r0-r2} // save a,b,c; d will be overwritten
    mov r0, r3 
    mov r1, #16
    bl rotate
    
    mov r3, r0 // save return value in d 
    pop {r0-r2} // restore other values
    

    
    # second part of quarterround:
    add r2, r3 // *c = *c + *d
    eor r1, r2 // *b = *b ^ *c
    
    # Call rotate(*b, 12):
    push {r0} // save a
    push {r2-r3} // save c and d b will be overwritten
    mov r0, r1 
    mov r1, #12
    bl rotate
    
    mov r1, r0 // save return value in d 
    pop {r2-r3} // restore other values
    pop {r0}



    # third part of quarterround:
    add r0, r1  // *a = *a + *b
    eor r3, r0  // *d = *d ^ *a
    
    # Call rotate(*d, 16):
    push {r0-r2} // save a,b,c; d will be overwritten
    mov r0, r3 
    mov r1, #8
    bl rotate
    
    mov r3, r0 // save return value in d 
    pop {r0-r2} // restore other values



    # fourth part of quarterround:
    add r2, r3 // *c = *c + *d
    eor r1, r2 // *b = *b ^ *c
    
    # Call rotate(*b, 12):
    push {r0} // save a
    push {r2-r3} // save c and d b will be overwritten
    mov r0, r1 
    mov r1, #7
    bl rotate
    
    mov r1, r0 // save return value in d 
    pop {r2-r3} // restore other values
    pop {r0}



    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr


rotate:
    # rotate function in asm
    # function header in c: uint32 rotate(uint32 a, int d)

    rotate:

    mov r2, r0        // duplicate input a into r2
    mov r3, #32       // prepare 32 for rotate
    sub r3, r1        // 32 - d

    lsr r0, r3        // t = a >> 32-d
    lsl r2, r1        // a <<= d

    orr r0, r2         // t | a  (== a | t)
    bx lr             // return r0
