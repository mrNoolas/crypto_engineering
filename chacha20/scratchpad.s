
    
    
# ===================================================================================================
    # Start of 20 rounds
    
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
    
    # r3 and r5 are rotated in the next round
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
    
    
    # =======================================================
    # In round 3.1 and 3.2 we need: x0, x1, x4, x5, x8, x9, x12 and x13
    # We still have around: r8 = x0; r9 = x5; r10 = x1; r11 = x12
    # store and use some other values we have around now anyway to save loads and stores
    # r2 = x8 and r6 = x9  should stay the same
    mov r3, r11         // r3 = x12
    mov r11, r0         // r11 = x2, store for later use
    mov r0, r8          // r0 = x0
    ror r8, r1, #25     // r8 = x7, store for later use and rotate while we are at it
    ror r1, r5, #25     // r1 = x4, rotate while we are at it
    mov r5, r9          // r5 = x5
    mov r9, r4          // r9 = x3, store for later use
    mov r4, r10         // r4 = x1
    ror r10, r7, #24    // r10 = x14, store for later use and rotate while we are at it
    ror r7, r3, #24     // r7 = x13, rotate while we are at it
    
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


    # In round 3.3 and 3.4 we need: x2, x3, x6, x7, x10, x11, x14 and x15
    # We still have around: r8 = x7; r9 = x3; r10 = x14; r11 = x2

    # Quarter round 3.3 and 3.4:
    # load everything thats still around and store some things for later
    mov r1, r0          // r1 = x0, swap register
    mov r0, r11         // r0 = x2
    mov r11, r4         // r11 = x1, store for later
    mov r4, r9          // r4 = x3
    ror r9, r3, #24     // r9 = x12, store for later does rotate and move together
    mov r3, r10         // r3 = x14
    ror r10, r5, #25    // r10 = x5, store for later does rotate and move together
    mov r5, r8          // r5 = x7
    mov r8, r1          // r8 = x0, store for later (uses swap register from earlier)
     
    
    # use pointer to load values from memory:
    ldr r1, [r12, #24] 	// r1 = x6  still needs to be rotated by 25 
    ldr r2, [r12, #40]  // r2 = x10
    ldr r6, [r12, #44]  // r6 = x11
    ldr r7, [r12, #60]  // r7 = x15 still needs to be rotated by 24
    
    ror r1, r1, #25     // TODO: merge this into the calculating instructions

    # two quarter rounds (more info in quarterround/quarterround.s)
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
    
    # r1, r3, r5 and r7 are rotated in a move later

    # swap some registers to prepare for round 4:
    # r2 and r6 should stay where they are for round 4  (r2 = x10; r6 = x11)
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
    # Quarter round 4.1 and 4.2:
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
    
    # r3 and r5 are rotated in next round
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
    
    
    # Quarter round 4.3 and 4.4:
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
    
    # =======================================================
    # Round 5; same as round 3
    mov r3, r11         // r3 = x12
    mov r11, r0         // r11 = x2, store for later use
    mov r0, r8          // r0 = x0
    
    // TODO: these two instructions cause problems!
    ror r8, r1, #25     // r8 = x7, store for later use and rotate while we are at it
    ror r1, r5, #25     // r1 = x4, rotate while we are at it    
    
    mov r5, r9          // r5 = x5
    mov r9, r4          // r9 = x3, store for later use
    mov r4, r10         // r4 = x1
    ror r10, r7, #24    // r10 = x14, store for later use and rotate while we are at it
    ror r7, r3, #24     // r7 = x13, rotate while we are at it  
    
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
    # Round 6: same as 4
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
    
    # =======================================================
    # Round 7; same as round 3
    mov r3, r11         // r3 = x12
    mov r11, r0         // r11 = x2, store for later use
    mov r0, r8          // r0 = x0
    ror r8, r1, #25     // r8 = x7, store for later use and rotate while we are at it
    ror r1, r5, #25     // r1 = x4, rotate while we are at it
    mov r5, r9          // r5 = x5
    mov r9, r4          // r9 = x3, store for later use
    mov r4, r10         // r4 = x1
    ror r10, r7, #24    // r10 = x14, store for later use and rotate while we are at it
    ror r7, r3, #24     // r7 = x13, rotate while we are at it  
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
    # Round 8: same as 4
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
    

    # =======================================================
    # Round 9; same as round 3
    mov r3, r11         // r3 = x12
    mov r11, r0         // r11 = x2, store for later use
    mov r0, r8          // r0 = x0
    ror r8, r1, #25     // r8 = x7, store for later use and rotate while we are at it
    ror r1, r5, #25     // r1 = x4, rotate while we are at it
    mov r5, r9          // r5 = x5
    mov r9, r4          // r9 = x3, store for later use
    mov r4, r10         // r4 = x1
    ror r10, r7, #24    // r10 = x14, store for later use and rotate while we are at it
    ror r7, r3, #24     // r7 = x13, rotate while we are at it  
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
    # Round 10: same as 4
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
    
    
    # =======================================================
    # Round 11; same as round 3
    mov r3, r11         // r3 = x12
    mov r11, r0         // r11 = x2, store for later use
    mov r0, r8          // r0 = x0
    ror r8, r1, #25     // r8 = x7, store for later use and rotate while we are at it
    ror r1, r5, #25     // r1 = x4, rotate while we are at it
    mov r5, r9          // r5 = x5
    mov r9, r4          // r9 = x3, store for later use
    mov r4, r10         // r4 = x1
    ror r10, r7, #24    // r10 = x14, store for later use and rotate while we are at it
    ror r7, r3, #24     // r7 = x13, rotate while we are at it  
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
    # Round 12: same as 4
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
    
    # =======================================================
    # Round 13; same as round 3
    mov r3, r11         // r3 = x12
    mov r11, r0         // r11 = x2, store for later use
    mov r0, r8          // r0 = x0
    ror r8, r1, #25     // r8 = x7, store for later use and rotate while we are at it
    ror r1, r5, #25     // r1 = x4, rotate while we are at it
    mov r5, r9          // r5 = x5
    mov r9, r4          // r9 = x3, store for later use
    mov r4, r10         // r4 = x1
    ror r10, r7, #24    // r10 = x14, store for later use and rotate while we are at it
    ror r7, r3, #24     // r7 = x13, rotate while we are at it  
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
    # Round 14: same as 4
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
    

    # =======================================================
    # Round 15; same as round 3
    mov r3, r11         // r3 = x12
    mov r11, r0         // r11 = x2, store for later use
    mov r0, r8          // r0 = x0
    ror r8, r1, #25     // r8 = x7, store for later use and rotate while we are at it
    ror r1, r5, #25     // r1 = x4, rotate while we are at it
    mov r5, r9          // r5 = x5
    mov r9, r4          // r9 = x3, store for later use
    mov r4, r10         // r4 = x1
    ror r10, r7, #24    // r10 = x14, store for later use and rotate while we are at it
    ror r7, r3, #24     // r7 = x13, rotate while we are at it  
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
    # Round 16: same as 4
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
    
     # =======================================================
    # Round 17; same as round 3
    mov r3, r11         // r3 = x12
    mov r11, r0         // r11 = x2, store for later use
    mov r0, r8          // r0 = x0
    ror r8, r1, #25     // r8 = x7, store for later use and rotate while we are at it
    ror r1, r5, #25     // r1 = x4, rotate while we are at it
    mov r5, r9          // r5 = x5
    mov r9, r4          // r9 = x3, store for later use
    mov r4, r10         // r4 = x1
    ror r10, r7, #24    // r10 = x14, store for later use and rotate while we are at it
    ror r7, r3, #24     // r7 = x13, rotate while we are at it  
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
    # Round 18: same as 4
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
    
    # =======================================================
    # Round 19; same as round 3
    mov r3, r11         // r3 = x12
    mov r11, r0         // r11 = x2, store for later use
    mov r0, r8          // r0 = x0
    ror r8, r1, #25     // r8 = x7, store for later use and rotate while we are at it
    ror r1, r5, #25     // r1 = x4, rotate while we are at it
    mov r5, r9          // r5 = x5
    mov r9, r4          // r9 = x3, store for later use
    mov r4, r10         // r4 = x1
    ror r10, r7, #24    // r10 = x14, store for later use and rotate while we are at it
    ror r7, r3, #24     // r7 = x13, rotate while we are at it  
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
    
