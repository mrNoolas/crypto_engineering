.syntax unified
.cpu cortex-m4

.global fullround
.type fullround, %function
fullround:
    # =============== Quarter Round Somewhat more efficient implementation =====================
    # Our function header in C: void fullround(uint32 *a);
    # r0 contains &a, pointer to first argument of the list; 15 others directly follow that address.

    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    //push {r4-r7}

    mov r12, r0 // keep r0 around for later reference...

    # Quarter round 1.1:
    # use pointer to load values from memory:
    ldr r0, [r12]    	// r0 = x0
    ldr r1, [r12, #16] 	// r1 = x4
    ldr r2, [r12, #32] 	// r2 = x8
    ldr r3, [r12, #48] 	// r3 = x12

    # Quarter round (more info in quarterround/quarterround.s)
    add r0, r1  	        	// *a = *a + *b
    eor r3, r0  	        	// *d = *d ^ *a
    add r2, r2, r3, ror #16 	// *c = *c + *d
    eor r1, r2 		        	// *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    eor r3, r0, r3, ror #16  	// *d = *d ^ a
    add r2, r2, r3, ror #24	    // *c = *c + *d
    eor r1, r2, r1, ror #20 	// *b = *b ^ c

    ror r3, r3, #24
    ror r1, r1, #25

    # write the results back to memory:
    str r0, [r12]    	// r0 = x0
    str r1, [r12, #16] 	// r1 = x4
    str r2, [r12, #32] 	// r2 = x8
    str r3, [r12, #48] 	// r3 = x12



    # Quarter round 1.2:
    # use pointer to load values from memory:
    ldr r0, [r12, #4]  	// r0 = x1
    ldr r1, [r12, #20] 	// r1 = x5
    ldr r2, [r12, #36] 	// r2 = x9
    ldr r3, [r12, #52] 	// r3 = x13

    # Quarter round (more info in quarterround/quarterround.s)
    add r0, r1  		// *a = *a + *b
    eor r3, r0  		// *d = *d ^ *a
    add r2, r2, r3, ror #16 	// *c = *c + *d
    eor r1, r2 			// *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    eor r3, r0, r3, ror #16  	// *d = *d ^ a
    add r2, r2, r3, ror #24	// *c = *c + *d
    eor r1, r2, r1, ror #20 	// *b = *b ^ c

    ror r3, r3, #24
    ror r1, r1, #25

    # write the results back to memory:
    str r0, [r12, #4]  	// r0 = x1
    str r1, [r12, #20] 	// r1 = x5
    str r2, [r12, #36] 	// r2 = x9
    str r3, [r12, #52] 	// r3 = x13



    # Quarter round 1.3:
    # use pointer to load values from memory:
    ldr r0, [r12, #8]  	// r0 = x2
    ldr r1, [r12, #24] 	// r1 = x6
    ldr r2, [r12, #40] 	// r2 = x10
    ldr r3, [r12, #56] 	// r3 = x14

    # Quarter round (more info in quarterround/quarterround.s)
    add r0, r1  		// *a = *a + *b
    eor r3, r0  		// *d = *d ^ *a
    add r2, r2, r3, ror #16 	// *c = *c + *d
    eor r1, r2 			// *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    eor r3, r0, r3, ror #16  	// *d = *d ^ a
    add r2, r2, r3, ror #24	// *c = *c + *d
    eor r1, r2, r1, ror #20 	// *b = *b ^ c

    ror r3, r3, #24
    ror r1, r1, #25

    # write the results back to memory:
    str r0, [r12, #8]  	// r0 = x2
    str r1, [r12, #24] 	// r1 = x6
    str r2, [r12, #40] 	// r2 = x10
    str r3, [r12, #56] 	// r3 = x14



    # Quarter round 1.4:
    # use pointer to load values from memory:
    ldr r0, [r12, #12] 	// r0 = x3
    ldr r1, [r12, #28] 	// r1 = x7
    ldr r2, [r12, #44] 	// r2 = x11
    ldr r3, [r12, #60] 	// r3 = x15

    # Quarter round (more info in quarterround/quarterround.s)
    add r0, r1  		// *a = *a + *b
    eor r3, r0  		// *d = *d ^ *a
    add r2, r2, r3, ror #16 	// *c = *c + *d
    eor r1, r2 			// *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    eor r3, r0, r3, ror #16  	// *d = *d ^ a
    add r2, r2, r3, ror #24	// *c = *c + *d
    eor r1, r2, r1, ror #20 	// *b = *b ^ c

    ror r3, r3, #24
    ror r1, r1, #25

    # write the results back to memory:
    str r0, [r12, #12] 	// r0 = x3
    str r1, [r12, #28] 	// r1 = x7
    str r2, [r12, #44] 	// r2 = x11
    str r3, [r12, #60] 	// r3 = x15
    
    # =======================================================
    # Quarter round 2.1:
    # use pointer to load values from memory:
    ldr r0, [r12]    	// r0 = x0
    ldr r1, [r12, #20] 	// r1 = x5
    ldr r2, [r12, #40] 	// r2 = x10
    ldr r3, [r12, #60] 	// r3 = x15

    # Quarter round (more info in quarterround/quarterround.s)
    add r0, r1  	        	// *a = *a + *b
    eor r3, r0  	        	// *d = *d ^ *a
    add r2, r2, r3, ror #16 	// *c = *c + *d
    eor r1, r2 		        	// *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    eor r3, r0, r3, ror #16  	// *d = *d ^ a
    add r2, r2, r3, ror #24	    // *c = *c + *d
    eor r1, r2, r1, ror #20 	// *b = *b ^ c

    ror r3, r3, #24
    ror r1, r1, #25

    # write the results back to memory:
    str r0, [r12]    	// r0 = x0
    str r1, [r12, #20] 	// r1 = x5
    str r2, [r12, #40] 	// r2 = x10
    str r3, [r12, #60] 	// r3 = x15



    # Quarter round 2.2:
    # use pointer to load values from memory:
    ldr r0, [r12, #4]  	// r0 = x1
    ldr r1, [r12, #24] 	// r1 = x6
    ldr r2, [r12, #44] 	// r2 = x11
    ldr r3, [r12, #48] 	// r3 = x12

    # Quarter round (more info in quarterround/quarterround.s)
    add r0, r1  		// *a = *a + *b
    eor r3, r0  		// *d = *d ^ *a
    add r2, r2, r3, ror #16 	// *c = *c + *d
    eor r1, r2 			// *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    eor r3, r0, r3, ror #16  	// *d = *d ^ a
    add r2, r2, r3, ror #24	// *c = *c + *d
    eor r1, r2, r1, ror #20 	// *b = *b ^ c

    ror r3, r3, #24
    ror r1, r1, #25

    # write the results back to memory:
    str r0, [r12, #4]  	// r0 = x1
    str r1, [r12, #24] 	// r1 = x6
    str r2, [r12, #44] 	// r2 = x11
    str r3, [r12, #48] 	// r3 = x12



    # Quarter round 2.3:
    # use pointer to load values from memory:
    ldr r0, [r12, #8]  	// r0 = x2
    ldr r1, [r12, #28] 	// r1 = x7
    ldr r2, [r12, #32] 	// r2 = x8
    ldr r3, [r12, #52] 	// r3 = x13

    # Quarter round (more info in quarterround/quarterround.s)
    add r0, r1  		// *a = *a + *b
    eor r3, r0  		// *d = *d ^ *a
    add r2, r2, r3, ror #16 	// *c = *c + *d
    eor r1, r2 			// *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    eor r3, r0, r3, ror #16  	// *d = *d ^ a
    add r2, r2, r3, ror #24	// *c = *c + *d
    eor r1, r2, r1, ror #20 	// *b = *b ^ c

    ror r3, r3, #24
    ror r1, r1, #25

    # write the results back to memory:
    str r0, [r12, #8]  	// r0 = x2
    str r1, [r12, #28] 	// r1 = x7
    str r2, [r12, #32] 	// r2 = x8
    str r3, [r12, #52] 	// r3 = x13



    # Quarter round 2.4:
    # use pointer to load values from memory:
    ldr r0, [r12, #12] 	// r0 = x3
    ldr r1, [r12, #16] 	// r1 = x4
    ldr r2, [r12, #36] 	// r2 = x9
    ldr r3, [r12, #56] 	// r3 = x14

    # Quarter round (more info in quarterround/quarterround.s)
    add r0, r1  		// *a = *a + *b
    eor r3, r0  		// *d = *d ^ *a
    add r2, r2, r3, ror #16 	// *c = *c + *d
    eor r1, r2 			// *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    eor r3, r0, r3, ror #16  	// *d = *d ^ a
    add r2, r2, r3, ror #24	// *c = *c + *d
    eor r1, r2, r1, ror #20 	// *b = *b ^ c

    ror r3, r3, #24
    ror r1, r1, #25

    # write the results back to memory:
    str r0, [r12, #12] 	// r0 = x3
    str r1, [r12, #16] 	// r1 = x4
    str r2, [r12, #36] 	// r2 = x9
    str r3, [r12, #56] 	// r3 = x14


    # Finally, we restore the callee-saved register values and branch back.
    //pop {r4-r7}
    bx lr

