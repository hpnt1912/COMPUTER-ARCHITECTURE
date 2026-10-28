.data
# ---------- Mang diem (word, 4 byte/phan tu) ----------
scores:    .word 8, 5, 10, 0, 4, 7, 9, 4, 8, 0, 6, 5   # T1: mang ca nhan, n = 12 (d = 2)
n_scores:  .word 12
t2:        .word 10                                     # T2: {10}, n = 1
t3:        .word 4, 4, 4, 4, 4                          # T3: {4,4,4,4,4}, n = 5

# ---------- Mang dem nhom (word) ----------
hist:      .word 0, 0, 0, 0                             # hist[0..3], khoi tao bang 0

# ---------- Bang tra nhom (byte, 1 byte/phan tu) ----------
#                0  1  2  3  4  5  6  7  8  9  10      <- diem s
grade_tab: .byte 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3

# ---------- Chuoi in ra (ASCII khong dau) ----------
str_min:   .asciiz "min="
str_max:   .asciiz " max="
str_g0:    .asciiz "g0="
str_g1:    .asciiz " g1="
str_g2:    .asciiz " g2="
str_g3:    .asciiz " g3="

.text
main:
    #goi stats
    la $a0, scores
    lw $a1, n_scores
    jal stats
    move $s0, $v0
    move $s1, $v1
    
    #goi histogram
    la $a0, scores
    lw $a1, n_scores
    la $a2, grade_tab
    la $a3, hist
    jal histogram
    
    #in ra min max
    li $v0, 4
    la $a0, str_min
    syscall
    li $v0, 1
    move $a0, $s0
    syscall
    
    li $v0, 4
    la $a0, str_max
    syscall
    li $v0, 1
    move $a0, $s1
    syscall
    
    #xuong dong
    li $v0, 11
    li $a0, 10
    syscall
    
    #in ra g0, g1, g2, g3
    la $s2, hist
    
    li $v0, 4
    la $a0, str_g0
    syscall
    li $v0, 1
    lw $a0, 0($s2)
    syscall
    
    li $v0, 4
    la $a0, str_g1
    syscall
    li $v0, 1
    lw $a0, 4($s2)
    syscall
    
    li $v0, 4
    la $a0, str_g2
    syscall
    li $v0, 1
    lw $a0, 8($s2)
    syscall
    
    li $v0, 4
    la $a0, str_g3
    syscall
    li $v0, 1
    lw $a0, 12($s2)
    syscall
    
    li $v0, 10
    syscall
    
    
    stats:
         lw $t1, 0($a0) #$t1 = scores[0], Min
         lw $t2, 0($a0) #$t2 = scores[0], Max
         
         li $t7, 1 #i = 1
         
         loop:
             beq $t7, $a1, end_loop
             
             sll $t0, $t7, 2
             add $t0, $t0, $a0
             lw $t3, 0($t0) #$t3 = scores[i]
             
             slt $t4, $t3, $t1
             beq $t4, $zero, find_max
             move $t1, $t3
             
             find_max:
             slt $t5, $t2, $t3
             beq $t5, $zero, incre_i
             move $t2, $t3
             
             incre_i:
             addi $t7, $t7, 1
             j loop
             
         end_loop:
             move $v0, $t1 #$v0 = min
             move $v1, $t2 #$v1 = max
             jr $ra
     
     
     
     histogram:
           li $t0, 0 # i = 0
           
           hist_loop:
               beq $t0, $a1, hist_end
               
               sll $t1, $t0, 2
               add $t1, $t1, $a0
               lw $t2, 0($t1) #t2 = scores[i]
               add $t3, $a2, $t2
               lbu $t4, 0($t3) #t4 = grade_tab[t2]
               sll $t5, $t4, 2
               add $t5, $t5, $a3
               lw $t6, 0($t5)
               addi $t6, $t6, 1 #his[t4] + 1
               sw $t6, 0($t5) #his++
               
               addi $t0, $t0, 1
               j hist_loop
           hist_end:
                jr $ra
               
               
           
           









