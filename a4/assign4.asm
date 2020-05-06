/*
    CPSC 355-02 - Computing Machinery 1

    Assignment 4

    Alexandar Zecevic
    30045860

    This ARMv8 A64 program utilizes subroutines and structs inorder to create 
    2 boxes and modifies the first box and prints the details of both boxes to 
    standard output i.e. the screen
*/
print1:     .string "Box %s origin = (%d, %d) width = %d height = %d area = %d\n"    //Print format for box details
print2:     .string "first"                                                          //Print format for "first"
print3:     .string "second"                                                         //Print format for "second"
print4:     .string "Initial box values:\n"                                          //Print format for "Initial box values"
print5:     .string "\nChanged box values:\n"                                        //Print format for "Changed box values" 

            .balign 4                                                           //Aligns intructions by 4 bits
            .global main                                                        //Makes main visible to OS

            fp .req x29                                                         //Defines x29 as FP
            lr .req x30                                                         //Defines x30 as lr

            point_x = 0                                                         //X variable offset for point struct from base
            point_y = 4                                                         //Y variable offset for point struct from base
            struct_point_size = 8                                               //Size of the struct point

            dimension_width = 0                                                 //Width variable offset for dimension struct from base
            dimension_height = 4                                                //Height variable offset for dimension struct from base
            struct_dimension_size = 8                                           //Size of struct dimension

            box_origin = 0                                                      //Origin variabel offset for box struct from base
            box_dimension = 8                                                   //Dimension variable offset for box struct from base
            box_area = 16                                                       //Area variable offset for box struct from base
            struct_box_size = 20                                                //Size of struct box

            box1 = struct_box_size                                              //Allocates memory for box 1 in memory
            box2 = struct_box_size                                              //Allocates memory for box 2 in memory
            alloc = -(16 + box1 + box2) & -16                                   //Defines total memory needed
            dealloc = -alloc                                                    //Defines total memory needed for deallocation
            box1_s = 16                                                         //Frame record offset for box 1
            box2_s = box1_s + struct_box_size                                   //Frame record offset for box 2

            FALSE = 0                                                           //Defines false as 0
            TRUE = 1                                                            //Defines true as 1

newbox:     stp x29, x30, [sp, -16]!                                            //Allocates 16 bytes memory for newbox
            mov fp, sp                                                          //fp = sp

            mov w9, 0                                                           //Sets temp register w9 to 0
            mov w10, 1                                                          //Sets temp register w10 to 1

            str w9, [x0, box_origin + point_x]                                  //b.origin.x = 0
            str w9, [x0, box_origin + point_y]                                  //b.origin.y = 0
            str w10, [x0, box_dimension + dimension_width]                      //b.size.width = 1
            str w10, [x0, box_dimension + dimension_height]                     //b.size.height = 1
            str w10, [x0, box_area]                                             //b.size.area = 1

            mov w0, 0                                                           //Restore w0 to 0
ret1:       ldp x29, x30, [sp], 16                                              //Deallocate subroutine
            ret                                                                 //Returns control to calling code

move:       stp x29, x30, [sp, -16]!                                            //Allocates 16 bytes of memory for move
            mov fp, sp                                                          //Resets SP to FP

            mov x9, x0                                                          //x9 is the base of the box struct that will be moved
            mov w10, w1                                                         //w10 int deltaX
            mov w11, w2                                                         //w11 int deltaY

            ldr w12, [x9, box_origin + point_x]                                 //Load x value of current box into w12
            add w12, w24, w10                                                   //newX = X + deltaX
            str w12, [x9, box_origin + point_x]                                 //Store new X in memory

            ldr w12, [x9, box_origin + point_y]                                 //Load y value of current box into w12
            add w12, w24, w11                                                   //newY = Y + deltaY
            str w12, [x9, box_origin + point_y]                                 //Store new Y in memory

            mov x0, 0                                                           //Restore x0 to 0
            mov w1, 0                                                           //Restore w1 to 0
            mov w2, 0                                                           //Restore w2 to 0
            
ret2:       ldp x29, x30, [sp], 16                                              //Deallocate subroutine
            ret                                                                 //Returns control to calling code

expand:     stp x29, x30, [sp, -16]!                                            //Allocate 16 bytes of memory for expand
            mov fp, sp                                                          //Resets SP to FP

            mov x9, x0                                                          //x9 is the base of the box struct that will be expanded
            mov w10, w1                                                         //w10 is the factor

            ldr w11, [x9, box_dimension + dimension_width]                      //Loads box.dimension.width from memory
            mul w11, w11, w10                                                   //Multiply width by factor
            str w11, [x9, box_dimension + dimension_width]                      //Store new width in memory

            ldr w12, [x9, box_dimension + dimension_height]                     //Loads box.dimension.height
            mul w12, w12, w10                                                   //Multiply height by factor
            str w12, [x9, box_dimension + dimension_height]                     //Stores new height in memory

            mul w12, w12, w11                                                   //Area = height * width
            str w12, [x9, box_area]                                             //Store new area in memory

            mov x0, 0                                                           //Reset x0 to 0
            mov w1, 0                                                           //Reset w1 to 0

ret3:       ldp x29, x30, [sp], 16                                              //Deallocate subroutine
            ret                                                                 //Return control to calling code

