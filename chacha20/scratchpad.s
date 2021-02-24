    # =======================================================
    # Round 19; same as round 3
    push {r0}           // There is not enough registers for the entire swap, so push one register for the swap.
    mov r0, r8          // r0 = x0
    ror r8, r1, #25     // r8 = x7, store for later use and rotate while we are at it
    ror r1, r5, #25     // r1 = x4, rotate while we are at it
    mov r5, r9          // r5 = x5
    mov r9, r4          // r9 = x3, store for later use
    mov r4, r10         // r4 = x1
    ror r10, r7, #24    // r10 = x14, store for later use and rotate while we are at it
    ror r7, r3, #24     // r7 = x13, rotate while we are at it
    mov r3, r11         // r3 = x12
    pop {r11}            // r11 = x2, store for later use  
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
    str r2, [r12, #32] 	// r2 = x8
    str r6, [r12, #36] 	// r6 = x9
    str r7, [r12, #52] 	// r7 = x13
    str r1, [r12, #16] 	// r1 = x4
    
    mov r1, r0          // r1 = x0, swap register
    mov r0, r11         // r0 = x2
    mov r11, r4         // r11 = x1, store for later
    mov r4, r9          // r4 = x3
    ror r9, r3, #24     // r9 = x12, store for later does rotate and move together
    mov r3, r10         // r3 = x14
    ror r10, r5, #25    // r10 = x5, store for later does rotate and move together
    mov r5, r8          // r5 = x7
    mov r8, r1          // r8 = x0, store for later (uses swap register from earlier)
    ldr r1, [r12, #24] 	// r1 = x6  still needs to be rotated by 25 
    ldr r2, [r12, #40]  // r2 = x10
    ldr r6, [r12, #44]  // r6 = x11
    ldr r7, [r12, #60]  // r7 = x15 still needs to be rotated by 24
    
    ror r1, r1, #25     // TODO: merge this into the calculating instructions

    add r0, r1  	        	// *a = *a + *b
    add r4, r5  		        // *a = *a + *b
    eor r3, r0  	        	// *d = *d ^ *a
    eor r7, r4, r7, ror #24     // *d = *d ^ *a and does rotate of x15
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
    push {r0}           // There is not enough registers for the entire swap, so push one register for the swap.
    mov r0, r8          // r0  = x0
    ror r8, r3, #24     // r8  = x14, does rotate and move together
    ror r3, r7, #24     // r3  = x15
    mov r7, r9          // r7  = x12
    mov r9, r4          // r9  = x3
    mov r4, r11         // r4  = x1
    ror r11, r5, #25    // r11 = x7, does rotate and move together
    ror r5, r1, #25     // r5  = x6
    mov r1, r10         // r1  = x5
    pop {r10}           // r10 = x2
    
    
    # =======================================================
    # Round 20: same as 4
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
    
    # TODO: r3 and r5 are rotated in the next round 
    ror r3, r3, #24
    ror r5, r5, #25
    
    str r2, [r12, #40] 	// r2 = x10
    str r3, [r12, #60] 	// r3 = x15
    str r5, [r12, #24] 	// r5 = x6
    str r6, [r12, #44] 	// r6 = x11
    mov r2, r0          // temporarily use r2 as a swap register
    mov r0, r10         // r0 = x2
    mov r10, r4         // r10 = x1
    mov r4, r9          // r4 = x3
    ror r9, r1, #25     // r9 = x5, does rotate and move together
    mov r1, r11         // r1 = x7
    ror r11, r7, #24    // r11 = x12    
    mov r7, r8          // r7 = x14
    mov r8, r2          // r8 = x0
    ldr r2, [r12, #32] 	// r2 = x8
    ldr r3, [r12, #52] 	// r3 = x13, still needs to rotate 24, done in first eor
    ldr r5, [r12, #16] 	// r5 = x4, still needs to rotate 25
    ldr r6, [r12, #36] 	// r6 = x9
    
    ror r5, r5, #25     // TODO: merge this into the calculating instructions

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
    

    
       
    # End of 20 rounds
    # ===================================================================================================
    
    
    
    # for this last round, do the rotations 'manualy'
    ror r3, r3, #24
    ror r7, r7, #24
    ror r1, r1, #25
    ror r5, r5, #25
    
    # already stored in ram: x6, x10, x11, x15; store everything we still have lying around into x
    str r0, [r12, #8]   // r0 = x2
    str r1, [r12, #28]  // r1 = x7
    str r2, [r12, #32]  // r2 = x8
    str r3, [r12, #52]  // r3 = x13
    str r4, [r12, #12]  // r4 = x3
    str r5, [r12, #16]  // r5 = x4
    str r6, [r12, #36]  // r6 = x9
    str r7, [r12, #56]  // r7 = x14
    str r8, [r12]       // r8 = x0
    str r9, [r12, #20]  // r9 = x5
    str r10, [r12, #4]  // r10 = x1
    str r11, [r12, #48] // r11 = x12
    
    # TODO: optimise and fix moves and stores of last round
  
    
    
    

    
    
    
    
    
    
    
    
    
