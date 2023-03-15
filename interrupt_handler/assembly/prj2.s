! This program executes pow as a test program using the LC 2200 calling convention
! Check your registers ($v0) and memory to see if it is consistent with this program

        ! vector table
vector0:
        .fill 0x00000000                        ! device ID 0
        .fill 0x00000000                        ! device ID 1
        .fill 0x00000000                        ! ...
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000                        ! device ID 7
        ! end vector table

main:	lea $sp, initsp                         ! initialize the stack pointer
        lw $sp, 0($sp)                          ! finish initialization

                                                ! TODO FIX ME: Install timer interrupt handler into vector table        
        lea $a0, timer_handler 
        sw $a0, 0($zero)                        ! 0x0 -> timer handler address

                                                ! TODO FIX ME: Install water level sensor interrupt handler into vector table
        lea $a0, water_level_handler
        sw $a0, 1($zero)
        

        ei                                      ! Enable interrupts

        lea $a0, BASE                           ! load base for pow
        lw $a0, 0($a0)
        lea $a1, EXP                            ! load power for pow
        lw $a1, 0($a1)
        lea $at, POW                            ! load address of pow
        jalr $ra, $at                           ! run pow
        lea $a0, ANS                            ! load base for pow
        sw $v0, 0($a0)

        halt                                    ! stop the program here
        addi $v0, $zero, -1                     ! load a bad value on failure to halt

BASE:   .fill 2
EXP:    .fill 8
ANS:	.fill 0                                 ! should come out to 256 (BASE^EXP)

POW:    addi $sp, $sp, -1                       ! allocate space for old frame pointer
        sw $fp, 0($sp)

        addi $fp, $sp, 0                        ! set new frame pinter

        beq $a0, $zero, RET0                    ! if the base is 0, return 0
        beq $a1, $zero, RET1                    ! if the exponent is 0, return 1

        addi $a1, $a1, -1                       ! decrement the power

        lea $at, POW                            ! load the address of POW
        addi $sp, $sp, -2                       ! push 2 slots onto the stack
        sw $ra, -1($fp)                         ! save RA to stack
        sw $a0, -2($fp)                         ! save arg 0 to stack
        jalr $ra, $at                           ! recursively call POW
        add $a1, $v0, $zero                     ! store return value in arg 1
        lw $a0, -2($fp)                         ! load the base into arg 0
        lea $at, MULT                           ! load the address of MULT
        jalr $ra, $at                           ! multiply arg 0 (base) and arg 1 (running product)
        lw $ra, -1($fp)                         ! load RA from the stack
        addi $sp, $sp, 2

        beq $zero, $zero, FIN                   ! unconditional branch to FIN

RET1:   addi $v0, $zero, 1                      ! return a value of 1
        beq $zero, $zero, FIN                   ! unconditional branch to FIN

RET0:   add $v0, $zero, $zero                   ! return a value of 0

FIN:	lw $fp, 0($fp)                          ! restore old frame pointer
        addi $sp, $sp, 1                        ! pop off the stack
        jalr $zero, $ra

MULT:   add $v0, $zero, $zero                   ! return value = 0
        addi $t0, $zero, 0                      ! sentinel = 0
AGAIN:  add $v0, $v0, $a0                       ! return value += argument0
        inc $t0	                         ! increment sentinel
        blt $t0, $a1, AGAIN                     ! while sentinel < argument1

        jalr $zero, $ra                         ! return from mult

timer_handler:
        addi $sp, $sp, -1                       ! push k0 
        sw   $k0, 0($sp)

        ei 

        addi $sp, $sp, -1                       ! push s0 
        sw   $s0, 0($sp)

        addi $sp, $sp, -1                       ! push s1 
        sw   $s1, 0($sp)

        lea  $s0, ticks
        lw   $s0, 0($s0)
        lw   $s1, 0($s0)
        inc  $s1
        sw   $s1, 0($s0)

        lw   $s1, 0($sp)
        addi $sp, $sp, 1                       ! pop s1

        lw   $s0, 0($sp)
        addi $sp, $sp, 1                       ! pop s0

        di 
        lw   $k0, 0($sp)
        addi $sp, $sp, 1                       ! pop k0

        reti 


water_level_handler:
        addi $sp, $sp, -1                       
        sw $k0, 0($sp)                          
        ei                                     

       
        addi $sp, $sp, -1
        sw   $a0, 0($sp)
        
        addi $sp, $sp, -1
        sw   $a1, 0($sp)
        
        addi $sp, $sp, -1
        sw   $a2, 0($sp)
        
        addi $sp, $sp, -1
        sw   $t0, 0($sp)
        
        addi $sp, $sp, -1
        sw   $t1, 0($sp)
        
        addi $sp, $sp, -1
        sw   $t2, 0($sp)
        
        addi $sp, $sp, -1
        sw   $s0, 0($sp)
        
        addi $sp, $sp, -1
        sw   $s1, 0($sp)
        
        addi $sp, $sp, -1
        sw   $s2, 0($sp)
        
        addi $sp, $sp, -1
        sw   $fp, 0($sp)
        
        addi $sp, $sp, -1
        sw   $ra, 0($sp)
        
        addi $sp, $sp, -1
        sw   $at, 0($sp)

        addi $sp, $sp, -1
        sw   $v0, 0($sp)
        
        lea $s0, total_water
        lw  $s1, 0($s0)
        lw  $s2, 0($s1)
        in  $t0, 1
        add $s2, $s2, $t0
        sw  $s2, 0($s1)

        lw   $v0, 0($sp)
        addi $sp, $sp, 1

        lw   $at, 0($sp)
        addi $sp, $sp, 1

        lw   $ra, 0($sp)
        addi $sp, $sp, 1

        lw   $fp, 0($sp)
        addi $sp, $sp, 1

        lw   $s2, 0($sp)
        addi $sp, $sp, 1

        lw   $s1, 0($sp)
        addi $sp, $sp, 1

        lw   $s0, 0($sp)
        addi $sp, $sp, 1

        lw   $t2, 0($sp)
        addi $sp, $sp, 1

        lw   $t1, 0($sp)
        addi $sp, $sp, 1

        lw   $t0, 0($sp)
        addi $sp, $sp, 1

        lw   $a2, 0($sp)
        addi $sp, $sp, 1

        lw   $a1, 0($sp)
        addi $sp, $sp, 1

        lw   $a0, 0($sp)
        addi $sp, $sp, 1

        

        di                             
        lw   $k0, 0($sp)                
        addi $sp, $sp, 1
        reti


ticks: .fill 0xFFFF
total_water: .fill 0xFFF0

initsp: .fill 0xA000