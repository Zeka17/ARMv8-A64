/*
    CPSC 355-02 - Computing Machinery 1
    Prof. Leonard Manzara
    
    Assignment 6
    
    Alexandar Zecevic
    30045860
    
    This ARMv8 A64 program computed the cube root of positive real numbers
    using Newtons Method. The program accomplishes this buy opening a file that
    contains double precision floating point numbers and runs them through the
    Newtons Method Algorithim.
*/

            .data                                                               //Begining of the data section
constant:   .double 0r3.0                                                       //The constant for the guess (will also be used to compute the derivative but as a multiplier)
con_limit:  .double 0r1.0e-10                                                   //The limit of when to stop Newtons Method

            .text                                                               //Return to the text section
            buf_size = 8                                                        //Create buffer to load 8-byte inputs into
            alloc = -(16 + buf_size) & -16                                      //For memory allocation
            dealloc = -alloc                                                    //For memory deallocation
            buf_s = 16                                                          //Buffer offset

            i_r .req w19                                                        //index counter
            argc_r .req w20                                                     //Argument counter
            argv_r .req x21                                                     //Argument values
            fd_r .req w22                                                       //File descriptor register
            buf_base_r .req x23                                                 //Base register for buffer
            read_base_r .req x24                                                //Base for bytes read from input

opening:    .string "Opening file: %s\n"                                        //Print format for opening files
eof:        .string "End of file reached.\n"                                    //Print format for end of file
closing:    .string "Closing file: %s\n"                                        //Print format for closing files
arg_err:    .string "Incorrect number of arguments. Usage: ./a6 <filename>\n"   //Print format for incorrect number of args error
file_err:   .string "Filename %s not found.\n"                                  //Print format for non-existent file error
header:     .string "|  Real Numbers  |  Cube Roots  |\n"                       //Print format for the table header
vals:       .string "  %13.10f  | %13.10f \n"                                   //Print format for the values of the table

            .balign 4                                                           //Allign instructions by 4 bytes

newton:     stp x29, x30, [sp, -16]!                                            //Allocate 16 bytes of memory for newton function
            mov x29, sp                                                         //Update x29

            fmov d9, d12                                                        //Move input into d9

            adrp x10, con_limit                                                 //Place address of the convergence into x10
            add x10, x10, :lo12:con_limit                                       //Add low 12 bits into x10
            ldr d10, [x10]                                                      //Load x10 into d10

            adrp x11, constant                                                  //Place address of the constant into x11
            add x11, x11, :lo12:constant                                        //Add low 12 bits into x11
            ldr d11, [x11]                                                      //load x11 into d11

            fdiv d12, d9, d11                                                   //d12 = x (x = input / 3.0)
            
loop:       fmul d13, d12, d12                                                  //d13 = y (y = x * x)
            fmul d13, d13, d12                                                  //y = y * x

            fsub d17, d13, d9                                                   //d17 = dy (dy = y - input)

            fmul d14, d12, d12                                                  //d14 = d (d = x * x)
            fmul d14, d14, d11                                                  //d = d * 3

            fdiv d15, d17, d14                                                  //d15 = dy/d (dy/d = dy/d)

            fsub d12, d12, d15                                                  //x = x - (dy/d)

            fabs d17, d17                                                       //dy = |dy|

            fmul d16, d9, d10                                                   //d16 = input * 1.0e-10

            fcmp d17, d16                                                       //Compare dy and (input * 1.0e-10)
            b.ge loop                                                           //If greater then or equal to then branch back to top of loop

newt_done:  fmov d0, d12
            ldp x29, x30, [sp], 16                                              //Deallocate memory
            ret                                                                 //Return to calling code

            .global main                                                        //Make main visible to OS

main:       stp x29, x30, [sp, alloc]!                                          //Allocates memory for main
            mov x29, sp                                                         //Updates x29

            mov argc_r, w0                                                      //Move argument counter input into its register
            mov argv_r, x1                                                      //Move argument value into its register

            cmp argc_r, 2                                                       //Compare number of args to 2
            b.eq open                                                           //If equal branch to next1 label

            adrp x0, arg_err                                                    //Place arg_err format into x0
            add x0, x0, :lo12:arg_err                                           //Add low 12 bits to x0
            bl printf                                                           //Call printf function
            b done                                                              //Branch to main return

open:       adrp x0, opening                                                    //Place opening format into x0
            add x0, x0, :lo12:opening                                           //Add low 12 bits to x0
            ldr x1, [argv_r, 8]                                                 //Load file name into x1
            bl printf                                                           //Call printf function

            mov w0, -100                                                        //Reading from file
            ldr x1, [argv_r, 8]                                                 //Place input into x1
            mov w2, 0                                                           //Move zero into w2
            mov w3, 0                                                           //Move zero into w3
            mov x8, 56                                                          //Openat I/O request
            svc 0                                                               //Call system function
            mov fd_r, w0                                                        //Move result into file descriptor

            cmp fd_r, 0                                                         //Compare fd_r to zero
            b.ge next                                                           //If greater then branch to next2 label

            adrp x0, file_err                                                   //Place file not found error format into x0
            add x0, x0, :lo12:file_err                                          //Add low 12 bits into x0
            ldr x1, [argv_r, 8]                                                 //Put filename into x1
            bl printf                                                           //Call printf function
            b done                                                              //Branch to main return

next:       adrp x0, header                                                     //Place header format into x0
            add x0, x0, :lo12:header                                            //Add low 12 bits to x0
            bl printf                                                           //Call printf function

            add buf_base_r, x29, buf_s                                          //Set base address
             
calculate:  mov w0, fd_r                                                        //Place file descriptor into w0
            mov x1, buf_base_r                                                  //Place base address into x1
            mov w2, buf_size                                                    //Place buffer size into w2
            mov x8, 63                                                          //Read I/O request
            svc 0                                                               //Call system function

            mov read_base_r, x0                                                 //Place results into read_base_r
            
            cmp read_base_r, buf_size                                           //Compare the bytes read to the buffer size
            b.ne close                                                          //If they are not equal then branch to close label
            
            ldr d12, [buf_base_r]                                               //Load buf_base_r into d12
            bl newton                                                           //Call newton function
            fmov d1, d0                                                         //Move return value into d1

            adrp x0, vals                                                       //Place the output printout into x0
            add x0, x0, :lo12:vals                                              //Add low 12 bits to x0
            ldr d0, [buf_base_r]            
            bl printf                                                           //Call printf function
             
            b calculate                                                         //Branch back to top of loop 

close:      adrp x0, eof                                                        //Place eof format into x0
            add x0, x0, :lo12:eof                                               //Add low 12 bits into x0
            bl printf                                                           //Call printf function

            adrp x0, closing                                                    //Place closing format into x0
            add x0, x0, :lo12:closing                                           //Add low 12 bits into x0
            ldr x1, [argv_r, 8]                                                 //Place filename into x1
            bl printf                                                           //Call printf function

            mov w0, fd_r                                                        //Move file descriptor into w0
            mov x8, 57                                                          //Close I/O request
            svc 0                                                               //Call system function

done:       ldp x29, x30, [sp], dealloc                                         //Deallocate memory
            ret                                                                 //Return to calling code
