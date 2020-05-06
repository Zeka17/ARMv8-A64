/*
    CPSC 355-02 - Computing Machinery 1

    Assignment 5 part A

    Alexandar Zecevic
    30045860

    This ARMv8 program utilizes global variables and seperate compilation 
    inorder to create a FIFO queue array. It will fill the array with given
    inputs through the simple given UI as well as dequeue the array and display
    the contents of the array for inspection
*/

        QUEUESIZE = 8                                                           //Equate for queue size
        MODMASK = 0X7                                                           //Equate for modmask
        FALSE = 0                                                               //Equate for false
        TRUE = 1                                                                //Equate for true

deqerr: .string "\nQueue underflow! Cannot dequeue from an empty queue.\n"      //Set dequeue error format
enqerr: .string "\nQueue overflow! Cannot enqueue into a full queue.\n"         //Set enqueue error format
diserr: .string "\nEmpty queue\n"                                               //Set display error format
cur:    .string "\nCurrent queue contents:\n"                                   //Set current contents format
headpt: .string " <-- head of queue"                                            //Set head of queue print format
tailpt: .string " <-- tail of queue"                                            //Set tail of queue print format
intid:  .string " %d"                                                           //Set integer print ID format
lf:     .string "\n"                                                            //Set line feed print format

        .data                                                                   //Following goes into data section
head:   .word -1                                                                //Set head global variable and allocates it to memory
tail:   .word -1                                                                //Set tail global variable and allocates it to memory

        .bss                                                                    //Following goes into bss section
q_m:    .skip QUEUESIZE * 4                                                     //Set queue int array global variable and allocates it to memory
        
        .text                                                                   //Return to text section
        
                                                                                //I tried many different ways of using registers for the functions for this part of
                                                                                //assignment (i.e. Calle, Caller and non defined registers from x9-x15 and x19-x28 but
                                                                                //each resulted in seg faults so I ended up using this method for preserving values
                                                                                //between function calls

                                                                                //Following registers for enqueue variables
        define(eq_val_r, w9)                                                    
        define(eq_tail_r, w10)
                                                                                //Following registers for dequeue variables
        define(dq_val_r, w11)
        define(dq_head_r, w12)
        define(dq_tail_r, w13)
                                                                                //Following registers for queueFull variables
        define(qfull_head_r, w14)
        define(qfull_tail_r, w15)
                                                                                //Following registers for queueEmpty variables
        define(qemp_head_r, w19)
                                                                                //Following registers for display variables
        define(dis_i_r, w20)
        define(dis_j_r, w21)
        define(dis_count_r, w22)
        define(dis_tail_r, w23)
        define(dis_head_r, w24)
                                                                                //Following register is a temporary register to store head, tail and queue when needed
        define(temp_r, x25)

        .balign 4                                                               //Allign instructions to 4 bits
                                                                                //Following are to make functions visible to main
        .global enqueue
        .global dequeue
        .global queueFull
        .global queueEmpty
        .global display

enqueue:    stp x29, x30, [sp, -16]!                                            //Allocates 16 bytes of memory for enqueue function
            mov x29, sp                                                         //Update x29

            mov eq_val_r, w0                                                    //Store input into eq_val_r
            
            bl queueFull                                                        //Call queueFull function to check if queue is full
            cmp w0, TRUE                                                        //Check if true
            b.ne enqif2                                                         //If not true then branch to enqif2 label

            adrp x0, enqerr                                                     //Place enqerr string in x0
            add x0, x0, :lo12:enqerr                                            //Add low 12 bits into x0
            bl printf                                                           //Call printf function
            b enqdone                                                           //Branch to function return

enqif2:     bl queueEmpty                                                       //Call queueEmpty function
            cmp w0, TRUE                                                        //Check if true
            b.ne enqelse                                                        //If not true then branch to enqelse label

            adrp temp_r, head                                                   //Place head address into temp_r
            add temp_r, temp_r, :lo12:head                                      //Add low 12 bits to temp_r
            str wzr, [temp_r]                                                   //Set temp_r = 0 (head = 0)
            adrp temp_r, tail                                                   //Place tail address into temp_r
            add temp_r, temp_r, :lo12:tail                                      //Add low12 bits to temp_r
            str wzr, [temp_r]                                                   //Set temp_r = 0 (tail = 0)
            b enqend                                                            //Branch to end of function

