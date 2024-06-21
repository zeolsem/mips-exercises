.data
  welcome: .asciiz "\nWelcome in a program to calculate a polynomial for you"
  degree: .asciiz "\nPlease input the degree of a polynomial you want to calculate: "

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

  li $v0, 10
  syscall

.data
  coefficient_p1: .asciiz "\nPodaj wspolczynnik przy "
  coefficient_p2: .asciiz " potedze: "

.text
InputLoop:
  addi $sp, $sp, -12
  sw $ra, 8($sp)
  sw $a0, 4($sp)
  sw $a1, 0($sp)

  move $t0, $a0 # size of an array
  move $t1, $a1 # address of first elem of array
  
  input_loop:
    blez $t0, input_loop_return
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
  arr_begin: .asciiz "\nArray:\n"
  elem: .asciiz "\nElement "
  colon: .asciiz ":"

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

  li $v0, 4
  la $a0, arr_begin
  syscall

  print_array_loop:
    bge $t2, $t0, print_array_return
    
    li $v0, 4
    la $a0, elem
    syscall

    li $v0, 1
    move $a0, $t2
    syscall

    li $v0, 4
    la $a0, colon
    syscall
    
    li $v0, 1
    lw $a0, 0($t1)
    syscall

    addi $t2, $t2, 1
    addi $t1, $t1, 4
    j print_array_loop

  print_array_return: 
    lw $ra, 8($sp)
    lw $a0, 4($sp)
    lw $a1, 0($sp)
    addi $sp, $sp, 12
    jr $ra
