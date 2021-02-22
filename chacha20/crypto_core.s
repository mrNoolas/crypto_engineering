.syntax unified
.cpu cortex-m4

.global cryptocore 

# We need to allocate memory for x's, and initialise it together with the out. 
# allocate 16 uint32's: 16*4 = 64 bytes (block size)
# No need to initialise, this is done later together with the j's / out array
.data
xarray: .skip 64
.text

.type  cryptocore, %function
cryptocore:
    # =============== crypto core somewhat more efficient ===================
    # function header in C: uint32 cryptocore(char *out, char *in, char *key, char *c);
    # r0 is a pointer to the out array: 16 times 32 bits (16 words)
    # r1 is a pointer to in; 16 chars (16 bytes) (4 words)
    # r2 is a pointer to the key array (32 chars/bytes) (8 words)
    # r3 is a pointer to the sigma/c/offset: (16 chars/bytes) (4 words)
    # The total block length is 64 bytes.

    # Let's first get some room to work in the registers by saving the values in there:
    push {r4-r11}

    adr r12, xarray
    sub r12, #64	// align pointer with start of memory block

    # instead of using 16 separate j's as in the example, we write directly to out to save memory operations
    ldm r3, {r4-r7} 	// load c[0], c[1], c[2], c[3] into r4 to r7
    ldm r2!, {r8-r11}    // load key[0], ..., key[3] into r8 to r11 
    
    # byte reverse the registers we got, (load_littleendian(...))
    rev r4, r4
    rev r5, r5
    rev r6, r6
    rev r7, r7
    rev r8, r8
    rev r9, r9
    rev r10, r10
    rev r11, r11

    stm r12, {r4-r11}	// store in x[0] to x[7]
    stm r0!, {r4-r11}   // store in out[0] to out[7]

    ldm r2, {r4-r7}	    // load key[4], ..., key[7] into r4 to r7
    ldm r1, {r8-r11}    // load in[0], ..., in[3] into r8 to r11
    sub r2, #16		    // reset pointer to start of key
    
    # byte reverse the registers we got, (load_littleendian(...))
    # TODO: rev and load directly into useful register
    rev r4, r4
    rev r5, r5
    rev r6, r6
    rev r7, r7
    rev r8, r8
    rev r9, r9
    rev r10, r10
    rev r11, r11

    # only store in out; for x it is moved directly into the rounds.
    stm r0, {r4-r11}   // store in out[8] to out[15]
    sub r0, #32		// reset pointer to start of out


    //push {r1-r3} # r1 to r3 are not needed anymore, so can be overwritten.
    push {r0}
    
    # ===================================================================================================
    # TODO: r12 = xarray --> assumption of doubleround
    # ROUNDS = 20
    # ============ loop over fullround
    # for (i = rounds; i > 0; i -= 2) fullround(x);  --> fullround is a double round here 
    
    # store and use some other values we have around now anyway to save loads and stores
    // r10 = x14
    // r11 = x15
    mov r2, r4          // r2 = x8
    mov r3, r8 	        // r3 = x12  
    mov r8, r7          // r8 = x11  store for later use 
    mov r6, r5 	        // r6 = x9  
    mov r7, r9 	        // r7 = x13 
    mov r9, r6          // r9 = x10  store for later use  
    
    # Quarter round 1.1 and 1.2:
    # use pointer to load values from memory:
    ldr r0, [r12]    	// r0 = x0
    ldr r1, [r12, #16] 	// r1 = x4
    ldr r4, [r12, #4]  	// r4 = x1
    ldr r5, [r12, #20] 	// r5 = x5

    # two quarter rounds (more info in quarterround/quarterround.s)
    add r0, r1  	        	// *a = *a + *b
    add r4, r5  		        // *a = *a + *b
    eor r3, r0  	        	// *d = *d ^ *a
    eor r7, r4  		        // *d = *d ^ *a
    add r2, r2, r3, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r2 		        	// *b = *b ^ c
    eor r5, r6 			        // *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    add r4, r4, r5, ror #20  	// *a = *a + *b
    eor r3, r0, r3, ror #16  	// *d = *d ^ a
    eor r7, r4, r7, ror #16  	// *d = *d ^ a
    add r2, r2, r3, ror #24	    // *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r2, r1, ror #20 	// *b = *b ^ c
    eor r5, r6, r5, ror #20 	// *b = *b ^ c
    
    # r1 and r7 are rotated in the next round
    # r3 and r5 are rotated in a move later
    # write some of the results back to memory:
    str r2, [r12, #32] 	// r2 = x8
    str r6, [r12, #36] 	// r6 = x9
    
    str r7, [r12, #52] 	// r7 = x13
    str r1, [r12, #16] 	// r1 = x4


    # Quarter round 1.3 and 1.4:
    # load everything thats still around and store some things for later    
    mov r2, r9 	        // r2 = x10
    ror r9, r3, #24     // r9 = x12, does rotate and move together
    mov r3, r10  	    // r3 = x14
    mov r6, r8 	        // r6 = x11
    mov r7, r11 	    // r7 = x15
    mov r8, r0          // r8 = x0
    ror r10, r5, #25    // r10 = x5, does rotate and move together
    mov r11, r4         // r11 = x1
    
    # use pointer to load values from memory:
    ldr r0, [r12, #8]  	// r0 = x2
    ldr r1, [r12, #24] 	// r1 = x6    
    ldr r4, [r12, #12] 	// r4 = x3
    ldr r5, [r12, #28] 	// r5 = x7 

    # two quarter rounds (more info in quarterround/quarterround.s)
    add r0, r1  	        	// *a = *a + *b
    add r4, r5  		        // *a = *a + *b
    eor r3, r0  	        	// *d = *d ^ *a
    eor r7, r4  		        // *d = *d ^ *a
    add r2, r2, r3, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r2 		        	// *b = *b ^ c
    eor r5, r6 			        // *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    add r4, r4, r5, ror #20  	// *a = *a + *b
    eor r3, r0, r3, ror #16  	// *d = *d ^ a
    eor r7, r4, r7, ror #16  	// *d = *d ^ a
    add r2, r2, r3, ror #24	    // *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r2, r1, ror #20 	// *b = *b ^ c
    eor r5, r6, r5, ror #20 	// *b = *b ^ c
    
    # r1, r3, r5 and r7 are rotated in a move later

    # swap some registers to prepare for round 2:
    # r2 and r6 should stay where they are for round 2  (r2 = x10; r6 = x11)
    mov r1, r10         // r1  = x5
    mov r10, r0         // r10 = x2
    mov r0, r8          // r0  = x0
    ror r8, r3, #24     // r8  = x14, does rotate and move together
    ror r3, r7, #24     // r3  = x15
    mov r7, r9          // r7  = x12
    mov r9, r4          // r9  = x3
    mov r4, r11         // r4  = x1
    ror r11, r5, #25    // r11 = x7, does rotate and move together
    ror r5, r1, #25     // r5  = x6
    
    
    # =======================================================
    # Quarter round 2.1 and 2.2:
    # two quarter rounds (more info in quarterround/quarterround.s)
    add r0, r1  	        	// *a = *a + *b
    add r4, r5  		        // *a = *a + *b
    eor r3, r0  	        	// *d = *d ^ *a
    eor r7, r4  		        // *d = *d ^ *a
    add r2, r2, r3, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r2 		        	// *b = *b ^ c
    eor r5, r6 			        // *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    add r4, r4, r5, ror #20  	// *a = *a + *b
    eor r3, r0, r3, ror #16  	// *d = *d ^ a
    eor r7, r4, r7, ror #16  	// *d = *d ^ a
    add r2, r2, r3, ror #24	    // *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r2, r1, ror #20 	// *b = *b ^ c
    eor r5, r6, r5, ror #20 	// *b = *b ^ c
    
    ror r3, r3, #24
    ror r5, r5, #25
    # r1 and r7 are rotated in a move later
    
    # write some of the results back to memory:
    str r2, [r12, #40] 	// r2 = x10
    str r3, [r12, #60] 	// r3 = x15
    str r5, [r12, #24] 	// r5 = x6
    str r6, [r12, #44] 	// r6 = x11 
    
    # Shift some registers around to prepare for the next round
    # In round 3.1 and 3.2 we need: x0, x1, x4, x5, x8, x9, x12 and x13
    # We still have around: r8 = x14; r9 = x3; r10 = x2; r11 = x7 
    mov r2, r0          // temporarily use r2 as a swap register
    mov r0, r10         // r0 = x2
    mov r10, r4         // r10 = x1
    mov r4, r9          // r4 = x3
    ror r9, r1, #25     // r9 = x5, does rotate and move together
    mov r1, r11         // r1 = x7
    ror r11, r7, #24    // r11 = x12    
    mov r7, r8          // r7 = x14
    mov r8, r2          // r8 = x0

    # Quarter round 2.3 and 2.4:
    # use pointer to load values from memory:
    ldr r2, [r12, #32] 	// r2 = x8
    ldr r3, [r12, #52] 	// r3 = x13, still needs to rotate 24, done in first eor
    ldr r5, [r12, #16] 	// r5 = x4, still needs to rotate 25
    ldr r6, [r12, #36] 	// r6 = x9
    
    ror r5, r5, #25     // TODO: merge this into the calculating instructions

    # two quarter rounds (more info in quarterround/quarterround.s)
    add r0, r1  	        	// *a = *a + *b
    add r4, r5  		        // *a = *a + *b
    eor r3, r0, r3, ror #24   	// *d = *d ^ *a
    eor r7, r4                  // *d = *d ^ *a
    add r2, r2, r3, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r2 		        	// *b = *b ^ c
    eor r5, r6 			        // *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    add r4, r4, r5, ror #20  	// *a = *a + *b
    eor r3, r0, r3, ror #16  	// *d = *d ^ a
    eor r7, r4, r7, ror #16  	// *d = *d ^ a
    add r2, r2, r3, ror #24	    // *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r2, r1, ror #20 	// *b = *b ^ c
    eor r5, r6, r5, ror #20 	// *b = *b ^ c
    
    ror r7, r7, #24
    ror r3, r3, #24
    ror r5, r5, #25
    ror r1, r1, #25
    
    # write the results back to memory:
    str r0, [r12, #8]  	// r0 = x2
    str r1, [r12, #28] 	// r1 = x7
    str r2, [r12, #32] 	// r2 = x8
    str r3, [r12, #52] 	// r3 = x13
    
    str r4, [r12, #12] 	// r4 = x3
    str r5, [r12, #16] 	// r5 = x4
    str r6, [r12, #36] 	// r6 = x9
    str r7, [r12, #56] 	// r7 = x14
    
    
    # ===================================================================================================

    pop {r0}
    push {r12}		// Temporarily store the pointer to x; this saves a round of loads.

    ldm r0, {r1-r6}	// load out[0] to out[5] into r1-r6 (loads the j's)
    ldm r12, {r7-r12}   // load x[0] to x[5] into r7-r12 
    add r1, r7
    add r2, r8
    add r3, r9
    add r4, r10
    add r5, r11
    add r6, r12 
 
    # byte reverse the registers we got, (store_littleendian(...))
    rev r1, r1
    rev r2, r2
    rev r3, r3
    rev r4, r4
    rev r5, r5
    rev r6, r6

    stm r0!, {r1-r6}   // store in out[0] to out[5]

    pop {r12} 		// r12 = pointer to xarray 
    ldm r0, {r1-r5}    // load out[6] to out[10] into r1-r5
    add r12, #24	// offset the pointer to x by 6 words
    ldm r12!, {r6-r10}  // load x[6] to x[10] into r6-r10 

    add r1, r7
    add r2, r8
    add r3, r9
    add r4, r10
    add r5, r11
    
    # byte reverse the registers we got, (store_littleendian(...))
    rev r1, r1
    rev r2, r2
    rev r3, r3
    rev r4, r4
    rev r5, r5

    stm r0!, {r1-r5}   // store in out[6] to out[10]

    ldm r0, {r1-r5}    // load out[6] to out[10] into r1-r5
    ldm r12!, {r6-r10}  // load x[6] to x[10] into r6-r10 

    add r1, r7
    add r2, r8
    add r3, r9
    add r4, r10
    add r5, r11
    
    # byte reverse the registers we got, (store_littleendian(...))
    rev r1, r1
    rev r2, r2
    rev r3, r3
    rev r4, r4
    rev r5, r5

    stm r0!, {r1-r5}   // store in out[6] to out[10]
    
    # substract 64 from r0 and r12 if they are needed beyond here

    mov r0, #0 		// return 0
    
    # Restore the registers before return:
    // pop {r1-r3}
    pop {r4-r11}
    bx lr 






















doubleround:
    # =============== Quarter Round Somewhat more efficient implementation =====================
    # Our function header in C: void doubleround(uint32 *a);
    # r0 contains &a, pointer to first argument of the list; 15 others directly follow that address.

    mov r12, r0 // keep r0 around for later reference...

    # This subroutine uses r0 to r7. It assumes that these are freed up by cryptocore.
    # We need r0 to r7, so push r4-r7 to the stack to preserve them.
    // push {r4-r7}


    # Quarter round 1.1 and 1.2:
    # use pointer to load values from memory:
    ldr r0, [r12]    	// r0 = x0
    ldr r1, [r12, #16] 	// r1 = x4
    ldr r2, [r12, #32] 	// r2 = x8
    ldr r3, [r12, #48] 	// r3 = x12
    
    ldr r4, [r12, #4]  	// r4 = x1
    ldr r5, [r12, #20] 	// r5 = x5
    ldr r6, [r12, #36] 	// r6 = x9
    ldr r7, [r12, #52] 	// r7 = x13

    # two quarter rounds (more info in quarterround/quarterround.s)
    add r0, r1  	        	// *a = *a + *b
    add r4, r5  		        // *a = *a + *b
    eor r3, r0  	        	// *d = *d ^ *a
    eor r7, r4  		        // *d = *d ^ *a
    add r2, r2, r3, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r2 		        	// *b = *b ^ c
    eor r5, r6 			        // *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    add r4, r4, r5, ror #20  	// *a = *a + *b
    eor r3, r0, r3, ror #16  	// *d = *d ^ a
    eor r7, r4, r7, ror #16  	// *d = *d ^ a
    add r2, r2, r3, ror #24	    // *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r2, r1, ror #20 	// *b = *b ^ c
    eor r5, r6, r5, ror #20 	// *b = *b ^ c
    
    ror r3, r3, #24
    ror r7, r7, #24
    ror r1, r1, #25
    ror r5, r5, #25

    # write the results back to memory:
    str r0, [r12]    	// r0 = x0
    str r1, [r12, #16] 	// r1 = x4
    str r2, [r12, #32] 	// r2 = x8
    str r3, [r12, #48] 	// r3 = x12
    
    str r4, [r12, #4]  	// r4 = x1
    str r5, [r12, #20] 	// r5 = x5
    str r6, [r12, #36] 	// r6 = x9
    str r7, [r12, #52] 	// r7 = x13


    # Quarter round 1.3 and 1.4:
    # use pointer to load values from memory:
    ldr r0, [r12, #8]  	// r0 = x2
    ldr r1, [r12, #24] 	// r1 = x6
    ldr r2, [r12, #40] 	// r2 = x10
    ldr r3, [r12, #56] 	// r3 = x14
    
    ldr r4, [r12, #12] 	// r4 = x3
    ldr r5, [r12, #28] 	// r5 = x7
    ldr r6, [r12, #44] 	// r6 = x11
    ldr r7, [r12, #60] 	// r7 = x15

    # two quarter rounds (more info in quarterround/quarterround.s)
    add r0, r1  	        	// *a = *a + *b
    add r4, r5  		        // *a = *a + *b
    eor r3, r0  	        	// *d = *d ^ *a
    eor r7, r4  		        // *d = *d ^ *a
    add r2, r2, r3, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r2 		        	// *b = *b ^ c
    eor r5, r6 			        // *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    add r4, r4, r5, ror #20  	// *a = *a + *b
    eor r3, r0, r3, ror #16  	// *d = *d ^ a
    eor r7, r4, r7, ror #16  	// *d = *d ^ a
    add r2, r2, r3, ror #24	    // *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r2, r1, ror #20 	// *b = *b ^ c
    eor r5, r6, r5, ror #20 	// *b = *b ^ c
    
    ror r7, r7, #24
    ror r3, r3, #24
    ror r5, r5, #25
    ror r1, r1, #25

    # write the results back to memory:
    str r0, [r12, #8]  	// r0 = x2
    str r3, [r12, #56] 	// r3 = x14
    
    str r4, [r12, #12] 	// r4 = x3
    str r5, [r12, #28] 	// r5 = x7


    # r2 and r6 should stay where they are for round 2  (r2 = x10; r6 = x11)
    mov r5, r1 	// r5 = x6
    mov r3, r7  // r3 = x15
    
    
    # =======================================================
    # Quarter round 2.1 and 2.2:
    # use pointer to load values from memory:
    ldr r0, [r12]    	// r0 = x0
    ldr r1, [r12, #20] 	// r1 = x5
    
    ldr r4, [r12, #4]  	// r4 = x1
    ldr r7, [r12, #48] 	// r7 = x12

    # two quarter rounds (more info in quarterround/quarterround.s)
    add r0, r1  	        	// *a = *a + *b
    add r4, r5  		        // *a = *a + *b
    eor r3, r0  	        	// *d = *d ^ *a
    eor r7, r4  		        // *d = *d ^ *a
    add r2, r2, r3, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r2 		        	// *b = *b ^ c
    eor r5, r6 			        // *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    add r4, r4, r5, ror #20  	// *a = *a + *b
    eor r3, r0, r3, ror #16  	// *d = *d ^ a
    eor r7, r4, r7, ror #16  	// *d = *d ^ a
    add r2, r2, r3, ror #24	    // *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r2, r1, ror #20 	// *b = *b ^ c
    eor r5, r6, r5, ror #20 	// *b = *b ^ c
    
    ror r7, r7, #24
    ror r3, r3, #24
    ror r5, r5, #25
    ror r1, r1, #25

    # write the results back to memory:
    str r0, [r12]    	// r0 = x0
    str r1, [r12, #20] 	// r1 = x5
    str r2, [r12, #40] 	// r2 = x10
    str r3, [r12, #60] 	// r3 = x15
    
    str r4, [r12, #4]  	// r4 = x1
    str r5, [r12, #24] 	// r5 = x6
    str r6, [r12, #44] 	// r6 = x11
    str r7, [r12, #48] 	// r7 = x12   



    # Quarter round 2.3 and 2.4:
    # use pointer to load values from memory:
    ldr r0, [r12, #8]  	// r0 = x2
    ldr r1, [r12, #28] 	// r1 = x7
    ldr r2, [r12, #32] 	// r2 = x8
    ldr r3, [r12, #52] 	// r3 = x13
    
    ldr r4, [r12, #12] 	// r4 = x3
    ldr r5, [r12, #16] 	// r5 = x4
    ldr r6, [r12, #36] 	// r6 = x9
    ldr r7, [r12, #56] 	// r7 = x14
    
    # retrieve the four we stored earlier:
    //mov r0, r8  // r0 = x2
    //mov r7, r9  // r7 = x14
    //mov r4, r10 // r4 = x3
    //mov r1, r11 // r1 = x7

    # two quarter rounds (more info in quarterround/quarterround.s)
    add r0, r1  	        	// *a = *a + *b
    add r4, r5  		        // *a = *a + *b
    eor r3, r0  	        	// *d = *d ^ *a
    eor r7, r4  		        // *d = *d ^ *a
    add r2, r2, r3, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r2 		        	// *b = *b ^ c
    eor r5, r6 			        // *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    add r4, r4, r5, ror #20  	// *a = *a + *b
    eor r3, r0, r3, ror #16  	// *d = *d ^ a
    eor r7, r4, r7, ror #16  	// *d = *d ^ a
    add r2, r2, r3, ror #24	    // *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r2, r1, ror #20 	// *b = *b ^ c
    eor r5, r6, r5, ror #20 	// *b = *b ^ c
    
    ror r7, r7, #24
    ror r3, r3, #24
    ror r5, r5, #25
    ror r1, r1, #25
    
    # write the results back to memory:
    str r0, [r12, #8]  	// r0 = x2
    str r1, [r12, #28] 	// r1 = x7
    str r2, [r12, #32] 	// r2 = x8
    str r3, [r12, #52] 	// r3 = x13
    
    str r4, [r12, #12] 	// r4 = x3
    str r5, [r12, #16] 	// r5 = x4
    str r6, [r12, #36] 	// r6 = x9
    str r7, [r12, #56] 	// r7 = x14


    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r7}
    bx lr