printbox:   stp x29, x30, [sp, -16]!                                            //Allocate 16 bytes of memory for printbox
            mov fp, sp                                                          //Resets SP to FP

            mov x9, x0                                                          //Move base address in x0 to x9
            mov x10, x1                                                         //Move string input into x10

            adrp x0, print1                                                     //Loads x0 with print1
            add w0, w0, :lo12:print1                                            //Adds low 12 bits to w0
            ldr w2, [x9, box_origin + point_x]                                  //Load box.origin.x into w2
            ldr w3, [x9, box_origin + point_y]                                  //Load box.origin.y into w3
            ldr w4, [x9, box_dimension + dimension_width]                       //Load box.dimension.width into w4
            ldr w5, [x9, box_dimension + dimension_height]                      //Load box.dimension.height into w5
            ldr w6, [x9, box_area]                                              //Load box.area into w6
            bl printf

            mov x0, 0                                                           //Reset x0 to 0
ret4:       ldp x29, x30, [sp], 16                                              //Deallocate subroutine
            ret                                                                 //Returns control to calling code

equal:      stp x29, x30, [sp, -16]!                                            //ALocate 16 bytes of memory for equal
            mov fp, sp                                                          //Resets SP to FP

            mov x9, x0                                                          //x0 = base of struct box 1
            mov x10, x1                                                         //x1 = base of struct box 2

            ldr x11, [x9, box_origin + point_x]                                 //Loads box1_origin_x into x11
            ldr x12, [x10, box_origin + point_x]                                //Loads box2_origin_x into x12
            cmp x11, x12                                                        //Compares 2 boxes
            b.ne false_eq                                                       //If not equal branch to false_eq

            ldr x11, [x9, box_origin + point_y]                                 //Loads box1_origin_y into x11
            ldr x12, [x10, box_origin + point_y]                                //Loads box2_origin_y into x12
            cmp x11, x12                                                        //Compares 2 boxes
            b.ne false_eq                                                       //If not equal branch to false_eq

            ldr x11, [x9, box_dimension + dimension_width]                      //Loads box1_width into x11
            ldr x12, [x10, box_dimension + dimension_width]                     //Loads box2_width into x12
            cmp x11, x12                                                        //Compares 2 boxes
            b.ne false_eq                                                       //If not equal branch to false_eq

            ldr x11, [x9, box_dimension + dimension_height]                     //Loads box1_height into x11
            ldr x12, [x10, box_dimension + dimension_height]                    //Loads box2_height into x12
            cmp x11, x12                                                        //Compares 2 boxes
            b.ne false_eq                                                       //If not equal branch to false_eq

            mov x0, TRUE                                                        //If nested ifs got to here then set x0 to true since all variables are equal
            b ret5                                                              //Branch to end of function

false_eq:   mov x0, FALSE                                                       //Sets x0 to false

ret5:       ldp x29, x30, [sp], 16                                              //Deallocate subroutine
            ret                                                                 //Returns control to calling code

main:       stp x29, x30, [sp, alloc]!                                          //Allocates memory for main
            mov fp, sp                                                          //Sets SP to FP

            add x19, fp, box1_s                                                 //x19 = base address of box 1
            add x20, fp, box2_s                                                 //x20 = base address of box 2

            mov x0, x19                                                         //Set x0 to x19
            bl newbox                                                           //Calls newbox function

            mov x0, x20                                                         //Set x0 to x20
            bl newbox                                                           //Calls newbox function

            adrp x0, print4                                                     //Loads x0 with print4 format
            add w0, w0, :lo12:print4                                            //Loads low 12 bits of print4 into w0
            bl printf                                                           //Calls printf function

printb4:    mov x0, x19                                                         //Sets x0 to x19
            adrp x1, print2                                                     //Loads x1 with print2 format
            add w1, w1, :lo12:print2                                            //Loads low 12 bits of print2 into w1
            bl printbox                                                         //Calls printbox function

            mov x0, x20                                                         //Sets x0 to x20
            adrp x1, print3                                                     //Loads x1 with print3 format
            add w1, w1, :lo12:print3                                            //Loads low 12 bits of print3 into w1
            bl printbox                                                         //Calls printbox function

            mov x0, x19                                                         //Sets x0 to x19
            mov x1, x20                                                         //Sets x1 to x20
            bl equal                                                            //Calls equal function
            mov x21, x0                                                         //Moves result into x21

            cmp x21, xzr                                                        //Compares result to zero
            b.eq next                                                           //Branch to next if equal

            mov x0, x19                                                         //Sets x0 to x19
            mov w1, -5                                                          //Sets w1 to -5 for deltaX
            mov w2, 7                                                           //Sets w2 to 7 for deltaY
            bl move                                                             //Calls move function

            mov x0, x20                                                         //Sets x0 to x20
            mov w1, 3                                                           //Sets w1 to 3 for factor
            bl expand                                                           //Calls expand function

next:       adrp x0, print5                                                     //Loads x0 with print5 format
            add w0, w0, :lo12:print5                                            //Loads low 12 bits of print5 into w0
            bl printf                                                           //Calls printf function

print_aft:  mov x0, x19                                                         //Sets x0 to x19
            adrp x1, print2                                                     //Loads x1 with print2 format
            add w1, w1, :lo12:print2                                            //Loads low 12 bits of print2 into w1
            bl printbox                                                         //Calls printbox function

            mov x0, x20                                                         //Sets x0 to x20
            adrp x1, print3                                                     //Loads x1 with print3 format
            add w1, w1, :lo12:print3                                            //Loads low 12 bits of print3 into w1
            bl printbox                                                         //Calls printbox function

done:       mov w0, 0                                                           //Reset w0 to 0
            ldp fp, lr, [sp], dealloc                                           //Deallocates stack memory
            ret                                                                 //Returns to caller
