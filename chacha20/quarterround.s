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
    push {r4-r8}

    # use pointers to load values from memory:
    ldr r4, [r0] // r4 = a
    ldr r5, [r1] // r5 = b
    ldr r6, [r2] // r6 = c
    ldr r7, [r3] // r7 = d

    # first part of quarterround:
    add r4, r5  // *a = *a + *b
    eor r7, r4  // *d = *d ^ *a

    # Call rotate(d, 16):
    lsr r8, r7, #16        	// t = d >> (32 - 16)
    orr r7, r8, r7, lsl #16     // d = (d << 16) | t



    # second part of quarterround:
    add r6, r7 // *c = *c + *d
    eor r5, r6 // *b = *b ^ c

    # Call rotate(b, 12):
    lsr r8, r5, #20 		// t = b >> (32 - 12)
    orr r5, r8, r5, lsl #12     // b = (b << 12) | t



    # third part of quarterround:
    add r4, r5  // *a = *a + *b
    eor r7, r4  // *d = *d ^ a

    # Call rotate(d, 8):
    lsr r8, r7, #24       	// t = d >> (32 - 8)
    orr r7, r8, r7, lsl #8      // d = (d << 8) | t



    # fourth part of quarterround:
    add r6, r7 // *c = *c + *d
    eor r5, r6 // *b = *b ^ c

    # Call rotate(b, 7):
    lsr r8, r5, #25 		// t = b >> (32 - 7)
    orr r5, r8, r5, lsl #7      // b = (b << 7) | t



    # write the results back to memory:
    str r4, [r0]
    str r5, [r1]
    str r6, [r2]
    str r7, [r3] 

    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r8}
    bx lr

