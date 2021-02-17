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
    push {r4-r7}

    # use pointers to load values from memory:
    ldr r4, [r0] // r4 = a
    ldr r5, [r1] // r5 = b
    ldr r6, [r2] // r6 = c
    ldr r7, [r3] // r7 = d

    # first part of quarterround:
    add r4, r5  	// *a = *a + *b
    eor r7, r4  	// *d = *d ^ *a
    # rotate of r7 is done later using barrel shifter

    # second part of quarterround:
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r5, r6 			// *b = *b ^ c
    # rotate of r5 is done later using barrel shifter

    # third part of quarterround:
    add r4, r4, r5, ror #20  	// *a = *a + *b
    eor r7, r4, r7, ror #16  	// *d = *d ^ a

    # fourth part of quarterround:
    add r6, r6, r7, ror #24	// *c = *c + *d
    eor r5, r6, r5, ror #20 	// *b = *b ^ c

    ror r7, r7, #24
    ror r5, r5, #25

    # write the results back to memory:
    str r4, [r0]
    str r5, [r1]
    str r6, [r2]
    str r7, [r3] 

    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r7}
    bx lr

