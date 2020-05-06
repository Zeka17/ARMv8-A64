/*
    CPSC 355-02 - Computing Machinery 1

    Assignment 5 part B

    Alexandar Zecevic
    30045860

    This ARMv8 A64 program utilizes external array pointers and command line
    arguments inorder to take 2 integer inputs and print out the day, month
    and season that they correspond to and print them to standard output i.e
    the screen
*/
        define(argc_r, w19)                                                     //Number of Arguments
        define(argv_r, x20)                                                     //Arguments array

        define(day_r, w21)                                                      //Input for day
        define(month_r, w22)                                                    //Input for month
        define(season_r, w23)                                                   //Index for season array
        define(suffix_r, w24)                                                   //Index for suffix array

        define(month_base_r, x25)                                               //Base of the month array
        define(season_base_r, x26)                                              //Base of the season array
        define(suffix_base_r, x27)                                              //Base of the suffix array

                                                                                //Bellow 12 lines are for month formats for output
jan:    .string "January"                                                       
feb:    .string "February"
mar:    .string "March"
apr:    .string "April"
may:    .string "May"
jun:    .string "June"
jul:    .string "July"
aug:    .string "August"
sep:    .string "September"
oct:    .string "October"
nov:    .string "November"
dec:    .string "December"

                                                                                //Bellow 4 lines are for season formats for output
win:    .string "Winter"
spr:    .string "Spring"
sum:    .string "Summer"
fal:    .string "Fall"

                                                                                //Bellow 4 lines are for suffix formats for output
sf1:    .string "th"
sf2:    .string "st"
sf3:    .string "nd"
sf4:    .string "rd"

useerr: .string "usage a5b mm dd\n"                                             //Improper amount of command line arguments error format
interr: .string "Invalid day or month given\n"                                  //Invalid day or month error format
result: .string "%s %d%s is %s\n"                                               //Result ouput message

        .data                                                                   //Place contents in data section of memory
        .balign 8                                                               //Allign all instructions by 8 bits

mon_m:  .dword jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec       //Create month array
ssn_m:  .dword win, spr, sum, fal                                               //Create season array
sfx_m:  .dword sf1, sf2, sf3, sf4                                               //Create suffix array

        .text                                                                   //Return to text section of memory
        .balign 4                                                               //Allign all instructions by 4 bits
        .global main                                                            //Make main visible

main:   stp x29, x30, [sp, -16]!                                                //Allocate 16 bytes of memory for main
        mov x29, sp                                                             //Update FP to SP

        mov argc_r, w0                                                          //Move w0 to argc_r
        mov argv_r, x1                                                          //Move x1 tp argv_r

        cmp argc_r, 3                                                           //Compares argc to 3
        b.eq next1                                                              //If equal branch to next1
        adrp x0, useerr                                                         //Move usage error into x0
        add x0, x0, :lo12:useerr                                                //Add low 12 bits to x0
        bl printf                                                               //Call printf function
        b done                                                                  //Branch to done

next1:  mov suffix_r, 1                                                         //Moves 1 into the suffix register
        ldr x0, [argv_r, suffix_r, SXTW 3]                                      //Get second element of argv and place in x0
        bl atoi                                                                 //Call atoi function
        mov month_r, w0                                                         //Put returned atoi value into month_r
        mov suffix_r, 2                                                         //Move 2 into the suffix register
        ldr x0, [argv_r, suffix_r, SXTW 3]                                      //Get third element of argv and place in x0
        bl atoi                                                                 //Call atoi function
        mov day_r, w0                                                           //Put returned atoi value into day_r 

        cmp month_r, 0                                                          //Compare value in month register to 0
        b.le error1                                                             //If less then or equal branch to error label
        cmp month_r, 12                                                         //Compare value in month register to 0
        b.gt error1                                                             //If greater then branch to error label
        cmp day_r, 0                                                            //Compare value in day register to 0
        b.le error1                                                             //If less then or equal branch to error label
        cmp day_r, 31                                                           //Compare value in day register to 31
        b.gt error1                                                             //If greater then branch to error label
        b next2                                                                 //If no errors branch to next2

error1: adrp x0, interr                                                         //Move day or month error into x0
        add x0, x0, :lo12:interr                                                //Add low 12 bits to x0
        bl printf                                                               //Call printf function
        b done                                                                  //Branch to end of program

next2:  sub month_r, month_r, 1                                                 //Subtract 1 from month for zero-based indexing
        
        cmp month_r, 1                                                          //Check if month_r is February
        b.ne next3                                                              //If not then continue
        cmp day_r, 28                                                           //Compare value of day register to 28
        b.gt error2                                                             //If greater then branch to error2 label

next3:  cmp month_r, 3                                                          //Check if month_r is April
        b.eq check                                                              //If it is branch to check
        cmp month_r, 5                                                          //Check if month_r is June
        b.eq check
        cmp month_r, 8                                                          //Check if month_r is September
        b.eq check
        cmp month_r, 10                                                         //Check if month_r is November
        b.eq check
        b next4                                                                 //If no errors branch to next5

check:  cmp day_r, 31                                                           //Compare value in day_r to 31
        b.ne next4                                                              //If not equal then branch to next5

