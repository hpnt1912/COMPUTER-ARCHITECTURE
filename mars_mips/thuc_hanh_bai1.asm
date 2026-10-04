.data
    prompt1:      .asciiz "Nhap so thu nhat: "
    prompt2:      .asciiz "Nhap so thu hai: "
    msg_max:      .asciiz "a) So lon hon la: "
    msg_sum:      .asciiz "\nb) Tong = "      
    msg_diff:     .asciiz ", Hieu = "         
    msg_prod:     .asciiz ", Tich = "        
    msg_quot:     .asciiz ", Thuong = "       
    msg_div_zero: .asciiz ", Thuong: Khong the chia cho 0!"

.text
.globl main

main:
    # ----------------------------------------
    # 1. Nhap hai so nguyen tu ban phim
    # ----------------------------------------
    # In thong bao nhap so thu nhat
    li $v0, 4
    la $a0, prompt1
    syscall

    # Doc so thu nhat (luu vao $t0)
    li $v0, 5
    syscall
    move $t0, $v0

    # In thong bao nhap so thu hai
    li $v0, 4
    la $a0, prompt2
    syscall

    # Doc so thu hai (luu vao $t1)
    li $v0, 5
    syscall
    move $t1, $v0

    # ----------------------------------------
    # a) Tim va in so lon hon
    # ----------------------------------------
    li $v0, 4
    la $a0, msg_max
    syscall

    # So sanh $t0 va $t1: neu $t0 >= $t1 thi nhay toi a_is_greater
    bge $t0, $t1, a_is_greater
    move $a0, $t1                # $t1 lon hon
    j print_max

a_is_greater:
    move $a0, $t0                # $t0 lon hon

print_max:
    li $v0, 1                    # In gia tri so lon hon
    syscall

    # ----------------------------------------
    # b) Tinh va in Tong, Hieu, Tich, Thuong
    # ----------------------------------------

    # --- TONG ($t0 + $t1) ---
    li $v0, 4
    la $a0, msg_sum
    syscall

    add $a0, $t0, $t1
    li $v0, 1
    syscall

    # --- HIEU ($t0 - $t1) ---
    li $v0, 4
    la $a0, msg_diff
    syscall

    sub $a0, $t0, $t1
    li $v0, 1
    syscall

    # --- TICH ($t0 * $t1) ---
    li $v0, 4
    la $a0, msg_prod
    syscall

    mul $a0, $t0, $t1
    li $v0, 1
    syscall

    # --- THUONG SO THUC ($t0 / $t1) ---
    beqz $t1, divide_by_zero     # Kiem tra truong hop chia cho 0

    # In nhan "   Thuong = "
    li $v0, 4
    la $a0, msg_quot
    syscall

    # Step 1: Chuyen du lieu sang thanh ghi FPU ($f0, $f1)
    mtc1 $t0, $f0
    mtc1 $t1, $f1

    # Step 2: Doi dinh dang sang so thuc (Single float)
    cvt.s.w $f0, $f0      # $f0 = (float)$t0
    cvt.s.w $f1, $f1      # $f1 = (float)$t1

    # Step 3: Thuc hien phep chia so thuc
    div.s $f12, $f0, $f1

    # Step 4: In so thuc ra man hinh (Syscall 2)
    li $v0, 2
    syscall

    j end_program

divide_by_zero:
    li $v0, 4
    la $a0, msg_div_zero
    syscall

end_program:
    # Ket thuc chuong trinh (Syscall 10)
    li $v0, 10
    syscall