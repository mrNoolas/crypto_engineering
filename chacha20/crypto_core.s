.syntax unified
.cpu cortex-m4

.global cryptocore 

# We need to allocate memory for x's, and initialise it together with the out. 
# allocate 16 uint32's: 16*4 = 64 bytes (block size)
# No need to initialise, this is done later together with the j's / out array
.data
xarray: .skip 16*4
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

    # r12 = *x
    movw r12, #:lower16:xarray
    movt r12, #:upper16:xarray

    # Let's first get some room to work in the registers by saving the values in there:
    push {r4-r11}

    # instead of using 16 separate j's as in the example, we write directly to out to save memory operations
    ldm r3, {r4-r7} 	// load c[0], c[1], c[2], c[3] into r4 to r7
    ldm r2!, {r8-r11}    // load key[0], ..., key[3] into r8 to r11 

    stm r12, {r4-r11}	// store in x[0] to x[7]
    stm r0, {r4-r11}   // store in out[0] to out[7]

    ldm r2, {r4-r7}	    // load key[4], ..., key[7] into r4 to r7
    ldr r10, [r1]       // r10 = in + 0
    ldr r11, [r1, #4]   // r11 = in + 4
    ldr r8, [r1, #8]    // r8  = in + 8
    ldr r9, [r1, #12]   // r9  = in + 12

    # only store in out; for x it is moved directly into the rounds.
    // store in out[8] to out[15]
    str r4, [r0, #32]
    str r5, [r0, #36]
    str r6, [r0, #40]
    str r7, [r0, #44]
    str r8, [r0, #48]
    str r9, [r0, #52]
    str r10, [r0, #56]
    str r11, [r0, #60]
   
    //push {r1-r3} # r1 to r3 are not needed anymore, so can be overwritten.    
    push {r0}
    
    # ===================================================================================================
    # Start of 20 rounds
    # r4 = x8, r5 = x9, r6 = x10, r7= x11, r8 = x12, r9 = x13, r10 = x14, r11 = x15 
    
    # store and use some other values we have around now anyway to save loads and stores
    // r10 = x14 stored for later use
    // r11 = x15 stored for later use
    // c1 = r4 = x8
    // d1 = r8 = x12  
    // r7 = x11  stored for later use 
    // d2 = r9 = x13 
    // r6 = x10  stored for later use  
    // c2 = r5 = x9  
    
    # Quarter round 1.1 and 1.2:
    # use pointer to load values from memory:
    ldr r0, [r12]    	// a1 = r0 = x0
    ldr r1, [r12, #16] 	// b1 = r1 = x4
    ldr r2, [r12, #4]  	// a2 = r2 = x1
    ldr r3, [r12, #20] 	// b2 = r3 = x5
    # r0 = x0; r1 = x4; r2 = x1; r3 = x5; r4 = x8; r5 = x9; r6 = x10; r7 = x11; r8 = x12; r9 = x13; r10 = x14; r11 = x15

    # two quarter rounds (more info in quarterround/quarterround.s)
    add r0, r1  	        	// *a = *a + *b
    add r2, r3  		        // *a = *a + *b
    eor r8, r0  	        	// *d = *d ^ *a
    eor r9, r2  		        // *d = *d ^ *a
    add r4, r4, r8, ror #16 		// *c = *c + *d
    add r5, r5, r9, ror #16 		// *c = *c + *d
    eor r1, r4 		        	// *b = *b ^ c
    eor r3, r5 			        // *b = *b ^ c
    add r0, r0, r1, ror #20  		// *a = *a + *b
    add r2, r2, r3, ror #20  		// *a = *a + *b
    eor r8, r0, r8, ror #16  		// *d = *d ^ a
    eor r9, r2, r9, ror #16  		// *d = *d ^ a
    add r4, r4, r8, ror #24	    	// *c = *c + *d
    add r5, r5, r9, ror #24	    	// *c = *c + *d
    eor r1, r4, r1, ror #20 		// *b = *b ^ c
    eor r3, r5, r3, ror #20 		// *b = *b ^ c
    
    # r1 and r9 (x4, x13) are rotated in the next round
    # r8 and r3 are rotated in a move later
    # write some of the results back to memory:
    str r4, [r12, #32] 	// r4 = x8
    str r5, [r12, #36] 	// r5 = x9
    str r9, [r12, #52] 	// r9 = x13
    str r1, [r12, #16] 	// r1 = x4

    # Quarter round 1.3 and 1.4:
    # load everything thats still around and store some things for later    
    ldr r4, [r12, #12] 	// r4 = x3
    ldr r5, [r12, #28] 	// r5 = x7 
    ldr r9, [r12, #8]  	// r9 = x2
    ldr r1, [r12, #24] 	// r1 = x6    

    # r0 = x0; r1 = x6; r2 = x1; r3 = x5; r4 = x3; r5 = x7; r6 = x10; r7 = x11; r8 = x12; r9 = x2; r10 = x14; r11 = x15

    # two quarter rounds (more info in quarterround/quarterround.s)
    add r9, r1  	        	// *a = *a + *b
    add r4, r5  		        // *a = *a + *b
    eor r10, r9  	        	// *d = *d ^ *a
    eor r11, r4  		        // *d = *d ^ *a
    add r6, r6, r10, ror #16 		// *c = *c + *d
    add r7, r7, r11, ror #16 		// *c = *c + *d
    eor r1, r6 		        	// *b = *b ^ c
    eor r5, r7 			        // *b = *b ^ c
    add r9, r9, r1, ror #20  		// *a = *a + *b
    add r4, r4, r5, ror #20  		// *a = *a + *b
    eor r10, r9, r10, ror #16  		// *d = *d ^ a
    eor r11, r4, r11, ror #16  		// *d = *d ^ a
    add r6, r6, r10, ror #24	    	// *c = *c + *d
    add r7, r7, r11, ror #24	    	// *c = *c + *d
    eor r1, r6, r1, ror #20 		// *b = *b ^ c
    eor r5, r7, r5, ror #20 		// *b = *b ^ c
    
    # The processor optimises the remaining rotate instructions by itself:
    ror r5, r5, #25       // r5 = x7
    ror r1, r1, #25       // r1  = x6 

    # some registers to prepare for round 2:
    # r0 = x0; r1 = x6; r2 = x1; r3 = x5; r4 = x3; r5 = x7; r6 = x10; r7 = x11; r8 = x12; r9 = x2; r10 = x14; r11 = x15
    # =======================================================
    # Quarter round 2.1 and 2.2:
    # two quarter rounds (more info in quarterround/quarterround.s)
    add r0, r0, r3, ror #25                          // *a = *a + *b
    add r2, r1                          // *a = *a + *b
    eor r11, r0, r11, ror #24                      // *d = *d ^ *a
    eor r8, r2, r8, ror #24                          // *d = *d ^ *a
    add r6, r6, r11, ror #16     	// *c = *c + *d
    add r7, r7, r8, ror #16     	// *c = *c + *d
    eor r3, r6, r3, ror #25                          // *b = *b ^ c
    eor r1, r7                          // *b = *b ^ c
    add r0, r0, r3, ror #20     	// *a = *a + *b
    add r2, r2, r1, ror #20     	// *a = *a + *b
    eor r11, r0, r11, ror #16    	// *d = *d ^ a
    eor r8, r2, r8, ror #16     	// *d = *d ^ a
    add r6, r6, r11, ror #24   		// *c = *c + *d
    add r7, r7, r8, ror #24         	// *c = *c + *d
    eor r3, r6, r3, ror #20     	// *b = *b ^ c
    eor r1, r7, r1, ror #20     	// *b = *b ^ c

    # r11 and r1 are rotated in the next round
    // These rotates are optimised by the processor itself, so are left here intentionally.
    ror r3, r3, #25     // r3 = x5
    ror r8, r8, #24    // r8 = x12    

    # Quarter round 2.3 and 2.4:
    # Prepare for the next round
    # In round 3.1 and 3.2 we need: x0, x1, x4, x5, x8, x9, x12 and x13
    # r4 = x3; r2 = x0; r5 = x7; r10 = x14; r2 = x1; r9 = x2
    str r7, [r12, #44]  // r7 = x11 
    str r6, [r12, #40]  // r6 = x10
    str r11, [r12, #60] // r11 = x15
    str r1, [r12, #24]  // r1 = x6
    ldr r11, [r12, #32]  // r11 = x8
    ldr r7, [r12, #52]  // r7 = x13, still needs to rotate 24, done in first eor
    ldr r1, [r12, #16]  // r1 = x4, still needs to rotate 25
    ldr r6, [r12, #36]  // r6 = x9
    
    # r0 = x0; r1 = x4; r2 = x1; r3 = x5; r4 = x3; r5 = x7; r6 = x9; r7 = x13; r8 = x12; r9 = x2; r10 = x14; r11 = x8

    ror r1, r1, #25     // Doing this separetly is just as fast as or faster than a barrel rotate alternative. Dont know why...

    # two quarter rounds (more info in quarterround/quarterround.s)
    add r9, r5                          // *a = *a + *b
    add r4, r1                          // *a = *a + *b
    eor r7, r9, r7, ror #24             // *d = *d ^ *a
    eor r10, r4, r10, ror #24           // *d = *d ^ *a
    add r11, r11, r7, ror #16           // *c = *c + *d
    add r6, r6, r10, ror #16            // *c = *c + *d
    eor r5, r11                         // *b = *b ^ c
    eor r1, r6                          // *b = *b ^ c
    add r9, r9, r5, ror #20             // *a = *a + *b
    add r4, r4, r1, ror #20             // *a = *a + *b
    eor r7, r9, r7, ror #16             // *d = *d ^ a
    eor r10, r4, r10, ror #16           // *d = *d ^ a
    add r11, r11, r7, ror #24           // *c = *c + *d
    add r6, r6, r10, ror #24            // *c = *c + *d
    eor r5, r11, r5, ror #20            // *b = *b ^ c
    eor r1, r6, r1, ror #20             // *b = *b ^ c

    ror r1, r1, #25     // r1 = x4, rotate while we are at it
    ror r5, r5, #25     // r5 = x7, store for later use and rotate while we are at it

    # r0 = x0; r1 = x4; r2 = x1; r3 = x5; r4 = x3; r5 = x7; r6 = x9; r7 = x13; r8 = x12; r9 = x2; r10 = x14; r11 = x8
    # =======================================================
    # In round 3.1 and 3.2 we need: x0, x1, x4, x5, x8, x9, x12 and x13
    # We still have around: r0 = x0; r3 = x5; r2 = x1; r8 = x12
    # store and use some other values we have around now anyway to save loads and stores
    # r11 = x8; r6 = x9; r6 = x9; r0 = x0; r3 = x5; r8 = x12; r4 = x3; r2 = x1; r11 = x8; r9 = x2
    # r1 = x4; r5 = x7; r7 = x13; r10 = x14
    
    # two quarter rounds (more info in quarterround/quarterround.s)
    add r0, r1  	        	// *a = *a + *b
    add r2, r3  		        // *a = *a + *b
    eor r8, r0  	        	// *d = *d ^ *a
    eor r7, r2, r7, ror #24     // *d = *d ^ *a
    add r11, r11, r8, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r11 		        // *b = *b ^ c
    eor r3, r6 			        // *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    add r2, r2, r3, ror #20  	// *a = *a + *b
    eor r8, r0, r8, ror #16  	// *d = *d ^ a
    eor r7, r2, r7, ror #16  	// *d = *d ^ a
    add r11, r11, r8, ror #24	// *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r11, r1, ror #20 	// *b = *b ^ c
    eor r3, r6, r3, ror #20 	// *b = *b ^ c
    
    # r1 and r7 are rotated in the next round
    # r8 and r3 are rotated in a move later
    ror r3, r3, #25    // r3 = x5, store for later does rotate and move together
    ror r8, r8, #24     // r8 = x12, store for later does rotate and move together

    # In round 3.3 and 3.4 we need: x2, x3, x6, x7, x10, x11, x14 and x15
    # We still have around: r5 = x7; r4 = x3; r10 = x14; r9 = x2; r2 = x1; r10 = x14; r9 = x2 r0 = x0
    str r11, [r12, #32] 	// r11 = x8
    str r6, [r12, #36] 	// r6 = x9
    str r7, [r12, #52] 	// r7 = x13
    str r1, [r12, #16] 	// r1 = x4
    ldr r1, [r12, #24] 	// r1 = x6  still needs to be rotated by 25 
    ldr r11, [r12, #40]  // r11 = x10
    ldr r6, [r12, #44]  // r6 = x11
    ldr r7, [r12, #60]  // r7 = x15 still needs to be rotated by 24
    
    ror r1, r1, #25     // Doing this separetly is just as fast as or faster than a barrel rotate alternative. Dont know why...

    # two quarter rounds (more info in quarterround/quarterround.s)
    add r9, r1  	        	// *a = *a + *b
    add r4, r5  		        // *a = *a + *b
    eor r10, r9, r10, ror #24  	// *d = *d ^ *a
    eor r7, r4, r7, ror #24     // *d = *d ^ *a and does rotate of x15
    add r11, r11, r10, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r11 		        // *b = *b ^ c
    eor r5, r6 			        // *b = *b ^ c
    add r9, r9, r1, ror #20  	// *a = *a + *b
    add r4, r4, r5, ror #20  	// *a = *a + *b
    eor r10, r9, r10, ror #16  	// *d = *d ^ a
    eor r7, r4, r7, ror #16  	// *d = *d ^ a
    add r11, r11, r10, ror #24	// *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r11, r1, ror #20 	// *b = *b ^ c
    eor r5, r6, r5, ror #20 	// *b = *b ^ c
    
    ror r5, r5, #25    // r5 = x7
    ror r1, r1, #25    // r1  = x6

    # r11 = x10; r6 = x11; r0 = x0; r3 = x5; r8 = x12; r4 = x3; r2 = x1; r9 = x2; r1 = x6; r5 = x7; r7 = x15; r10 = x14        
    # =======================================================
    # Quarter round 4.1 and 4.2:
    # two quarter rounds (more info in quarterround/quarterround.s)
    add r0, r3  	        	// *a = *a + *b
    add r2, r1  		        // *a = *a + *b
    eor r7, r0, r7, ror #24    	// *d = *d ^ *a
    eor r8, r2  		        // *d = *d ^ *a
    add r11, r11, r7, ror #16 	// *c = *c + *d
    add r6, r6, r8, ror #16 	// *c = *c + *d
    eor r3, r11 		        	// *b = *b ^ c
    eor r1, r6 			        // *b = *b ^ c
    add r0, r0, r3, ror #20  	// *a = *a + *b
    add r2, r2, r1, ror #20  	// *a = *a + *b
    eor r7, r0, r7, ror #16  	// *d = *d ^ a
    eor r8, r2, r8, ror #16  	// *d = *d ^ a
    add r11, r11, r7, ror #24	    // *c = *c + *d
    add r6, r6, r8, ror #24	    // *c = *c + *d
    eor r3, r11, r3, ror #20 	// *b = *b ^ c
    eor r1, r6, r1, ror #20 	// *b = *b ^ c
    
    # r7 and r1 are rotated in next round
    ror r3, r3, #25     // r3 = x5, does rotate and move together
    ror r8, r8, #24    // r8 = x12    
    
    # Quarter round 4.3 and 4.4:
    # r10 = x14; r4 = x3; r9 = x2; r5 = x7; r0 = x0; r2 = x1; r5 = x7
    str r11, [r12, #40] 	// r11 = x10
    str r7, [r12, #60] 	// r7 = x15
    str r1, [r12, #24] 	// r1 = x6
    str r6, [r12, #44] 	// r6 = x11 
    ldr r11, [r12, #32] 	// r11 = x8
    ldr r7, [r12, #52] 	// r7 = x13, still needs to rotate 24, done in first eor
    ldr r1, [r12, #16] 	// r1 = x4, still needs to rotate 25
    ldr r6, [r12, #36] 	// r6 = x9

    ror r1, r1, #25     // Doing this separetly is just as fast as or faster than a barrel rotate alternative. Optimised by the processor. 

    # two quarter rounds (more info in quarterround/quarterround.s)
    add r9, r5  	        	// *a = *a + *b
    add r4, r1  		        // *a = *a + *b
    eor r7, r9, r7, ror #24   	// *d = *d ^ *a
    eor r10, r4, r10, ror #24   // *d = *d ^ *a
    add r11, r11, r7, ror #16 	// *c = *c + *d
    add r6, r6, r10, ror #16 	// *c = *c + *d
    eor r5, r11 		        	// *b = *b ^ c
    eor r1, r6 			        // *b = *b ^ c
    add r9, r9, r5, ror #20  	// *a = *a + *b
    add r4, r4, r1, ror #20  	// *a = *a + *b
    eor r7, r9, r7, ror #16  	// *d = *d ^ a
    eor r10, r4, r10, ror #16  	// *d = *d ^ a
    add r11, r11, r7, ror #24	    // *c = *c + *d
    add r6, r6, r10, ror #24	    // *c = *c + *d
    eor r5, r11, r5, ror #20 	// *b = *b ^ c
    eor r1, r6, r1, ror #20 	// *b = *b ^ c

    ror r1, r1, #25     // r1 = x4, rotate while we are at it
    ror r5, r5, #25     // r5 = x7, store for later use and rotate while we are at it

    # r10 = x14; r4 = x3; r9 = x2; r5 = x7; r0 = x0; r2 = x1; r5 = x7; r11 = x8; r7 = x13;, r1 = x4; r6 = x9; r3 = x5; r8 = x12
    # =======================================================
    # Round 5; same as round 3
    # r11 = x8; r6 = x9; r0 = x0; r3 = x5; r8 = x12; r4 = x3; r2 = x1; r9 = x2; r1 = x4; r5 = x7; r7 = x13; r10 = x14  
    add r0, r1  	        	// *a = *a + *b
    add r2, r3  		        // *a = *a + *b
    eor r8, r0  	        	// *d = *d ^ *a
    eor r7, r2, r7, ror #24     // *d = *d ^ *a
    add r11, r11, r8, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r11 		        // *b = *b ^ c
    eor r3, r6 			        // *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    add r2, r2, r3, ror #20  	// *a = *a + *b
    eor r8, r0, r8, ror #16  	// *d = *d ^ a
    eor r7, r2, r7, ror #16  	// *d = *d ^ a
    add r11, r11, r8, ror #24	// *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r11, r1, ror #20 	// *b = *b ^ c
    eor r3, r6, r3, ror #20 	// *b = *b ^ c 
    str r11, [r12, #32] 	// r11 = x8
    str r6, [r12, #36] 	// r6 = x9
    str r7, [r12, #52] 	// r7 = x13
    str r1, [r12, #16] 	// r1 = x4
    ldr r1, [r12, #24] 	// r1 = x6  still needs to be rotated by 25 
    ldr r11, [r12, #40]  // r11 = x10
    ldr r6, [r12, #44]  // r6 = x11
    ldr r7, [r12, #60]  // r7 = x15 still needs to be rotated by 24    
    ror r1, r1, #25     // Doing this separetly is just as fast as or faster than a barrel rotate alternative. Dont know why...
    add r9, r1  	        	// *a = *a + *b
    add r4, r5  		        // *a = *a + *b
    eor r10, r9, r10, ror #24  	// *d = *d ^ *a
    eor r7, r4, r7, ror #24     // *d = *d ^ *a and does rotate of x15
    add r11, r11, r10, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r11 		        // *b = *b ^ c
    eor r5, r6 			        // *b = *b ^ c
    add r9, r9, r1, ror #20  	// *a = *a + *b
    add r4, r4, r5, ror #20  	// *a = *a + *b
    eor r10, r9, r10, ror #16  	// *d = *d ^ a
    eor r7, r4, r7, ror #16  	// *d = *d ^ a
    add r11, r11, r10, ror #24	// *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r11, r1, ror #20 	// *b = *b ^ c
    eor r5, r6, r5, ror #20 	// *b = *b ^ c
    ror r5, r5, #25    // r5 = x7
    ror r1, r1, #25    // r1  = x6      
    
    # =======================================================
    # Round 6; same as round 4  
    add r0, r0, r3, ror #25     // *a = *a + *b
    add r2, r1   		        // *a = *a + *b
    eor r7, r0, r7, ror #24    	// *d = *d ^ *a
    eor r8, r2, r8, ror #24     // *d = *d ^ *a
    add r11, r11, r7, ror #16 	// *c = *c + *d
    add r6, r6, r8, ror #16 	// *c = *c + *d
    eor r3, r11, r3, ror #25    	// *b = *b ^ c
    eor r1, r6 			        // *b = *b ^ c
    add r0, r0, r3, ror #20  	// *a = *a + *b
    add r2, r2, r1, ror #20  	// *a = *a + *b
    eor r7, r0, r7, ror #16  	// *d = *d ^ a
    eor r8, r2, r8, ror #16  	// *d = *d ^ a
    add r11, r11, r7, ror #24	    // *c = *c + *d
    add r6, r6, r8, ror #24	    // *c = *c + *d
    eor r3, r11, r3, ror #20 	// *b = *b ^ c
    eor r1, r6, r1, ror #20 	// *b = *b ^ c
    
    # r7 and r1 are rotated during additions
    # Rotating r3 and r8 separetely is faster than barrel shifts:
    ror r3, r3, #25     // r3 = x5
    ror r8, r8, #24    // r8 = x12   
    
    str r11, [r12, #40] 	// r11 = x10
    str r7, [r12, #60] 	// r7 = x15
    str r1, [r12, #24] 	// r1 = x6
    str r6, [r12, #44] 	// r6 = x11   
    ldr r11, [r12, #32] 	// r11 = x8
    ldr r7, [r12, #52] 	// r7 = x13, still needs to rotate 24, done in first eor
    ldr r1, [r12, #16] 	// r1 = x4, still needs to rotate 25
    ldr r6, [r12, #36] 	// r6 = x9
    ror r1, r1, #25     // Doing this separetly is just as fast as or faster than a barrel rotate alternative. Dont know why...
    add r9, r5  	        	// *a = *a + *b
    add r4, r1  		        // *a = *a + *b
    eor r7, r9, r7, ror #24   	// *d = *d ^ *a
    eor r10, r4, r10, ror #24   // *d = *d ^ *a
    add r11, r11, r7, ror #16 	// *c = *c + *d
    add r6, r6, r10, ror #16 	// *c = *c + *d
    eor r5, r11 		        // *b = *b ^ c
    eor r1, r6 			        // *b = *b ^ c
    add r9, r9, r5, ror #20  	// *a = *a + *b
    add r4, r4, r1, ror #20  	// *a = *a + *b
    eor r7, r9, r7, ror #16  	// *d = *d ^ a
    eor r10, r4, r10, ror #16  	// *d = *d ^ a
    add r11, r11, r7, ror #24	// *c = *c + *d
    add r6, r6, r10, ror #24	// *c = *c + *d
    eor r5, r11, r5, ror #20 	// *b = *b ^ c
    eor r1, r6, r1, ror #20 	// *b = *b ^ c
    ror r1, r1, #25     // r1 = x4, rotate while we are at it
    ror r5, r5, #25     // r5 = x7, store for later use and rotate while we are at it

    # r10 = x14; r4 = x3; r9 = x2; r5 = x7; r0 = x0; r2 = x1; r5 = x7; r11 = x8; r7 = x13;, r1 = x4; r6 = x9; r3 = x5; r8 = x12
    # =======================================================
    # Round 7; same as round 3
    # r11 = x8; r6 = x9; r0 = x0; r3 = x5; r8 = x12; r4 = x3; r2 = x1; r9 = x2; r1 = x4; r5 = x7; r7 = x13; r10 = x14  
    add r0, r1  	        	// *a = *a + *b
    add r2, r3  		        // *a = *a + *b
    eor r8, r0  	        	// *d = *d ^ *a
    eor r7, r2, r7, ror #24     // *d = *d ^ *a
    add r11, r11, r8, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r11 		        // *b = *b ^ c
    eor r3, r6 			        // *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    add r2, r2, r3, ror #20  	// *a = *a + *b
    eor r8, r0, r8, ror #16  	// *d = *d ^ a
    eor r7, r2, r7, ror #16  	// *d = *d ^ a
    add r11, r11, r8, ror #24	// *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r11, r1, ror #20 	// *b = *b ^ c
    eor r3, r6, r3, ror #20 	// *b = *b ^ c 
    str r11, [r12, #32] 	// r11 = x8
    str r6, [r12, #36] 	// r6 = x9
    str r7, [r12, #52] 	// r7 = x13
    str r1, [r12, #16] 	// r1 = x4
    ldr r1, [r12, #24] 	// r1 = x6  still needs to be rotated by 25 
    ldr r11, [r12, #40]  // r11 = x10
    ldr r6, [r12, #44]  // r6 = x11
    ldr r7, [r12, #60]  // r7 = x15 still needs to be rotated by 24    
    ror r1, r1, #25     // Doing this separetly is just as fast as or faster than a barrel rotate alternative. Dont know why...
    add r9, r1  	        	// *a = *a + *b
    add r4, r5  		        // *a = *a + *b
    eor r10, r9, r10, ror #24  	// *d = *d ^ *a
    eor r7, r4, r7, ror #24     // *d = *d ^ *a and does rotate of x15
    add r11, r11, r10, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r11 		        // *b = *b ^ c
    eor r5, r6 			        // *b = *b ^ c
    add r9, r9, r1, ror #20  	// *a = *a + *b
    add r4, r4, r5, ror #20  	// *a = *a + *b
    eor r10, r9, r10, ror #16  	// *d = *d ^ a
    eor r7, r4, r7, ror #16  	// *d = *d ^ a
    add r11, r11, r10, ror #24	// *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r11, r1, ror #20 	// *b = *b ^ c
    eor r5, r6, r5, ror #20 	// *b = *b ^ c
    ror r5, r5, #25    // r5 = x7
    ror r1, r1, #25    // r1  = x6     
    
    # =======================================================
    # Round 8; same as round 4
    add r0, r0, r3, ror #25     // *a = *a + *b
    add r2, r1   		        // *a = *a + *b
    eor r7, r0, r7, ror #24    	// *d = *d ^ *a
    eor r8, r2, r8, ror #24     // *d = *d ^ *a
    add r11, r11, r7, ror #16 	// *c = *c + *d
    add r6, r6, r8, ror #16 	// *c = *c + *d
    eor r3, r11, r3, ror #25    	// *b = *b ^ c
    eor r1, r6 			        // *b = *b ^ c
    add r0, r0, r3, ror #20  	// *a = *a + *b
    add r2, r2, r1, ror #20  	// *a = *a + *b
    eor r7, r0, r7, ror #16  	// *d = *d ^ a
    eor r8, r2, r8, ror #16  	// *d = *d ^ a
    add r11, r11, r7, ror #24	    // *c = *c + *d
    add r6, r6, r8, ror #24	    // *c = *c + *d
    eor r3, r11, r3, ror #20 	// *b = *b ^ c
    eor r1, r6, r1, ror #20 	// *b = *b ^ c
    
    # r7 and r1 are rotated during additions
    # Rotating r3 and r8 separetely is faster than barrel shifts:
    ror r3, r3, #25     // r3 = x5
    ror r8, r8, #24    // r8 = x12   
    
    str r11, [r12, #40] 	// r11 = x10
    str r7, [r12, #60] 	// r7 = x15
    str r1, [r12, #24] 	// r1 = x6
    str r6, [r12, #44] 	// r6 = x11   
    ldr r11, [r12, #32] 	// r11 = x8
    ldr r7, [r12, #52] 	// r7 = x13, still needs to rotate 24, done in first eor
    ldr r1, [r12, #16] 	// r1 = x4, still needs to rotate 25
    ldr r6, [r12, #36] 	// r6 = x9
    ror r1, r1, #25     // Doing this separetly is just as fast as or faster than a barrel rotate alternative. Dont know why...
    add r9, r5  	        	// *a = *a + *b
    add r4, r1  		        // *a = *a + *b
    eor r7, r9, r7, ror #24   	// *d = *d ^ *a
    eor r10, r4, r10, ror #24   // *d = *d ^ *a
    add r11, r11, r7, ror #16 	// *c = *c + *d
    add r6, r6, r10, ror #16 	// *c = *c + *d
    eor r5, r11 		        // *b = *b ^ c
    eor r1, r6 			        // *b = *b ^ c
    add r9, r9, r5, ror #20  	// *a = *a + *b
    add r4, r4, r1, ror #20  	// *a = *a + *b
    eor r7, r9, r7, ror #16  	// *d = *d ^ a
    eor r10, r4, r10, ror #16  	// *d = *d ^ a
    add r11, r11, r7, ror #24	// *c = *c + *d
    add r6, r6, r10, ror #24	// *c = *c + *d
    eor r5, r11, r5, ror #20 	// *b = *b ^ c
    eor r1, r6, r1, ror #20 	// *b = *b ^ c
    ror r1, r1, #25     // r1 = x4, rotate while we are at it
    ror r5, r5, #25     // r5 = x7, store for later use and rotate while we are at it

    # r10 = x14; r4 = x3; r9 = x2; r5 = x7; r0 = x0; r2 = x1; r5 = x7; r11 = x8; r7 = x13;, r1 = x4; r6 = x9; r3 = x5; r8 = x12
    # =======================================================
    # Round 9; same as round 3
    # r11 = x8; r6 = x9; r0 = x0; r3 = x5; r8 = x12; r4 = x3; r2 = x1; r9 = x2; r1 = x4; r5 = x7; r7 = x13; r10 = x14  
    add r0, r1  	        	// *a = *a + *b
    add r2, r3  		        // *a = *a + *b
    eor r8, r0  	        	// *d = *d ^ *a
    eor r7, r2, r7, ror #24     // *d = *d ^ *a
    add r11, r11, r8, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r11 		        // *b = *b ^ c
    eor r3, r6 			        // *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    add r2, r2, r3, ror #20  	// *a = *a + *b
    eor r8, r0, r8, ror #16  	// *d = *d ^ a
    eor r7, r2, r7, ror #16  	// *d = *d ^ a
    add r11, r11, r8, ror #24	// *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r11, r1, ror #20 	// *b = *b ^ c
    eor r3, r6, r3, ror #20 	// *b = *b ^ c 
    str r11, [r12, #32] 	// r11 = x8
    str r6, [r12, #36] 	// r6 = x9
    str r7, [r12, #52] 	// r7 = x13
    str r1, [r12, #16] 	// r1 = x4
    ldr r1, [r12, #24] 	// r1 = x6  still needs to be rotated by 25 
    ldr r11, [r12, #40]  // r11 = x10
    ldr r6, [r12, #44]  // r6 = x11
    ldr r7, [r12, #60]  // r7 = x15 still needs to be rotated by 24    
    ror r1, r1, #25     // Doing this separetly is just as fast as or faster than a barrel rotate alternative. Dont know why...
    add r9, r1  	        	// *a = *a + *b
    add r4, r5  		        // *a = *a + *b
    eor r10, r9, r10, ror #24  	// *d = *d ^ *a
    eor r7, r4, r7, ror #24     // *d = *d ^ *a and does rotate of x15
    add r11, r11, r10, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r11 		        // *b = *b ^ c
    eor r5, r6 			        // *b = *b ^ c
    add r9, r9, r1, ror #20  	// *a = *a + *b
    add r4, r4, r5, ror #20  	// *a = *a + *b
    eor r10, r9, r10, ror #16  	// *d = *d ^ a
    eor r7, r4, r7, ror #16  	// *d = *d ^ a
    add r11, r11, r10, ror #24	// *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r11, r1, ror #20 	// *b = *b ^ c
    eor r5, r6, r5, ror #20 	// *b = *b ^ c
    ror r5, r5, #25    // r5 = x7
    ror r1, r1, #25    // r1  = x6  
    
    # =======================================================
    # Round 10; same as round 4
    add r0, r0, r3, ror #25     // *a = *a + *b
    add r2, r1   		        // *a = *a + *b
    eor r7, r0, r7, ror #24    	// *d = *d ^ *a
    eor r8, r2, r8, ror #24     // *d = *d ^ *a
    add r11, r11, r7, ror #16 	// *c = *c + *d
    add r6, r6, r8, ror #16 	// *c = *c + *d
    eor r3, r11, r3, ror #25    	// *b = *b ^ c
    eor r1, r6 			        // *b = *b ^ c
    add r0, r0, r3, ror #20  	// *a = *a + *b
    add r2, r2, r1, ror #20  	// *a = *a + *b
    eor r7, r0, r7, ror #16  	// *d = *d ^ a
    eor r8, r2, r8, ror #16  	// *d = *d ^ a
    add r11, r11, r7, ror #24	    // *c = *c + *d
    add r6, r6, r8, ror #24	    // *c = *c + *d
    eor r3, r11, r3, ror #20 	// *b = *b ^ c
    eor r1, r6, r1, ror #20 	// *b = *b ^ c
    
    # r7 and r1 are rotated during additions
    # Rotating r3 and r8 separetely is faster than barrel shifts:
    ror r3, r3, #25     // r3 = x5
    ror r8, r8, #24    // r8 = x12   
    
    str r11, [r12, #40] 	// r11 = x10
    str r7, [r12, #60] 	// r7 = x15
    str r1, [r12, #24] 	// r1 = x6
    str r6, [r12, #44] 	// r6 = x11   
    ldr r11, [r12, #32] 	// r11 = x8
    ldr r7, [r12, #52] 	// r7 = x13, still needs to rotate 24, done in first eor
    ldr r1, [r12, #16] 	// r1 = x4, still needs to rotate 25
    ldr r6, [r12, #36] 	// r6 = x9
    ror r1, r1, #25     // Doing this separetly is just as fast as or faster than a barrel rotate alternative. Dont know why...
    add r9, r5  	        	// *a = *a + *b
    add r4, r1  		        // *a = *a + *b
    eor r7, r9, r7, ror #24   	// *d = *d ^ *a
    eor r10, r4, r10, ror #24   // *d = *d ^ *a
    add r11, r11, r7, ror #16 	// *c = *c + *d
    add r6, r6, r10, ror #16 	// *c = *c + *d
    eor r5, r11 		        // *b = *b ^ c
    eor r1, r6 			        // *b = *b ^ c
    add r9, r9, r5, ror #20  	// *a = *a + *b
    add r4, r4, r1, ror #20  	// *a = *a + *b
    eor r7, r9, r7, ror #16  	// *d = *d ^ a
    eor r10, r4, r10, ror #16  	// *d = *d ^ a
    add r11, r11, r7, ror #24	// *c = *c + *d
    add r6, r6, r10, ror #24	// *c = *c + *d
    eor r5, r11, r5, ror #20 	// *b = *b ^ c
    eor r1, r6, r1, ror #20 	// *b = *b ^ c
    ror r1, r1, #25     // r1 = x4, rotate while we are at it
    ror r5, r5, #25     // r5 = x7, store for later use and rotate while we are at it

    # r10 = x14; r4 = x3; r9 = x2; r5 = x7; r0 = x0; r2 = x1; r5 = x7; r11 = x8; r7 = x13;, r1 = x4; r6 = x9; r3 = x5; r8 = x12
    # =======================================================
    # Round 11; same as round 3
    # r11 = x8; r6 = x9; r0 = x0; r3 = x5; r8 = x12; r4 = x3; r2 = x1; r9 = x2; r1 = x4; r5 = x7; r7 = x13; r10 = x14  
    add r0, r1  	        	// *a = *a + *b
    add r2, r3  		        // *a = *a + *b
    eor r8, r0  	        	// *d = *d ^ *a
    eor r7, r2, r7, ror #24     // *d = *d ^ *a
    add r11, r11, r8, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r11 		        // *b = *b ^ c
    eor r3, r6 			        // *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    add r2, r2, r3, ror #20  	// *a = *a + *b
    eor r8, r0, r8, ror #16  	// *d = *d ^ a
    eor r7, r2, r7, ror #16  	// *d = *d ^ a
    add r11, r11, r8, ror #24	// *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r11, r1, ror #20 	// *b = *b ^ c
    eor r3, r6, r3, ror #20 	// *b = *b ^ c 
    str r11, [r12, #32] 	// r11 = x8
    str r6, [r12, #36] 	// r6 = x9
    str r7, [r12, #52] 	// r7 = x13
    str r1, [r12, #16] 	// r1 = x4
    ldr r1, [r12, #24] 	// r1 = x6  still needs to be rotated by 25 
    ldr r11, [r12, #40]  // r11 = x10
    ldr r6, [r12, #44]  // r6 = x11
    ldr r7, [r12, #60]  // r7 = x15 still needs to be rotated by 24    
    ror r1, r1, #25     // Doing this separetly is just as fast as or faster than a barrel rotate alternative. Dont know why...
    add r9, r1  	        	// *a = *a + *b
    add r4, r5  		        // *a = *a + *b
    eor r10, r9, r10, ror #24  	// *d = *d ^ *a
    eor r7, r4, r7, ror #24     // *d = *d ^ *a and does rotate of x15
    add r11, r11, r10, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r11 		        // *b = *b ^ c
    eor r5, r6 			        // *b = *b ^ c
    add r9, r9, r1, ror #20  	// *a = *a + *b
    add r4, r4, r5, ror #20  	// *a = *a + *b
    eor r10, r9, r10, ror #16  	// *d = *d ^ a
    eor r7, r4, r7, ror #16  	// *d = *d ^ a
    add r11, r11, r10, ror #24	// *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r11, r1, ror #20 	// *b = *b ^ c
    eor r5, r6, r5, ror #20 	// *b = *b ^ c
    ror r5, r5, #25    // r5 = x7
    ror r1, r1, #25    // r1  = x6     
    
    # =======================================================
    # Round 12; same as round 4
    add r0, r0, r3, ror #25     // *a = *a + *b
    add r2, r1   		        // *a = *a + *b
    eor r7, r0, r7, ror #24    	// *d = *d ^ *a
    eor r8, r2, r8, ror #24     // *d = *d ^ *a
    add r11, r11, r7, ror #16 	// *c = *c + *d
    add r6, r6, r8, ror #16 	// *c = *c + *d
    eor r3, r11, r3, ror #25    	// *b = *b ^ c
    eor r1, r6 			        // *b = *b ^ c
    add r0, r0, r3, ror #20  	// *a = *a + *b
    add r2, r2, r1, ror #20  	// *a = *a + *b
    eor r7, r0, r7, ror #16  	// *d = *d ^ a
    eor r8, r2, r8, ror #16  	// *d = *d ^ a
    add r11, r11, r7, ror #24	    // *c = *c + *d
    add r6, r6, r8, ror #24	    // *c = *c + *d
    eor r3, r11, r3, ror #20 	// *b = *b ^ c
    eor r1, r6, r1, ror #20 	// *b = *b ^ c
    
    # r7 and r1 are rotated during additions
    # Rotating r3 and r8 separetely is faster than barrel shifts:
    ror r3, r3, #25     // r3 = x5
    ror r8, r8, #24    // r8 = x12   
    
    str r11, [r12, #40] 	// r11 = x10
    str r7, [r12, #60] 	// r7 = x15
    str r1, [r12, #24] 	// r1 = x6
    str r6, [r12, #44] 	// r6 = x11   
    ldr r11, [r12, #32] 	// r11 = x8
    ldr r7, [r12, #52] 	// r7 = x13, still needs to rotate 24, done in first eor
    ldr r1, [r12, #16] 	// r1 = x4, still needs to rotate 25
    ldr r6, [r12, #36] 	// r6 = x9
    ror r1, r1, #25     // Doing this separetly is just as fast as or faster than a barrel rotate alternative. Dont know why...
    add r9, r5  	        	// *a = *a + *b
    add r4, r1  		        // *a = *a + *b
    eor r7, r9, r7, ror #24   	// *d = *d ^ *a
    eor r10, r4, r10, ror #24   // *d = *d ^ *a
    add r11, r11, r7, ror #16 	// *c = *c + *d
    add r6, r6, r10, ror #16 	// *c = *c + *d
    eor r5, r11 		        // *b = *b ^ c
    eor r1, r6 			        // *b = *b ^ c
    add r9, r9, r5, ror #20  	// *a = *a + *b
    add r4, r4, r1, ror #20  	// *a = *a + *b
    eor r7, r9, r7, ror #16  	// *d = *d ^ a
    eor r10, r4, r10, ror #16  	// *d = *d ^ a
    add r11, r11, r7, ror #24	// *c = *c + *d
    add r6, r6, r10, ror #24	// *c = *c + *d
    eor r5, r11, r5, ror #20 	// *b = *b ^ c
    eor r1, r6, r1, ror #20 	// *b = *b ^ c
    ror r1, r1, #25     // r1 = x4, rotate while we are at it
    ror r5, r5, #25     // r5 = x7, store for later use and rotate while we are at it

    # r10 = x14; r4 = x3; r9 = x2; r5 = x7; r0 = x0; r2 = x1; r5 = x7; r11 = x8; r7 = x13;, r1 = x4; r6 = x9; r3 = x5; r8 = x12
    # =======================================================
    # Round 13; same as round 3
    # r11 = x8; r6 = x9; r0 = x0; r3 = x5; r8 = x12; r4 = x3; r2 = x1; r9 = x2; r1 = x4; r5 = x7; r7 = x13; r10 = x14  
    add r0, r1  	        	// *a = *a + *b
    add r2, r3  		        // *a = *a + *b
    eor r8, r0  	        	// *d = *d ^ *a
    eor r7, r2, r7, ror #24     // *d = *d ^ *a
    add r11, r11, r8, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r11 		        // *b = *b ^ c
    eor r3, r6 			        // *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    add r2, r2, r3, ror #20  	// *a = *a + *b
    eor r8, r0, r8, ror #16  	// *d = *d ^ a
    eor r7, r2, r7, ror #16  	// *d = *d ^ a
    add r11, r11, r8, ror #24	// *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r11, r1, ror #20 	// *b = *b ^ c
    eor r3, r6, r3, ror #20 	// *b = *b ^ c 
    str r11, [r12, #32] 	// r11 = x8
    str r6, [r12, #36] 	// r6 = x9
    str r7, [r12, #52] 	// r7 = x13
    str r1, [r12, #16] 	// r1 = x4
    ldr r1, [r12, #24] 	// r1 = x6  still needs to be rotated by 25 
    ldr r11, [r12, #40]  // r11 = x10
    ldr r6, [r12, #44]  // r6 = x11
    ldr r7, [r12, #60]  // r7 = x15 still needs to be rotated by 24    
    ror r1, r1, #25     // Doing this separetly is just as fast as or faster than a barrel rotate alternative. Dont know why...
    add r9, r1  	        	// *a = *a + *b
    add r4, r5  		        // *a = *a + *b
    eor r10, r9, r10, ror #24  	// *d = *d ^ *a
    eor r7, r4, r7, ror #24     // *d = *d ^ *a and does rotate of x15
    add r11, r11, r10, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r11 		        // *b = *b ^ c
    eor r5, r6 			        // *b = *b ^ c
    add r9, r9, r1, ror #20  	// *a = *a + *b
    add r4, r4, r5, ror #20  	// *a = *a + *b
    eor r10, r9, r10, ror #16  	// *d = *d ^ a
    eor r7, r4, r7, ror #16  	// *d = *d ^ a
    add r11, r11, r10, ror #24	// *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r11, r1, ror #20 	// *b = *b ^ c
    eor r5, r6, r5, ror #20 	// *b = *b ^ c
    ror r5, r5, #25    // r5 = x7
    ror r1, r1, #25    // r1  = x6     
    
    # =======================================================
    # Round 14; same as round 4
    add r0, r0, r3, ror #25     // *a = *a + *b
    add r2, r1   		        // *a = *a + *b
    eor r7, r0, r7, ror #24    	// *d = *d ^ *a
    eor r8, r2, r8, ror #24     // *d = *d ^ *a
    add r11, r11, r7, ror #16 	// *c = *c + *d
    add r6, r6, r8, ror #16 	// *c = *c + *d
    eor r3, r11, r3, ror #25    	// *b = *b ^ c
    eor r1, r6 			        // *b = *b ^ c
    add r0, r0, r3, ror #20  	// *a = *a + *b
    add r2, r2, r1, ror #20  	// *a = *a + *b
    eor r7, r0, r7, ror #16  	// *d = *d ^ a
    eor r8, r2, r8, ror #16  	// *d = *d ^ a
    add r11, r11, r7, ror #24	    // *c = *c + *d
    add r6, r6, r8, ror #24	    // *c = *c + *d
    eor r3, r11, r3, ror #20 	// *b = *b ^ c
    eor r1, r6, r1, ror #20 	// *b = *b ^ c
    
    # r7 and r1 are rotated during additions
    # Rotating r3 and r8 separetely is faster than barrel shifts:
    ror r3, r3, #25     // r3 = x5
    ror r8, r8, #24    // r8 = x12   
    
    str r11, [r12, #40] 	// r11 = x10
    str r7, [r12, #60] 	// r7 = x15
    str r1, [r12, #24] 	// r1 = x6
    str r6, [r12, #44] 	// r6 = x11   
    ldr r11, [r12, #32] 	// r11 = x8
    ldr r7, [r12, #52] 	// r7 = x13, still needs to rotate 24, done in first eor
    ldr r1, [r12, #16] 	// r1 = x4, still needs to rotate 25
    ldr r6, [r12, #36] 	// r6 = x9
    ror r1, r1, #25     // Doing this separetly is just as fast as or faster than a barrel rotate alternative. Dont know why...
    add r9, r5  	        	// *a = *a + *b
    add r4, r1  		        // *a = *a + *b
    eor r7, r9, r7, ror #24   	// *d = *d ^ *a
    eor r10, r4, r10, ror #24   // *d = *d ^ *a
    add r11, r11, r7, ror #16 	// *c = *c + *d
    add r6, r6, r10, ror #16 	// *c = *c + *d
    eor r5, r11 		        // *b = *b ^ c
    eor r1, r6 			        // *b = *b ^ c
    add r9, r9, r5, ror #20  	// *a = *a + *b
    add r4, r4, r1, ror #20  	// *a = *a + *b
    eor r7, r9, r7, ror #16  	// *d = *d ^ a
    eor r10, r4, r10, ror #16  	// *d = *d ^ a
    add r11, r11, r7, ror #24	// *c = *c + *d
    add r6, r6, r10, ror #24	// *c = *c + *d
    eor r5, r11, r5, ror #20 	// *b = *b ^ c
    eor r1, r6, r1, ror #20 	// *b = *b ^ c
    ror r1, r1, #25     // r1 = x4, rotate while we are at it
    ror r5, r5, #25     // r5 = x7, store for later use and rotate while we are at it

    # r10 = x14; r4 = x3; r9 = x2; r5 = x7; r0 = x0; r2 = x1; r5 = x7; r11 = x8; r7 = x13;, r1 = x4; r6 = x9; r3 = x5; r8 = x12
    # =======================================================
    # Round 15; same as round 3
    # r11 = x8; r6 = x9; r0 = x0; r3 = x5; r8 = x12; r4 = x3; r2 = x1; r9 = x2; r1 = x4; r5 = x7; r7 = x13; r10 = x14  
    add r0, r1  	        	// *a = *a + *b
    add r2, r3  		        // *a = *a + *b
    eor r8, r0  	        	// *d = *d ^ *a
    eor r7, r2, r7, ror #24     // *d = *d ^ *a
    add r11, r11, r8, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r11 		        // *b = *b ^ c
    eor r3, r6 			        // *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    add r2, r2, r3, ror #20  	// *a = *a + *b
    eor r8, r0, r8, ror #16  	// *d = *d ^ a
    eor r7, r2, r7, ror #16  	// *d = *d ^ a
    add r11, r11, r8, ror #24	// *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r11, r1, ror #20 	// *b = *b ^ c
    eor r3, r6, r3, ror #20 	// *b = *b ^ c 
    str r11, [r12, #32] 	// r11 = x8
    str r6, [r12, #36] 	// r6 = x9
    str r7, [r12, #52] 	// r7 = x13
    str r1, [r12, #16] 	// r1 = x4
    ldr r1, [r12, #24] 	// r1 = x6  still needs to be rotated by 25 
    ldr r11, [r12, #40]  // r11 = x10
    ldr r6, [r12, #44]  // r6 = x11
    ldr r7, [r12, #60]  // r7 = x15 still needs to be rotated by 24    
    ror r1, r1, #25     // Doing this separetly is just as fast as or faster than a barrel rotate alternative. Dont know why...
    add r9, r1  	        	// *a = *a + *b
    add r4, r5  		        // *a = *a + *b
    eor r10, r9, r10, ror #24  	// *d = *d ^ *a
    eor r7, r4, r7, ror #24     // *d = *d ^ *a and does rotate of x15
    add r11, r11, r10, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r11 		        // *b = *b ^ c
    eor r5, r6 			        // *b = *b ^ c
    add r9, r9, r1, ror #20  	// *a = *a + *b
    add r4, r4, r5, ror #20  	// *a = *a + *b
    eor r10, r9, r10, ror #16  	// *d = *d ^ a
    eor r7, r4, r7, ror #16  	// *d = *d ^ a
    add r11, r11, r10, ror #24	// *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r11, r1, ror #20 	// *b = *b ^ c
    eor r5, r6, r5, ror #20 	// *b = *b ^ c
    ror r5, r5, #25    // r5 = x7
    ror r1, r1, #25    // r1  = x6     
    
    # =======================================================
    # Round 16; same as round 4
    add r0, r0, r3, ror #25     // *a = *a + *b
    add r2, r1   		        // *a = *a + *b
    eor r7, r0, r7, ror #24    	// *d = *d ^ *a
    eor r8, r2, r8, ror #24     // *d = *d ^ *a
    add r11, r11, r7, ror #16 	// *c = *c + *d
    add r6, r6, r8, ror #16 	// *c = *c + *d
    eor r3, r11, r3, ror #25    	// *b = *b ^ c
    eor r1, r6 			        // *b = *b ^ c
    add r0, r0, r3, ror #20  	// *a = *a + *b
    add r2, r2, r1, ror #20  	// *a = *a + *b
    eor r7, r0, r7, ror #16  	// *d = *d ^ a
    eor r8, r2, r8, ror #16  	// *d = *d ^ a
    add r11, r11, r7, ror #24	    // *c = *c + *d
    add r6, r6, r8, ror #24	    // *c = *c + *d
    eor r3, r11, r3, ror #20 	// *b = *b ^ c
    eor r1, r6, r1, ror #20 	// *b = *b ^ c
    
    # r7 and r1 are rotated during additions
    # Rotating r3 and r8 separetely is faster than barrel shifts:
    ror r3, r3, #25     // r3 = x5
    ror r8, r8, #24    // r8 = x12   
    
    str r11, [r12, #40] 	// r11 = x10
    str r7, [r12, #60] 	// r7 = x15
    str r1, [r12, #24] 	// r1 = x6
    str r6, [r12, #44] 	// r6 = x11   
    ldr r11, [r12, #32] 	// r11 = x8
    ldr r7, [r12, #52] 	// r7 = x13, still needs to rotate 24, done in first eor
    ldr r1, [r12, #16] 	// r1 = x4, still needs to rotate 25
    ldr r6, [r12, #36] 	// r6 = x9
    ror r1, r1, #25     // Doing this separetly is just as fast as or faster than a barrel rotate alternative. Dont know why...
    add r9, r5  	        	// *a = *a + *b
    add r4, r1  		        // *a = *a + *b
    eor r7, r9, r7, ror #24   	// *d = *d ^ *a
    eor r10, r4, r10, ror #24   // *d = *d ^ *a
    add r11, r11, r7, ror #16 	// *c = *c + *d
    add r6, r6, r10, ror #16 	// *c = *c + *d
    eor r5, r11 		        // *b = *b ^ c
    eor r1, r6 			        // *b = *b ^ c
    add r9, r9, r5, ror #20  	// *a = *a + *b
    add r4, r4, r1, ror #20  	// *a = *a + *b
    eor r7, r9, r7, ror #16  	// *d = *d ^ a
    eor r10, r4, r10, ror #16  	// *d = *d ^ a
    add r11, r11, r7, ror #24	// *c = *c + *d
    add r6, r6, r10, ror #24	// *c = *c + *d
    eor r5, r11, r5, ror #20 	// *b = *b ^ c
    eor r1, r6, r1, ror #20 	// *b = *b ^ c
    ror r1, r1, #25     // r1 = x4, rotate while we are at it
    ror r5, r5, #25     // r5 = x7, store for later use and rotate while we are at it

    # r10 = x14; r4 = x3; r9 = x2; r5 = x7; r0 = x0; r2 = x1; r5 = x7; r11 = x8; r7 = x13;, r1 = x4; r6 = x9; r3 = x5; r8 = x12
    # =======================================================
    # Round 17; same as round 3
    # r11 = x8; r6 = x9; r0 = x0; r3 = x5; r8 = x12; r4 = x3; r2 = x1; r9 = x2; r1 = x4; r5 = x7; r7 = x13; r10 = x14  
    add r0, r1  	        	// *a = *a + *b
    add r2, r3  		        // *a = *a + *b
    eor r8, r0  	        	// *d = *d ^ *a
    eor r7, r2, r7, ror #24     // *d = *d ^ *a
    add r11, r11, r8, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r11 		        // *b = *b ^ c
    eor r3, r6 			        // *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    add r2, r2, r3, ror #20  	// *a = *a + *b
    eor r8, r0, r8, ror #16  	// *d = *d ^ a
    eor r7, r2, r7, ror #16  	// *d = *d ^ a
    add r11, r11, r8, ror #24	// *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r11, r1, ror #20 	// *b = *b ^ c
    eor r3, r6, r3, ror #20 	// *b = *b ^ c 
    str r11, [r12, #32] 	// r11 = x8
    str r6, [r12, #36] 	// r6 = x9
    str r7, [r12, #52] 	// r7 = x13
    str r1, [r12, #16] 	// r1 = x4
    ldr r1, [r12, #24] 	// r1 = x6  still needs to be rotated by 25 
    ldr r11, [r12, #40]  // r11 = x10
    ldr r6, [r12, #44]  // r6 = x11
    ldr r7, [r12, #60]  // r7 = x15 still needs to be rotated by 24    
    ror r1, r1, #25     // Doing this separetly is just as fast as or faster than a barrel rotate alternative. Dont know why...
    add r9, r1  	        	// *a = *a + *b
    add r4, r5  		        // *a = *a + *b
    eor r10, r9, r10, ror #24  	// *d = *d ^ *a
    eor r7, r4, r7, ror #24     // *d = *d ^ *a and does rotate of x15
    add r11, r11, r10, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r11 		        // *b = *b ^ c
    eor r5, r6 			        // *b = *b ^ c
    add r9, r9, r1, ror #20  	// *a = *a + *b
    add r4, r4, r5, ror #20  	// *a = *a + *b
    eor r10, r9, r10, ror #16  	// *d = *d ^ a
    eor r7, r4, r7, ror #16  	// *d = *d ^ a
    add r11, r11, r10, ror #24	// *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r11, r1, ror #20 	// *b = *b ^ c
    eor r5, r6, r5, ror #20 	// *b = *b ^ c
    ror r5, r5, #25    // r5 = x7
    ror r1, r1, #25    // r1  = x6      
    
    # =======================================================
    # Round 18; same as round 4
    add r0, r0, r3, ror #25     // *a = *a + *b
    add r2, r1   		        // *a = *a + *b
    eor r7, r0, r7, ror #24    	// *d = *d ^ *a
    eor r8, r2, r8, ror #24     // *d = *d ^ *a
    add r11, r11, r7, ror #16 	// *c = *c + *d
    add r6, r6, r8, ror #16 	// *c = *c + *d
    eor r3, r11, r3, ror #25    	// *b = *b ^ c
    eor r1, r6 			        // *b = *b ^ c
    add r0, r0, r3, ror #20  	// *a = *a + *b
    add r2, r2, r1, ror #20  	// *a = *a + *b
    eor r7, r0, r7, ror #16  	// *d = *d ^ a
    eor r8, r2, r8, ror #16  	// *d = *d ^ a
    add r11, r11, r7, ror #24	    // *c = *c + *d
    add r6, r6, r8, ror #24	    // *c = *c + *d
    eor r3, r11, r3, ror #20 	// *b = *b ^ c
    eor r1, r6, r1, ror #20 	// *b = *b ^ c
    
    # r7 and r1 are rotated during additions
    # Rotating r3 and r8 separetely is faster than barrel shifts:
    ror r3, r3, #25     // r3 = x5
    ror r8, r8, #24    // r8 = x12   
    
    str r11, [r12, #40] 	// r11 = x10
    str r7, [r12, #60] 	// r7 = x15
    str r1, [r12, #24] 	// r1 = x6
    str r6, [r12, #44] 	// r6 = x11   
    ldr r11, [r12, #32] 	// r11 = x8
    ldr r7, [r12, #52] 	// r7 = x13, still needs to rotate 24, done in first eor
    ldr r1, [r12, #16] 	// r1 = x4, still needs to rotate 25
    ldr r6, [r12, #36] 	// r6 = x9
    ror r1, r1, #25     // Doing this separetly is just as fast as or faster than a barrel rotate alternative. Dont know why...
    add r9, r5  	        	// *a = *a + *b
    add r4, r1  		        // *a = *a + *b
    eor r7, r9, r7, ror #24   	// *d = *d ^ *a
    eor r10, r4, r10, ror #24   // *d = *d ^ *a
    add r11, r11, r7, ror #16 	// *c = *c + *d
    add r6, r6, r10, ror #16 	// *c = *c + *d
    eor r5, r11 		        // *b = *b ^ c
    eor r1, r6 			        // *b = *b ^ c
    add r9, r9, r5, ror #20  	// *a = *a + *b
    add r4, r4, r1, ror #20  	// *a = *a + *b
    eor r7, r9, r7, ror #16  	// *d = *d ^ a
    eor r10, r4, r10, ror #16  	// *d = *d ^ a
    add r11, r11, r7, ror #24	// *c = *c + *d
    add r6, r6, r10, ror #24	// *c = *c + *d
    eor r5, r11, r5, ror #20 	// *b = *b ^ c
    eor r1, r6, r1, ror #20 	// *b = *b ^ c
    ror r1, r1, #25     // r1 = x4, rotate while we are at it
    ror r5, r5, #25     // r5 = x7, store for later use and rotate while we are at it

    # r10 = x14; r4 = x3; r9 = x2; r5 = x7; r0 = x0; r2 = x1; r5 = x7; r11 = x8; r7 = x13;, r1 = x4; r6 = x9; r3 = x5; r8 = x12
    # =======================================================
    # Round 19; same as round 3
    # r11 = x8; r6 = x9; r0 = x0; r3 = x5; r8 = x12; r4 = x3; r2 = x1; r9 = x2; r1 = x4; r5 = x7; r7 = x13; r10 = x14  
    add r0, r1  	        	// *a = *a + *b
    add r2, r3  		        // *a = *a + *b
    eor r8, r0  	        	// *d = *d ^ *a
    eor r7, r2, r7, ror #24     // *d = *d ^ *a
    add r11, r11, r8, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r11 		        // *b = *b ^ c
    eor r3, r6 			        // *b = *b ^ c
    add r0, r0, r1, ror #20  	// *a = *a + *b
    add r2, r2, r3, ror #20  	// *a = *a + *b
    eor r8, r0, r8, ror #16  	// *d = *d ^ a
    eor r7, r2, r7, ror #16  	// *d = *d ^ a
    add r11, r11, r8, ror #24	// *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r11, r1, ror #20 	// *b = *b ^ c
    eor r3, r6, r3, ror #20 	// *b = *b ^ c 
    str r11, [r12, #32] 	// r11 = x8
    str r6, [r12, #36] 	// r6 = x9
    str r7, [r12, #52] 	// r7 = x13
    str r1, [r12, #16] 	// r1 = x4
    ldr r1, [r12, #24] 	// r1 = x6  still needs to be rotated by 25 
    ldr r11, [r12, #40]  // r11 = x10
    ldr r6, [r12, #44]  // r6 = x11
    ldr r7, [r12, #60]  // r7 = x15 still needs to be rotated by 24    
    ror r1, r1, #25     // Doing this separetly is just as fast as or faster than a barrel rotate alternative. Dont know why...
    add r9, r1  	        	// *a = *a + *b
    add r4, r5  		        // *a = *a + *b
    eor r10, r9, r10, ror #24  	// *d = *d ^ *a
    eor r7, r4, r7, ror #24     // *d = *d ^ *a and does rotate of x15
    add r11, r11, r10, ror #16 	// *c = *c + *d
    add r6, r6, r7, ror #16 	// *c = *c + *d
    eor r1, r11 		        // *b = *b ^ c
    eor r5, r6 			        // *b = *b ^ c
    add r9, r9, r1, ror #20  	// *a = *a + *b
    add r4, r4, r5, ror #20  	// *a = *a + *b
    eor r10, r9, r10, ror #16  	// *d = *d ^ a
    eor r7, r4, r7, ror #16  	// *d = *d ^ a
    add r11, r11, r10, ror #24	// *c = *c + *d
    add r6, r6, r7, ror #24	    // *c = *c + *d
    eor r1, r11, r1, ror #20 	// *b = *b ^ c
    eor r5, r6, r5, ror #20 	// *b = *b ^ c
    ror r5, r5, #25    // r5 = x7
    ror r1, r1, #25    // r1  = x6  
    
    # =======================================================
    # Round 20; same as round 4
    add r0, r0, r3, ror #25     // *a = *a + *b
    add r2, r1   		        // *a = *a + *b
    eor r7, r0, r7, ror #24    	// *d = *d ^ *a
    eor r8, r2, r8, ror #24     // *d = *d ^ *a
    add r11, r11, r7, ror #16 	// *c = *c + *d
    add r6, r6, r8, ror #16 	// *c = *c + *d
    eor r3, r11, r3, ror #25    	// *b = *b ^ c
    eor r1, r6 			        // *b = *b ^ c
    add r0, r0, r3, ror #20  	// *a = *a + *b
    add r2, r2, r1, ror #20  	// *a = *a + *b
    eor r7, r0, r7, ror #16  	// *d = *d ^ a
    eor r8, r2, r8, ror #16  	// *d = *d ^ a
    add r11, r11, r7, ror #24	    // *c = *c + *d
    add r6, r6, r8, ror #24	    // *c = *c + *d
    eor r3, r11, r3, ror #20 	// *b = *b ^ c
    eor r1, r6, r1, ror #20 	// *b = *b ^ c
    
    # r7 and r1 are rotated during additions
    # Rotating r3 and r8 separetely is faster than barrel shifts:
    ror r3, r3, #25     // r3 = x5
    ror r8, r8, #24    // r8 = x12   
    
    str r11, [r12, #40] 	// r11 = x10
    str r7, [r12, #60] 	// r7 = x15
    str r1, [r12, #24] 	// r1 = x6
    str r6, [r12, #44] 	// r6 = x11   
    ldr r11, [r12, #32] 	// r11 = x8
    ldr r7, [r12, #52] 	// r7 = x13, still needs to rotate 24, done in first eor
    ldr r1, [r12, #16] 	// r1 = x4, still needs to rotate 25
    ldr r6, [r12, #36] 	// r6 = x9
    ror r1, r1, #25     // Doing this separetly is just as fast as or faster than a barrel rotate alternative. Dont know why...
    add r9, r5  	        	// *a = *a + *b
    add r4, r1  		        // *a = *a + *b
    eor r7, r9, r7, ror #24   	// *d = *d ^ *a
    eor r10, r4, r10, ror #24   // *d = *d ^ *a
    add r11, r11, r7, ror #16 	// *c = *c + *d
    add r6, r6, r10, ror #16 	// *c = *c + *d
    eor r5, r11 		        // *b = *b ^ c
    eor r1, r6 			        // *b = *b ^ c
    add r9, r9, r5, ror #20  	// *a = *a + *b
    add r4, r4, r1, ror #20  	// *a = *a + *b
    eor r7, r9, r7, ror #16  	// *d = *d ^ a
    eor r10, r4, r10, ror #16  	// *d = *d ^ a
    add r11, r11, r7, ror #24	// *c = *c + *d
    add r6, r6, r10, ror #24	// *c = *c + *d
    eor r5, r11, r5, ror #20 	// *b = *b ^ c
    eor r1, r6, r1, ror #20 	// *b = *b ^ c
    
    # r1, r10, r7 and r5 are rotated later during the additions

    # r10 = x14; r4 = x3; r9 = x2; r5 = x7; r0 = x0; r2 = x1; r5 = x7; r11 = x8; r7 = x13;, r1 = x4; r6 = x9; r3 = x5; r8 = x12    
    # ===================================================================================================
    
    # write the results back to memory:
    str r5, [r12, #28] 	// r5 = x7
    str r11, [r12, #32] // r11 = x8
    str r7, [r12, #52] 	// r7 = x13
    str r6, [r12, #36] 	// r6 = x9
    str r10, [r12, #56] // r10 = x14
    str r3, [r12, #20]  // r3 = x5
    str r8, [r12, #48]  // r8 = x12
   
    pop {r6}        	// restore pointer to out
    // load out[0] to out[4] into registers (loads the j's)
    ldr r10, [r6]	// r10 = out[0]
    ldr r7, [r6, #4]    // r7 = out[1]
    ldr r3, [r6, #8]    // r3 = out[2]
    ldr r8, [r6, #12]   // r8 = out[3]
    ldr r5, [r6, #16]   // r5 = out[4]
    
    add r10, r0
    add r2, r7
    add r3, r9 
    add r4, r8 
    add r5, r5, r1, ror #25

    # store in out[0] to out[4]
    str r10, [r6]
    str r2, [r6, #4]
    str r3, [r6, #8]
    str r4, [r6, #12]
    str r5, [r6, #16]
 
    // load out[5] to out[9] into r0-r4
    ldr r0, [r6, #20]
    ldr r1, [r6, #24]
    ldr r2, [r6, #28]
    ldr r3, [r6, #32]
    ldr r4, [r6, #36]

    # load x[5] to x[9] into r5 and r7-r10
    ldr r5, [r12, #20]
    ldr r7, [r12, #24]
    ldr r8, [r12, #28]
    ldr r9, [r12, #32]
    ldr r10, [r12, #36]

    add r0, r5
    add r1, r1, r7, ror #25
    add r2, r2, r8, ror #25
    add r3, r9
    add r4, r10
    
    str r0, [r6, #20]
    str r1, [r6, #24]
    str r2, [r6, #28]
    str r3, [r6, #32]
    str r4, [r6, #36]
   
    // load x[10] to x[15] in r0-r5
    ldr r0, [r12, #40]
    ldr r1, [r12, #44]
    ldr r2, [r12, #48]
    ldr r3, [r12, #52]
    ldr r4, [r12, #56]
    ldr r5, [r12, #60]

    // load out[10] to out[15] into r7-r12
    ldr r7, [r6, #40]
    ldr r8, [r6, #44]
    ldr r9, [r6, #48]
    ldr r10, [r6, #52]
    ldr r11, [r6, #56]
    ldr r12, [r6, #60]

    add r0, r7
    add r1, r8
    add r2, r9
    add r3, r10, r3, ror #24
    add r4, r11, r4, ror #24
    add r5, r12, r5, ror #24

    // store in out[10] to out[15]
    str r0, [r6, #40]
    str r1, [r6, #44]
    str r2, [r6, #48]
    str r3, [r6, #52]
    str r4, [r6, #56]
    str r5, [r6, #60]
    
    # substract 64 from r0 and r12 if they are needed beyond here
    
    // The return value isn't used, so no need mov r0, #0	 	// return 0
    pop {r4-r11}        // Restore registers before return
    bx lr