error2: adrp x0, interr                                                         //Move day or month error into x0
        add x0, x0, :lo12:interr                                                //Add low 12 bits to x0
        bl printf                                                               //Call printf function
        b done                                                                  //Branch to end of program

next4:  cmp month_r, 1                                                          //Check if month_r is February
        b.gt sprssn                                                             //If greater then branch to sprssn label
        mov season_r, 0                                                         //Set season_r to winter
        b next5                                                                 //Branch to next5 label
        
sprssn: cmp month_r, 3                                                          //Check if month_r is April
        b.lt verequ                                                             //If less then branch to verequ label
        cmp month_r, 4                                                          //Check if month_r is May
        b.gt sumssn                                                             //If greater then branch to sumssn label
        mov season_r, 1                                                         //Set season_r to spring
        b next5                                                                 //Branch to next5 label

sumssn: cmp month_r, 6                                                          //Check if month_r is July
        b.lt sumsol                                                             //If less then branch to sumsol label
        cmp month_r, 7                                                          //Check if month_r is August
        b.gt falssn                                                             //If greater then branch to falssn label
        mov season_r, 2                                                         //Set season_r to summer
        b next5                                                                 //Branch to next5 label

falssn: cmp month_r, 9                                                          //Check if month_r is October
        b.lt autequ                                                             //If less then branch to autequ label
        cmp month_r, 10                                                         //Check if month_r is November
        b.gt winsol                                                             //If greater then branch to winsol label
        mov season_r, 3                                                         //Set season_r to fall
        b next5                                                                 //Branch to next5 label

verequ: mov season_r, 0                                                         //Set season_r to winter
        cmp day_r, 20                                                           //Compare value in day_r to 20
        b.le next5                                                              //If less then or equal branch to next5 label
        mov season_r, 1                                                         //Set season_r to spring
        b next5                                                                 //Branch to next5 label

sumsol: mov season_r, 1                                                         //Set season_r to spring
        cmp day_r, 20                                                           //Compare value in day_r to 20
        b.le next5                                                              //If less then or equal branch to next5 label
        mov season_r, 2                                                         //Set season_r to summer
        b next5                                                                 //Branch to next5 label

autequ: mov season_r, 2                                                         //Set season_r to summer
        cmp day_r, 20                                                           //Compare value in day_r to 20
        b.le next5                                                              //If less then or equal branch to next5 label
        mov season_r, 3                                                         //Set season_r to fall
        b next5                                                                 //Branch to next5 label

winsol: mov season_r, 3                                                         //Set season_r to fall
        cmp day_r, 20                                                           //Compare value in day_r to 20
        b.le next5                                                              //If less then or equal branch to next5 label
        mov season_r, 0                                                         //Set season_r to winter
        b next5                                                                 //Branch to next5 label

next5:  cmp day_r, 3                                                            //Check if the day is 3
        b.eq setsf4                                                             //If equal then branch to setsf4 label
        cmp day_r, 23                                                           //Check if the day is 23
        b.eq setsf4                                                             //If equal then branch to setsf4 label
        
        cmp day_r, 2                                                            //Check if the day is 2
        b.eq setsf3                                                             //If equal then branch to setsf3 label
        cmp day_r, 22                                                           //Check if the day is 22
        b.eq setsf3                                                             //If equal then branch to setsf3 label
        
        cmp day_r, 1                                                            //Check if the day is 1
        b.eq setsf2                                                             //If equal then branch to setsf2 label
        cmp day_r, 21                                                           //Check if the day is 21
        b.eq setsf2                                                             //If equal then branch to setsf2 label
        cmp day_r, 31                                                           //Check if the day is 31
        b.eq setsf2                                                             //If equal then branch to setsf2 label
        
        mov suffix_r, 0                                                         //If program gets to this point then set suffix to "th"
        b output                                                                //Branch to output 

setsf2: mov suffix_r, 1                                                         //Set the suffix to "st"
        b output                                                                //Branch to output

setsf3: mov suffix_r, 2                                                         //Set the suffix to "nd"
        b output                                                                //Branch to output

setsf4: mov suffix_r, 3                                                         //Set the suffix to "rd"

output: adrp month_base_r, mon_m                                                //Put month base into register
        add month_base_r, month_base_r, :lo12:mon_m                             //Add low 12 bits to month_base_r

        adrp season_base_r, ssn_m                                               //Put season base into register
        add season_base_r, season_base_r, :lo12:ssn_m                           //Add low 12 bits to season_base_r

        adrp suffix_base_r, sfx_m                                               //Put suffix base into register
        add suffix_base_r, suffix_base_r, :lo12:sfx_m                           //Add low 12 bits into suffix_base_r

        adrp x0, result                                                         //Add result format to x0
        add x0, x0, :lo12:result                                                //Add low 12 bits to x0
        ldr x1, [month_base_r, month_r, SXTW 3]                                 //Load month into x1
        mov w2, day_r                                                           //Move day into w2
        ldr x3, [suffix_base_r, suffix_r, SXTW 3]                               //Load suffix into x3
        ldr x4, [season_base_r, season_r, SXTW 3]                               //Load season into x4
        bl printf                                                               //Call printf function

done:   mov w0, 0                                                               //Set return to 0
        ldp x29, x30, [sp], 16                                                  //Deallocate memory
        ret                                                                     //Return to calling code
