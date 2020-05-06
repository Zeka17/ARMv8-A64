/*
    CPSC 355-02 - Computing Machiner 1
    Prof. Leonard Manzara

    Assignment 3

    Alexandar Zecevic
    30045860

    This ARMv8 A64 program which builds an array with a size of 50 with random
    integers. It then sorts the array using insertion sort from smallest to
    largest and prints out the array to the screen
*/

print1:     .string "v[%d]: %d\n"                                               //The first print label, for printing each section of the array

print2:     .string "\nSorted array:\n"                                         //The second print label, for printing the title for the sorted array


            index_size = 4                                                      //Size of each element in the array, 4 bytes or word
            array_size = 50                                                     //Defines the array size as 50 units
            b_size = array_size*index_size                                      //Allocates 200 bytes in memory for the array
            alloc = -(16 + 16 + array_size) & -16                               //Set the pre-increment value, for updating SP. AND is for quadword allignment
            dealloc = -alloc                                                    //Set the post-increment value

            i_s = 16                                                            //Sets the stack offset for i variable to 16
            j_s = 20                                                            //Sets the stack offset for j variable to 20
            temp_s = 24                                                         //Sets the stack offset for the temp variable to 24
            b_s = 28                                                            //Sets the stack offset for the base of the array to 28

            .align 4                                                            //Word alligns instructions
            .global main                                                        //Makes main visible to OS

            define(base_r, x28)                                                 //Defines the register for the address of the base of the array
            define(i_r, w26)                                                    //Defines the register for the i index
            define(j_r, w27)                                                    //Defines the register for the j index
            define(temp_r, w20)                                                 //Defines the register& for the temp register
            define(jmin_r, w21)                                                 //Defines a register for j - 1

            fp .req x29                                                         //Defines FP as x29
            lr .req x30                                                         //Defines LR as x30

main:       stp fp, lr, [sp, alloc]!                                            //Saves FP and LR to stack, and allocates amount defined in alloc, pre-increments SP
            mov fp, sp                                                          //Updates FP to SP

            mov base_r, fp                                                      //Moves FP to base_r
            add base_r, base_r, b_s                                             //Sets location of base array to FP + base offset

            mov i_r, 0                                                          //Sets i to zero
            str i_r, [fp, i_s]                                                  //Writes i to the stack

            b test1                                                             //Branches to test1

loop1:      ldr i_r, [fp, i_s]                                                  //Loads i from memory

            bl rand                                                             //Gets random number from random number generator
            AND w0, w0, 0xff                                                    //Checks to see that the number is between 0 and 255
            str w0, [base_r, i_r, SXTW 2]                                       //Stores data from w0 to v[i], sign extend to fit into 64 bit registers

            ldr w22, [base_r, i_r, SXTW 2]                                      //Reads from v[i] and stores it in w22

            adrp x0, print1                                                     //Sets first argument x0 for printf                                             
            add w0, w0, :lo12:print1                                            //Add the low 12 bits to w0
            mov w1, i_r                                                         //Places i register into w1
            mov w2, w22                                                         //Places contents of w22 into w2
            bl printf                                                           //Calls printf function

            ldr i_r, [fp, i_s]                                                  //Get current i
            add i_r, i_r, 1                                                     //Increment i by 1
            str i_r, [fp, i_s]                                                  //Store new i in memory

test1:      cmp i_r, array_size                                                 //Checks to see if i < 50
            b.lt loop1                                                          //Branches to first loop

            ldr i_r, [fp, i_s]                                                  //Loads i from memory
            mov i_r, 1                                                          //Sets i = 1
            str i_r, [fp, i_s]                                                  //Stores i into memory

            b test2a                                                            //Branches to the test for loop 2a

loop2a:     ldr temp_r, [base_r, i_r, SXTW 2]                                   //Loads v[i] from memory and stores it in temp
            str temp_r, [fp, temp_s]                                            //Stores v[i] in memory
            ldr j_r, [fp, i_s]                                                  //Sets j = i
            str j_r, [fp, j_s]                                                  //Stores j in memory

            b test2b                                                            //Branches to the test for loop 2b

loop2b:     ldr j_r, [fp, j_s]                                                  //Loads j from memory
            sub jmin_r, j_r, 1                                                  //Sets jmin = j - 1
            ldr w22, [base_r, jmin_r, SXTW 2]                                   //Loads v[j-1] to temp register w22
            str w22, [base_r, j_r, SXTW 2]                                      //Sets v[j] = v[j-1]
            str jmin_r, [fp, j_s]                                               //Stores j-1 in memory

test2b:     ldr j_r, [fp, j_s]                                                  //Loads j_r from memory
            cmp j_r, 0                                                          //Compare j to 0
            b.le endloop2                                                       //If j <= 0 then branch to end of loop 2
            ldr temp_r, [fp, temp_s]                                            //Loads temp from memory
            sub jmin_r, j_r, 1                                                  //Sets j = j - 1
            ldr w22, [base_r, jmin_r, SXTW 2]                                   //Puts v[j-1] in temp register w22
            cmp temp_r, w22                                                     //Compare temp and w22
            b.ge endloop2                                                       //If temp >= v[j-1] then branch to end of loop 2

            b loop2b                                                            //Branch back to the start of the loop

endloop2:   ldr temp_r, [fp, temp_s]                                            //Loads temp from memory
            ldr j_r, [fp, j_s]                                                  //Loads j from memory
            str temp_r, [base_r, j_r, SXTW 2]                                   //Stores temp into v[j]
            
            ldr i_r, [fp, i_s]                                                  //Loads i from memory
            add i_r, i_r, 1                                                     //Adds one to i
            str i_r, [fp, i_s]                                                  //Stores i into memory

test2a:     cmp i_r, array_size                                                 //Checks to see if i < 50
            b.lt loop2a                                                         //Branches to second loop part a

            adrp x0, print2                                                     //Sets first argument x0 for printf
            add w0, w0, :lo12:print2                                            //Adds low 12 bits to w0
            bl printf                                                           //Calls the function printf

            ldr i_r, [fp, i_s]                                                  //Loads i from memory
            mov i_r, 0                                                          //Sets i = 0
            str i_r, [fp, i_s]                                                  //Stores i into memory

            b test3                                                             //Branches to the test for the third loop

loop3:      ldr temp_r, [base_r, i_r, SXTW 2]                                   //Loads v[i] into temp

            adrp x0, print1                                                     //Sets first argument x0 for printf
            add w0, w0, :lo12:print1                                            //Adds the low 12 bits to w0
            mov w1, i_r                                                         //Moves i into w1
            mov w2, temp_r                                                      //Moves temp into w2
            bl printf                                                           //Calls the printf function

            add i_r, i_r, 1                                                     //Adds 1 to i
            str i_r, [fp, i_s]                                                  //Stores i into memory

test3:      cmp i_r, array_size                                                 //Compares i to the array size (50)
            b.lt loop3                                                          //If i < 50 then branch to the third loop
            
done:       mov w0, 0                                                           //Return 0 to OS
            ldp fp, lr, [sp], dealloc                                           //De-allocate stack memory
            ret                                                                 //Returns to caller
