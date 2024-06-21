.data
  welcome: .asciiz "\nWelcome in a program to calculate a polynomial for you\n"
  degree: .asciiz "\nPlease input the degree of a polynomial you want to calculate: "
  wrong_number_prompt: .asciiz "\nThe number of bytes to allocate must be non-negative!"
  variable_prompt: .asciiz "\nPlease enter the value of the variable: "

# File: polynomials.asm
# Purpose: Calculate a polynomial of arbitrary degree
.text
main:
  li $v0, 4
  la $a0, welcome
  syscall

  li $v0, 4
  la $a0, degree
  syscall

  li $v0, 5
  syscall
  move $s0, $v0 # store the degree of a polynomial in s1

  bltz $s0, wrong_number
  
  move $a0, $s0
  mul $a0, $a0, 4 # store the amount of bytes, not coefficient
  li $v0, 9
  syscall
  move $s1, $v0
  
  move $a0, $s0 
  move $a1, $s1 # pass the address of 1st addres of allocated mem to the func
  jal InputLoop

  move $a0, $s0 
  move $a1, $s1 
  jal PrintArray

  li $v0, 4
  la $a0, variable_prompt
  syscall

  li $v0, 5
  syscall
  move $s2, $v0

  move $a0, $s0
  move $a1, $s1
  move $a2, $s2
  jal EvalAndOutputPolynomial

  li $v0, 10
  syscall

  wrong_number: # hotline miami 2 reference? Perchance.
  li $v0, 4
  la $a0, wrong_number_prompt 
  syscall

  li $v0, 11
  la $a0, 10
  syscall
  li $v0, 10
  syscall

.data
  coefficient_p1: .asciiz "\nInput the coefficient at "
  coefficient_p2: .asciiz "th power: "

# subprogram: InputLoop
# purpose: fill an array with integers read from the user
# input: a0 - size of an array, a1 - pointer to the array
# output: none
# side effects: none
.text
InputLoop:
  addi $sp, $sp, -12
  sw $ra, 8($sp)
  sw $a0, 4($sp)
  sw $a1, 0($sp)

  move $t0, $a0 # size of an array
  move $t1, $a1 # address of first elem of array
  
  input_loop:
    bltz $t0, input_loop_return
    li $v0, 4
    la $a0, coefficient_p1
    syscall

    li $v0, 1 
    move $a0, $t0
    syscall

    li $v0, 4
    la $a0, coefficient_p2
    syscall

    li $v0, 5
    syscall
    sw $v0, 0($t1)
    
    addi $t0, $t0, -1
    addi $t1, $t1, 4
    j input_loop

  input_loop_return:
    lw $ra, 8($sp)
    lw $a0, 4($sp)
    lw $a1, 0($sp)
    addi $sp, $sp, 12
    jr $ra

.data
  arr_begin: .asciiz "\n["
  comma: .asciiz ", "
  arr_end: .asciiz "]\n"

# subprogram: PrintArray
# purpose: print an array
# input: a0 - size of an array, a1 - pointer to the array
# output: none
# side effects: an easily readable array is printed to the console
.text:
PrintArray:
  # a0 - size of an array
  # a1 - pointer to an array
  addi $sp, $sp, -12
  sw $ra, 8($sp)
  sw $a0, 4($sp)
  sw $a1, 0($sp)

  move $t0, $a0 # array size
  move $t1, $a1 # pointer to array
  li $t2, 0 # index counter
  move $t3, $a0 # used to check if separator is needed
  addi $t3, $t3, -1

  li $v0, 4
  la $a0, arr_begin
  syscall

  print_array_loop:
    bgt $t2, $t0, print_array_return
    # print the  current element 
    li $v0, 1
    lw $a0, 0($t1)
    syscall
    # a separator
    bgt $t2, $t3, no_comma
    li $v0, 4
    la $a0, comma
    syscall
    
    no_comma:
    addi $t2, $t2, 1
    addi $t1, $t1, 4
    j print_array_loop

  print_array_return: 
    li $v0, 4
    la $a0, arr_end
    syscall
    # epilogue
    lw $ra, 8($sp)
    lw $a0, 4($sp)
    lw $a1, 0($sp)
    addi $sp, $sp, 12
    jr $ra

