.data
    array:          .space 400            # C?p phát b? nh? cho m?ng t?i ða 100 ph?n t? (100 * 4 bytes)
    prompt_n:       .asciiz "Nhap so luong phan tu n (1 -> 100): "
    prompt_elem1:   .asciiz "Nhap array["
    prompt_elem2:   .asciiz "]: "
    msg_max:        .asciiz "\na) Gia tri lon nhat: "
    msg_min:        .asciiz "\n   Gia tri nho nhat: "
    msg_sum:        .asciiz "\nb) Tong cac phan tu: "
    prompt_idx1:    .asciiz "\nc) Nhap chi so k phan tu can xem (0 -> "
    prompt_idx2:    .asciiz "): "
    msg_val1:       .asciiz "   Gia tri array["
    msg_val2:       .asciiz "] = "
    msg_invalid:    .asciiz "   Loi: Chi so k nam ngoai pham vi cua mang!"

.text
.globl main

main:
    # ----------------------------------------------------
    # 1. NH?P S? LÝ?NG PH?N T? (n) VÀ CÁC PH?N T? C?A M?NG
    # ----------------------------------------------------
    # In thông báo nh?p n
    li $v0, 4
    la $a0, prompt_n
    syscall

    # Ð?c n t? bàn phím (lýu vào $s0)
    li $v0, 5
    syscall
    move $s0, $v0        # $s0 = n

    # Kh?i t?o bi?n ð?m v?ng l?p nh?p
    li $t0, 0            # $t0 = i = 0
    la $s1, array        # $s1 = ð?a ch? g?c c?a m?ng (array[0])

input_loop:
    bge $t0, $s0, process_array   # N?u i >= n th? d?ng nh?p, chuy?n sang x? l?

    # In thông báo "Nhap array[i]: "
    li $v0, 4
    la $a0, prompt_elem1
    syscall

    li $v0, 1
    move $a0, $t0        # In ch? s? i
    syscall

    li $v0, 4
    la $a0, prompt_elem2
    syscall

    # Ð?c giá tr? nh?p vào
    li $v0, 5
    syscall              # K?t qu? nh?p n?m ? $v0

    # Tính ð?a ch? ph?n t? array[i]: ð?a ch? = $s1 + (i * 4)
    sll $t1, $t0, 2      # $t1 = i * 4 (d?ch trái 2 bit týõng ðýõng nhân 4)
    add $t2, $s1, $t1    # $t2 = ð?a ch? th?c c?a array[i]
    sw $v0, 0($t2)       # Lýu giá tr? v?a nh?p vào array[i]

    addi $t0, $t0, 1     # i++
    j input_loop

# ----------------------------------------------------
# 2. X? L?: T?M MIN, MAX VÀ TÍNH T?NG (CÂU a & b)
# ----------------------------------------------------
process_array:
    lw $t3, 0($s1)       # $t3 = min = array[0]
    lw $t4, 0($s1)       # $t4 = max = array[0]
    li $t5, 0            # $t5 = sum = 0
    li $t0, 0            # $t0 = i = 0

calc_loop:
    bge $t0, $s0, print_results   # N?u i >= n th? chuy?n sang in k?t qu?

    # L?y giá tr? array[i]
    sll $t1, $t0, 2      # $t1 = i * 4
    add $t2, $s1, $t1    # $t2 = ð?a ch? array[i]
    lw $t6, 0($t2)       # $t6 = array[i]

    # Tính t?ng: sum += array[i]
    add $t5, $t5, $t6

    # C?p nh?t Min: if (array[i] < min) min = array[i]
    bge $t6, $t3, check_max
    move $t3, $t6

check_max:
    # C?p nh?t Max: if (array[i] > max) max = array[i]
    ble $t6, $t4, next_item
    move $t4, $t6

next_item:
    addi $t0, $t0, 1     # i++
    j calc_loop

# ----------------------------------------------------
# 3. XU?T K?T QU? CÂU a VÀ CÂU b
# ----------------------------------------------------
print_results:
    # --- Câu a) In Max ---
    li $v0, 4
    la $a0, msg_max
    syscall

    li $v0, 1
    move $a0, $t4        # In Max ($t4)
    syscall

    # --- Câu a) In Min ---
    li $v0, 4
    la $a0, msg_min
    syscall

    li $v0, 1
    move $a0, $t3        # In Min ($t3)
    syscall

    # --- Câu b) In T?ng ---
    li $v0, 4
    la $a0, msg_sum
    syscall

    li $v0, 1
    move $a0, $t5        # In Sum ($t5)
    syscall

# ----------------------------------------------------
# 4. TRUY XU?T PH?N T? THEO CH? S? (CÂU c)
# ----------------------------------------------------
    # In thông báo "c) Nhap chi so k phan tu can xem (0 -> n-1): "
    li $v0, 4
    la $a0, prompt_idx1
    syscall

    li $v0, 1
    addi $a0, $s0, -1    # In giá tr? (n - 1)
    syscall

    li $v0, 4
    la $a0, prompt_idx2
    syscall

    # Ð?c ch? s? k
    li $v0, 5
    syscall
    move $t7, $v0        # $t7 = k

    # Ki?m tra ði?u ki?n h?p l?: 0 <= k < n
    bltz $t7, invalid_index      # N?u k < 0 -> Nh?y t?i báo l?i
    bge $t7, $s0, invalid_index  # N?u k >= n -> Nh?y t?i báo l?i

    # Ch? s? h?p l?: L?y giá tr? array[k]
    sll $t1, $t7, 2      # $t1 = k * 4
    add $t2, $s1, $t1    # $t2 = ð?a ch? array[k]
    lw $t8, 0($t2)       # $t8 = array[k]

    # In k?t qu?: "Gia tri array[k] = ..."
    li $v0, 4
    la $a0, msg_val1
    syscall

    li $v0, 1
    move $a0, $t7        # In k
    syscall

    li $v0, 4
    la $a0, msg_val2
    syscall

    li $v0, 1
    move $a0, $t8        # In array[k]
    syscall

    j end_program

invalid_index:
    li $v0, 4
    la $a0, msg_invalid
    syscall

end_program:
    # K?t thúc chýõng tr?nh
    li $v0, 10
    syscall