enqelse:    adrp temp_r, tail                                                   //Place tail address into temp_r
            add temp_r, temp_r, :lo12:tail                                      //Add low 12 bits to temp_r

            ldr eq_tail_r, [temp_r]                                             //Load temp_r into eq_tail_r
            add eq_tail_r, eq_tail_r, 1                                         //tail++
            and eq_tail_r, eq_tail_r, MODMASK                                   //AND tail with MODMASK
            str eq_tail_r, [temp_r]                                             //Set new tail

enqend:     ldr eq_tail_r, [temp_r]                                             //Place tail into tail register
            adrp temp_r, q_m                                                    //Place queue address into temp_r
            add temp_r, temp_r, :lo12:q_m                                       //Add low 12 bits to temp_r
            str eq_val_r, [temp_r, eq_tail_r, SXTW 2]                           //Store the value into the queue

enqdone:    ldp x29, x30, [sp], 16                                              //Deallocate memory
            ret                                                                 //Return to calling code

dequeue:    stp x29, x30, [sp, -16]!                                            //Allocates 16 bytes of memory for dequeue fucntion
            mov x29, sp                                                         //Update x29

            bl queueEmpty                                                       //Call queueEmpty function
            cmp w0, TRUE                                                        //Check if true
            b.ne deqif2                                                         //If not true branch to deqif2 label
            
            adrp x0, deqerr                                                     //Place deqerr string into x0
            add x0, x0, :lo12:deqerr                                            //Add low 12 bits to x0
            bl printf                                                           //Call printf function
            mov w0 , -1                                                         //Set -1 to be returned
            b deqdone                                                           //Branch to function return

deqif2:     adrp temp_r, head                                                   //Place head into temp_r
            add temp_r, temp_r, :lo12:head                                      //Add low12 bits to temp_r
            ldr dq_head_r, [temp_r]                                             //Set the head register to temp_r

            adrp temp_r, tail                                                   //Place tail into temp_r
            add temp_r, temp_r, :lo12:tail                                      //Add low 12 bits to temp_r
            ldr dq_tail_r, [temp_r]                                             //Set the tail register to temp_r

            adrp temp_r, q_m                                                    //Place queue address into temp_r
            add temp_r, temp_r, :lo12:q_m                                       //Add low 12 bits to temp_r
            ldr dq_val_r, [temp_r, dq_head_r, SXTW 2]                           //Place dequeued value into its register

            cmp dq_head_r, dq_tail_r                                            //Compare the head and the tail registers
            b.ne deqelse                                                        //If they are not equal then branch to deqelse label

            mov w26, -1                                                         //Set temp register w26 (throw away register) to -1
            adrp temp_r, head                                                   //Place head into temp_r
            add temp_r, temp_r, :lo12:head                                      //Add low 12 bits to temp_r
            str w26, [temp_r]                                                   //Store w26 into temp_r
            adrp temp_r, tail                                                   //Place tail into temp_r
            add temp_r, temp_r, :lo12:tail                                      //Add low 12 bits to temp_r
            str w26, [temp_r]                                                   //Store w26 into temp_r

            b deqend                                                            //Branch to deqend label

deqelse:    add dq_head_r, dq_head_r, 1                                         //head++
            and dq_head_r, dq_head_r, MODMASK                                   //AND head with MODMASK
            adrp temp_r, head                                                   //Place head into temp_r
            add temp_r, temp_r, :lo12:head                                      //Add low 12 bits to temp_r
            str dq_head_r, [temp_r]                                             //Set temp_r to head register

deqend:     mov w0, dq_val_r                                                    //Set return value to the dequeued value

deqdone:    ldp x29, x30, [sp], 16                                              //Deallocate memory
            ret                                                                 //Return to calling code

queueFull:  stp x29, x30, [sp, -16]!                                            //Allocates 16 bytes of memory for queueFull function
            mov x29, sp                                                         //Update x29

            adrp temp_r, tail                                                   //Place tail into temp_r
            add temp_r, temp_r, :lo12:tail                                      //Add low 12 bits to temp_r
            ldr qfull_tail_r, [temp_r]                                          //Set tail register to temp_r
            add qfull_tail_r, qfull_tail_r, 1                                   //tail++
            and qfull_tail_r, qfull_tail_r, MODMASK                             //AND tail with modmask

            adrp temp_r, head                                                   //Place head into temp_r
            add temp_r, temp_r, :lo12:head                                      //Add low 12 bits to temp_r
            ldr qfull_head_r, [temp_r]                                          //Set tail register to temp_r

            mov w0, TRUE                                                        //Set return to true
            cmp qfull_tail_r, qfull_head_r                                      //Compare tail and head
            b.eq qfulldone                                                      //If they are equal branch to function return
            mov w0, FALSE                                                       //Otherwise set return to false

