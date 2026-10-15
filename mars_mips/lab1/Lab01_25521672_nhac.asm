.data
# du lieu bai hat
SoNot: .word 15
CaoDo: .word 64 64 65 67 67 65 64 62 60 60 62 64 64 62 62
DoDai: .word 2 2 2 2 2 2 2 2 2 2 2 2 3 1 4

#tham so ca nhan
thamso_a: .word 2 # a = 2
thamso_b: .word 7 # b = 7
volume: .word 100
nhacCu: .word 100

#in ra man hinh
p1: .asciiz "Tong du kien (ms): "
p2: .asciiz "Thoi gian do duoc (ms): "
cach: .asciiz " "
xuong_dong: .asciiz "\n"
ms: .asciiz " ms"

.text
.globl main

main:
    #tinh 1 don vi nhip 150 + 10*b
    lw $t0, thamso_b
    li $t1, 10
    mul $t0, $t0, $t1
    addi $s0, $t0, 150 #s0 la 1 don vi nhip
    
    # do thoi diem bat dau
    li $v0, 30
    syscall
    move $s1, $a0 #s1 la thoi diem bat dau
    
    #khoi tao vong lap
    lw $s2, SoNot #s2 = tong so not = 15
    li $s3, 0 #s3 = i
    li $s4, 0 #s4 = tong thoi luong du kien
    
    loop:
        #kiem tra neu i = 15 thi ket thuc vong lap
        beq $s3, $s2, end_loop
    
        #lay cao do thuc = cao do + a
        la $t0, CaoDo
        sll $t1, $s3, 2 #offset = i * 4
        add $t2, $t1, $t0 
        lw $t2, 0($t2) #t2 = CaoDo[i]
        lw $t3, thamso_a
        add $t2, $t2, $t3 #t2 = CaoDo Thuc [i]
        
        #lay thoi luong thuc = DoDai * $s0
        la $t0, DoDai
        sll $t1, $s3, 2
        add $t4, $t0, $t1
        lw $t4, 0($t4)
        mul $t4, $t4, $s0 # $t4 = thoi luong
        
        #tong thoi luong
        add $s4, $s4, $t4
        
        #in ra cao do
        li $v0, 1
        move $a0, $t2
        syscall
        
        li $v0, 4
        la $a0, cach
        syscall
        
        #in ra thoi luong
        li $v0, 1
        move $a0, $t4
        syscall
        
        #xuong dong
        li $v0, 4
        la $a0, xuong_dong
        syscall
        
        #phat not = syscall 
        li $v0, 31
        move $a0, $t2 #cao do
        move $a1, $t4 #thoi luong
        lw $a2, nhacCu
        lw $a3, volume
        syscall
        
        li $v0, 32
        move $a0, $t4
        syscall
        
        #tang bien dem i
        addi $s3, $s3, 1
        
        #loop
        j loop
        
    end_loop:
        # do thoi diem ket thuc
        li $v0, 30
        syscall
        sub $s5, $a0, $s1 #thoi gian do duoc = thoi diem ket thuc - thoi diem bat dau
        
        #in tong du kien va thoi gian do duoc
        li $v0, 4
        la $a0, p1
        syscall
        
        li $v0, 1
        move $a0, $s4 #in ra tong thoi luong du kien
        syscall
        
        li $v0, 4
        la $a0, xuong_dong
        syscall
        
        #thoi gian do duoc
        li $v0, 4
        la $a0, p2
        syscall
        
        li $v0, 1
        move $a0, $s5 #in ra thoi gian do duoc
        syscall
        
   end_program:
       li $v0, 10
       syscall


