.data
  exp: .asciiz "^"
  result_1: .asciiz "\nThe value of polynomial "
  result_2: .asciiz " for x = "
  result_3: .asciiz " is "
  result_end: .asciiz "\n"
  plus_ch: .asciiz " + "
  minus_ch: .asciiz " - "
  x: .asciiz "x"

# subprogram: EvalAndOutputPolynomial
# purpose: Evaluate the polynomial and print it to console in pretty format
# input: a0 - array size, a1 - pointer to an array of coefficients, a2 - variable
# output: none
# side_effects: prints to a console 
.text
EvalAndOutputPolynomial:
  # prologue
  addi $sp, $sp, -16
  sw $ra, 12($sp)
  sw $a0, 8($sp)
  sw $a1, 4($sp)
  sw $a2, 0($sp)

  move $t0, $a0 # size of an array

  move $t1, $a1 # pointer to array
  move $t2, $a2 # variable x

  li $v0, 4
  la $a0, result_1
  syscall
  
  eval_polynomial_loop:
    blez $t0, eval_polynomial_end

    li $v0, 1
    lw $t4, 0($t1)
    beq $t4, $zero, next_num
    bgtz $t4, print_factor
    sub $t4, $zero, $t4

    print_factor:
    li $v0, 1
    move $a0, $t4
    syscall

    li $v0, 4
    la $a0, x
    syscall
    
    beq $t0, 1, eval_sign
    li $v0, 4
    la $a0, exp
    syscall

    li $v0, 1 
    move $a0, $t0
    syscall

    next_num:
    lw $t4, 4($t1)
    beq $t4, $zero, after_sign
    
    eval_sign:
    bgtz $t4, print_plus
    
    print_minus:
    li $v0, 4
    la $a0, minus_ch
    syscall
    j after_sign

    print_plus:
    li $v0, 4
    la $a0, plus_ch
    syscall

    after_sign:
    addi $t1, $t1, 4
    addi $t0, $t0, -1 
    j eval_polynomial_loop

  eval_polynomial_end:
    li $v0, 1 
    lw $a0, 0($t1)
    beq $a0, $zero, ep_end
    syscall

    ep_end:
    li $v0, 4
    la $a0, result_2
    syscall

    li $v0, 1
    move $a0, $t2
    syscall

    li $v0, 4
    la $a0, result_3
    syscall
    
    lw $a0, 8($sp)
    lw $a1, 4($sp)
    lw $a2, 0($sp)
    jal EvalPolynomial
    move $a0, $v0
    li $v0, 1 
    syscall

    # epilogue
    lw $ra, 12($sp)
    lw $a0, 8($sp)
    lw $a1, 4($sp)
    lw $a2, 0($sp)
    addi $sp, $sp, 16
    jr $ra 

# subprogram: EvalPolynomial
# purpose: calculate the polynomial
# input: a0 - array size, a1 - pointer to an array of coefficients, a2 - variable
# output: value of the polynomial for the specific value of a variable
# side effects: none
.text
EvalPolynomial:
  addi $sp, $sp, -16  
  sw $ra, 12($sp)
  sw $a0, 8($sp)
  sw $a1, 4($sp)
  sw $a2, 0($sp)

  move $t0, $a0 # size of the array of the coefficients
  move $t1, $a1 # pointer to the array
  move $t2, $a2 # variable
  li $t5, 0 # value of polynomial

  outer_mul_loop:
    bltz $t0, eval_polynomial_epilogue

    li $t3, 0
    lw $t4, 0($t1)
    beq $t4, $zero, end_of_outer_loop
    inner_mul_loop:
      bge $t3, $t0, end_of_outer_loop
      mul $t4, $t4, $t2

      addi $t3, $t3, 1
      j inner_mul_loop

    end_of_outer_loop:
      add $t5, $t5, $t4
      addi $t0, $t0, -1
      addi $t1, $t1, 4
      j outer_mul_loop

  eval_polynomial_epilogue:
    # epilogue
  lw $ra, 12($sp)
  lw $a0, 8($sp)
  lw $a1, 4($sp)
  lw $a2, 0($sp)
  addi $sp, $sp, 16
  move $v0, $t5
  jr $ra 
