/*
    CPSC 355-02 - Computing Machinery 1
    Prof Leonard Manzara

    Assignment 2b

    Alexandar Zecevic
    30045860

    This ARMv8 A64 program that does interger multiplication

    Part A) See file assign2a.asm
    Part B) This verison of the program uses the multipplier 200 with the
            multiplicand 522133279
    Part C) See file assign2c.asm
*/

string1:
        .string "multiplier = 0x%08x (%d) multiplicand = 0x%08x (%d)\n\n"       //Sets the format for the first
        .balign 4                                                               //Aligns instructions by 4 bits

string2:
        .string "Product = 0x%08x multiplier = 0x%08x\n"                        //Sets the format for the secound output
        .balign 4                                                               //Aligns instructions by 4 bits

string3: 
        .string "64-bit result = 0x%016lx (%ld)\n"                              //Sets the format for the third output
        .balign 4                                                               //Aligns instructions by 4 bits

        .global main                                                            //Makes main visible to the linker

main:   stp x29, x30, [sp, -16]!                                                //Saves FP and LR to stack, allocates 16 bytes and preincrements SP
        mov x29, sp                                                             //Updates FP to SP
        
                                                                                //***Following registers are all 32-bit registers***
        define(false_r, w19)                                                    //Saves a register for the false interger
        define(true_r, w20)                                                     //Saves a register for the true interger
        define(multiplier_r, w21)                                               //Saves a register for the multiplier
        define(multiplicand_r, w22)                                             //Saves a register for the multiplicand
        define(product_r, w23)                                                  //Saves a register for the product
        define(i_r, w24)                                                        //Saves a register for the counter
        define(negative_r, w25)                                                 //Saves a register for the negative interger

                                                                                //***Following registers are all 64-bit registers***
        define(result_r, x19)                                                   //Saves a register for the result
        define(temp1_r, x20)                                                    //Saves a register for 1 temporary register
        define(temp2_r, x21)                                                    //Saves a register for another temporary register

        mov false_r, 0                                                          //Sets the false register to zero
        mov true_r, 1                                                           //Sets the true register to one
        mov multiplicand_r, 522133279                                           //Sets the multiplicand register to 522133279
        mov multiplier_r, 200                                                   //Sets the multiplier register to 200
        mov product_r, 0                                                        //Sets the product to zero

                                                                                //***Following is for the first output***
        adrp x0, string1                                                        //Sets the first argument for printf
        add x0, x0, :lo12:string1                                               //Add the low 12 bits to x0
        mov w1, multiplier_r                                                    //Place the value of the multiplier register into w1
        mov w2, multiplier_r                                                    //Same as above but just into w2
        mov w3, multiplicand_r                                                  //Place the value of the multiplicand register into w3
        mov w4, multiplicand_r                                                  //Same as above but just into w4
        bl printf                                                               //Calls printf function

        cmp multiplier_r, wzr                                                   //Compares the multiplier register to zero register to check if it is negative
        b.ge else                                                               //Branches to else if it is not negative

        mov negative_r, true_r                                                  //Stores true in the negative register if the number is negative
        b next1                                                                 //Branches to first next skipping else

else:   mov negative_r, false_r                                                 //Stores false in the negative register if the number is positive

next1:  mov i_r, 0                                                              //Sets i register to zero
        b test                                                                  //Branches to the test for the loop

loop:   AND w26, multiplier_r, 0x1                                              //Does an AND operation and stores it in w26 
        cmp w26, 0                                                              //Compare the result of the AND to zero
        b.eq next2                                                              //Branches to the the secound next indicating that the if statement was false
        
        add product_r, product_r, multiplicand_r                                //Product = product + multiplicand

next2:  asr multiplier_r, multiplier_r , 1                                      //Arithmetic shift right by 1
        
        AND w26, product_r, 0x1                                                 //Does an AND operation and stores it in w26
        cmp w26, 0                                                              //Compare the reult of the AND to zero
        b.eq next3                                                              //Branches to the third next indicating that the if statement was false and skips ORR operation

        orr multiplier_r, multiplier_r, 0x80000000                              //Does an ORR operation and stores it in the multiplier register
        b next4                                                                 //Branches to the fourth next

next3:  AND multiplier_r, multiplier_r, 0x7FFFFFFF                              //Does an AND operation and stores it in multiplier 

next4:  asr product_r, product_r, 1                                             //Arithmetic shift right by 1

        add i_r, i_r, 1                                                         //Adds 1 to the counter register

test:   cmp i_r, 32                                                             //Compares the counter register to 32 
        b.lt loop                                                               //Branches to the loop if i is less the 32

        cmp negative_r, false_r                                                 //Checks if negative is false
        b.eq next5                                                              //Branches to fifth next if it is negative

        sub product_r, product_r, multiplicand_r                                //Product = product - multiplicand

                                                                                //***The following is for the 2nd output***
next5:  adrp x0, string2                                                        //Sets the first argument for printf
        add x0, x0, :lo12:string2                                               //Add the low 12 bits to x0
        mov w1, product_r                                                       //Place the value of the product register into w1
        mov w2, multiplier_r                                                    //Place the value of the multiplicand register into w2
        bl printf                                                               //Calls printf function

        sxtw temp1_r, product_r                                                 //Move product into temp registry
        AND temp1_r, temp1_r, 0xFFFFFFFF                                        //Does an AND operation and stores it in temp1 register
        lsl temp1_r, temp1_r, 32                                                //Shifts value of temp1 register over 32 bits

        sxtw temp2_r, multiplier_r                                              //Move multiplier into temp2 register
        AND temp2_r, temp2_r, 0xFFFFFFFF                                        //Does an AND operation and stores it in temp2

        add result_r, temp1_r, temp2_r                                          //Adds the 2 temp registers and stores it into the result register

                                                                                //***The following is for the 3rd output***
        adrp x0, string3                                                        //Sets the first argument for printf
        add x0, x0, :lo12:string3                                               //Add the low 12 bits to x0
        mov x1, result_r                                                        //Place the value of the result register into x1
        mov x2, result_r                                                        //Same as above just for x2
        bl printf                                                               //Calls the printf function

done:   ldp x29, x30, [sp], 16                                                  //Restore FP ans LR from the stack, post increments SP by 16
        ret                                                                     //Return to caller