qfulldone:  ldp x29, x30, [sp], 16                                              //Deallocate memory
            ret                                                                 //Return to calling code

queueEmpty: stp x29, x30, [sp, -16]!                                            //Allocates 16 bytes of memory for queueEmpty function
            mov x29, sp                                                         //Updates x29

            adrp temp_r, head                                                   //Place head into temp_r
            add temp_r, temp_r, :lo12:head                                      //Add low 12 bits to temp_r
            mov w0, TRUE                                                        //Set return to true
            ldr qemp_head_r, [temp_r]                                           //Place temp_r into head register
            cmp qemp_head_r, -1                                                 //Check to see if head is equal to -1
            b.eq qempdone                                                       //If it is then branch to function return
            mov w0, FALSE                                                       //Otherwise return false

qempdone:   ldp x29, x30, [sp], 16                                              //Deallocate memory
            ret                                                                 //Return to calling code

display:    stp x29, x30, [sp, -16]!                                            //Allocate 16 bytes of memory for display function
            mov x29, sp                                                         //Update x29

            bl queueEmpty                                                       //Call queueEmpty function
            cmp w0, TRUE                                                        //Check to see if it return true
            b.ne disif2                                                         //If it didnt then branch to disif2 label

            adrp x0, diserr                                                     //Place Empty Queue format into x0
            add x0, x0, :lo12:diserr                                            //Add low 12 bits into x0
            bl printf                                                           //Call printf function
            b dispdone                                                          //Branch to function return

disif2:     adrp temp_r, head                                                   //Place head into temp_r
            add temp_r, temp_r, :lo12:head                                      //Add low 12 bits to temp_r
            ldr dis_head_r, [temp_r]                                            //Load temp_r into head register (w11)

            adrp temp_r, tail                                                   //Place tail into temp_r
            add temp_r, temp_r, :lo12:tail                                      //Add low 12 bits to temp_r
            ldr dis_tail_r, [temp_r]                                            //Load temp_r into tail register (w12)

            sub dis_count_r, dis_tail_r, dis_head_r                             //count = tail - head
            add dis_count_r, dis_count_r, 1                                     //count++

            cmp dis_count_r, 0                                                  //Check if count is 0
            b.gt next                                                           //If it is greater then branch to next label
            add dis_count_r, dis_count_r, QUEUESIZE                             //Otherwise add QUEUESIZE to count

next:       adrp x0, cur                                                        //Place cur format into x0
            add x0, x0, :lo12:cur                                               //Add low 12 bits to x0
            bl printf                                                           //Call printf function

            mov dis_i_r, dis_head_r                                             //i=head
            mov dis_j_r, 0                                                      //j=0
            b test                                                              //Branch to test label for the loop

disfor:     adrp x0, intid                                                      //Place the integer print ID to x0
            add x0, x0, :lo12:intid                                             //Add low 12 bits into x0
            adrp temp_r, q_m                                                    //Place queue into temp_r
            add temp_r, temp_r, :lo12:q_m                                       //Add low 12 bits to temp_r
            ldr w1, [temp_r, dis_i_r, SXTW 2]                                   //Set w1 as i index
            bl printf                                                           //Call printf function

            cmp dis_i_r, dis_head_r                                             //Compare i index to head register
            b.ne nothead                                                        //If not equal to then branch to nothead label
            adrp x0, headpt                                                     //Place head of queue format into x0
            add x0, x0, :lo12:headpt                                            //Add low 12 bits to x0
            bl printf                                                           //Call printf function

nothead:    cmp dis_i_r, dis_tail_r                                             //Compare i index to tail register
            b.ne nottail                                                        //If not equal to then brancht to nottail label
            adrp x0, tailpt                                                     //Place tail of queue format into x0
            add x0, x0, :lo12:tailpt                                            //Add low 12 bits to x0
            bl printf                                                           //Call printf function

nottail:    adrp x0, lf                                                         //Place line feed format into x0
            add x0, x0, :lo12:lf                                                //Add low 12 bits to x0
            bl printf                                                           //Call printf function
            add dis_i_r, dis_i_r, 1                                             //i++
            and dis_i_r, dis_i_r, MODMASK                                       //AND i index with modmask

            add dis_j_r, dis_j_r, 1                                             //j++

test:       cmp dis_j_r, dis_count_r                                            //Compare the j index to count
            b.lt disfor                                                         //Branch to top of for loop if less then

dispdone:   ldp x29, x30, [sp], 16                                              //Deallocate memory
            ret                                                                 //Return to calling code
