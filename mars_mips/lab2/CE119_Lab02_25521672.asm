# CE119 - Lab 02: Mang, chuoi, thu tuc va ngan xep
# MSSV: 25521672  (d = 2, k = 5)
# Gom: TN2 (stats, histogram), TN3 (check_brackets), Mo rong (draw_hist)

.data
# ================= TN2 =================
# Mang diem ca nhan: S[i] = (A0[i] + 2) mod 11
scores:    .word 8, 5, 10, 0, 4, 7, 9, 4, 8, 0, 6, 5   # T1, n = 12
n_scores:  .word 12
t2:        .word 10                                     # T2: {10}, n = 1
t3:        .word 4, 4, 4, 4, 4                          # T3: {4,4,4,4,4}, n = 5

hist:      .word 0, 0, 0, 0                             # dem so diem moi nhom

#                0  1  2  3  4  5  6  7  8  9  10      <- diem s
grade_tab: .byte 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3

str_min:   .asciiz "min="
str_max:   .asciiz " max="
str_g0:    .asciiz "g0="
str_g1:    .asciiz " g1="
str_g2:    .asciiz " g2="
str_g3:    .asciiz " g3="

# ================= TN3 =================
br1:       .asciiz "(a+b)*[c-{d/e}]"
br2:       .asciiz "f(x[i]{j}))"
br3:       .asciiz "{[(])}"
br4:       .asciiz "((a)"
br5:       .asciiz ""
br6:       .asciiz "no brackets here"
br7:       .asciiz "]"
br8:       .asciiz "([)]"
brP:       .asciiz "([{([])}])"                         # chuoi ca nhan, k = 5
           .align 2
br_tab:    .word br1, br2, br3, br4, br5, br6, br7, br8, brP
br_n:      .word 9

str_lp:    .asciiz "("
str_cm:    .asciiz ", "
str_rp:    .asciiz ")\n"

.text
main:
    # ---------------- TN2: thong ke diem ----------------
    la   $a0, scores
    lw   $a1, n_scores
    jal  stats
    move $s0, $v0               # min
    move $s1, $v1               # max

    la   $a0, scores
    lw   $a1, n_scores
    la   $a2, grade_tab
    la   $a3, hist
    jal  histogram

    # dong 1: min=.. max=..
    li   $v0, 4
    la   $a0, str_min
    syscall
    li   $v0, 1
    move $a0, $s0
    syscall
    li   $v0, 4
    la   $a0, str_max
    syscall
    li   $v0, 1
    move $a0, $s1
    syscall
    li   $v0, 11
    li   $a0, 10
    syscall

    # dong 2: g0=.. g1=.. g2=.. g3=..
    la   $s2, hist
    li   $v0, 4
    la   $a0, str_g0
    syscall
    li   $v0, 1
    lw   $a0, 0($s2)
    syscall
    li   $v0, 4
    la   $a0, str_g1
    syscall
    li   $v0, 1
    lw   $a0, 4($s2)
    syscall
    li   $v0, 4
    la   $a0, str_g2
    syscall
    li   $v0, 1
    lw   $a0, 8($s2)
    syscall
    li   $v0, 4
    la   $a0, str_g3
    syscall
    li   $v0, 1
    lw   $a0, 12($s2)
    syscall
    li   $v0, 11
    li   $a0, 10
    syscall

    # ---------------- Mo rong: ve pho diem ----------------
    la   $a0, hist
    li   $a1, 4
    jal  draw_hist

    li   $v0, 11                # dong trong ngan cach
    li   $a0, 10
    syscall

    # ---------------- TN3: kiem tra ngoac ----------------
    la   $s0, br_tab            # con tro vao bang dia chi chuoi
    li   $s1, 0                 # i = 0
    lw   $s2, br_n              # so chuoi
main_br_loop:
    beq  $s1, $s2, main_exit
    lw   $a0, 0($s0)
    jal  check_brackets
    move $s3, $v0
    move $s4, $v1

    li   $v0, 4
    la   $a0, str_lp
    syscall
    li   $v0, 1
    move $a0, $s3
    syscall
    li   $v0, 4
    la   $a0, str_cm
    syscall
    li   $v0, 1
    move $a0, $s4
    syscall
    li   $v0, 4
    la   $a0, str_rp
    syscall

    addi $s0, $s0, 4
    addi $s1, $s1, 1
    j    main_br_loop

main_exit:
    li   $v0, 10                # ket thuc chuong trinh
    syscall

# ============================================================
# stats: tim gia tri nho nhat va lon nhat cua mang word
# Tham so : $a0 = dia chi mang, $a1 = n (n >= 1)
# Tra ve  : $v0 = min, $v1 = max
# Thanh ghi su dung: $t0-$t5, $t7. Thu tuc la, khong ghi bo nho.
# ============================================================
stats:
    lw   $t1, 0($a0)            # min = A[0]
    lw   $t2, 0($a0)            # max = A[0]
    li   $t7, 1                 # i = 1
stats_loop:
    beq  $t7, $a1, stats_end
    sll  $t0, $t7, 2            # i * 4
    add  $t0, $t0, $a0          # &A[i]
    lw   $t3, 0($t0)            # A[i]
    slt  $t4, $t3, $t1          # A[i] < min ?
    beq  $t4, $zero, stats_findmax
    move $t1, $t3
stats_findmax:
    slt  $t5, $t2, $t3          # max < A[i] ?
    beq  $t5, $zero, stats_next
    move $t2, $t3
stats_next:
    addi $t7, $t7, 1
    j    stats_loop
stats_end:
    move $v0, $t1
    move $v1, $t2
    jr   $ra

# ============================================================
# histogram: voi moi diem s, tang hist[grade_tab[s]] them 1
# Tham so : $a0 = dia chi mang diem, $a1 = n,
#           $a2 = dia chi grade_tab, $a3 = dia chi hist
# Tra ve  : khong
# Thanh ghi su dung: $t0-$t6. Thu tuc la.
# ============================================================
histogram:
    li   $t0, 0                 # i = 0
hist_loop:
    beq  $t0, $a1, hist_end
    sll  $t1, $t0, 2            # i * 4 (mang word)
    add  $t1, $t1, $a0
    lw   $t2, 0($t1)            # s = scores[i]
    add  $t3, $a2, $t2          # &grade_tab[s] (mang byte, khong nhan 4)
    lbu  $t4, 0($t3)            # g = grade_tab[s]
    sll  $t5, $t4, 2            # g * 4
    add  $t5, $t5, $a3          # &hist[g]
    lw   $t6, 0($t5)
    addi $t6, $t6, 1
    sw   $t6, 0($t5)            # hist[g]++
    addi $t0, $t0, 1
    j    hist_loop
hist_end:
    jr   $ra

# ============================================================
# draw_hist: ve pho diem dang cot ngang bang ky tu '|'
# Tham so : $a0 = dia chi mang hist, $a1 = so nhom (4)
# Tra ve  : khong
# Thanh ghi su dung: $t0-$t3, $v0, $a0 (cho syscall). Thu tuc la.
# Ghi chu : syscall dung $a0 nen chep dia chi hist sang $t0 truoc.
# ============================================================
draw_hist:
    move $t0, $a0               # con tro vao hist
    move $t1, $a1               # so nhom
    li   $t2, 0                 # g = 0
dh_group:
    beq  $t2, $t1, dh_end
    li   $v0, 11
    li   $a0, 'g'
    syscall
    li   $v0, 1
    move $a0, $t2
    syscall
    li   $v0, 11
    li   $a0, ':'
    syscall
    li   $a0, ' '
    syscall
    lw   $t3, 0($t0)            # so ky tu '|' can in
dh_bar:
    beq  $t3, $zero, dh_newline # nhom rong: chi in nhan
    li   $v0, 11
    li   $a0, '|'
    syscall
    addi $t3, $t3, -1
    j    dh_bar
dh_newline:
    li   $v0, 11
    li   $a0, 10
    syscall
    addi $t0, $t0, 4
    addi $t2, $t2, 1
    j    dh_group
dh_end:
    jr   $ra

# ============================================================
# check_brackets: kiem tra cap ngoac (), [], {} trong chuoi
# Tham so : $a0 = dia chi chuoi .asciiz
# Tra ve  : $v0 = vi tri (dem tu 1), $v1 = ma loi
#           0: hop le (v0 = 0); 1: ngoac dong khac loai;
#           2: ngoac dong khi ngan xep rong; 3: het chuoi con ngoac mo
# Ngan xep: dung $sp, moi phan tu 1 word. Gap ngoac mo thi push
#           ngoac dong tuong ung, gap ngoac dong thi pop va so sanh bang.
# Thanh ghi su dung: $t0-$t3, $t8 (vi tri), $t9 ($sp luc vao). Thu tuc la.
# $sp duoc khoi phuc tai cb_exit tren moi duong thoat.
# ============================================================
check_brackets:
    move $t9, $sp               # day ngan xep = $sp luc vao
    li   $t8, 0                 # pos = 0
cb_loop:
    lbu  $t0, 0($a0)            # c = ky tu hien tai
    addi $a0, $a0, 1
    addi $t8, $t8, 1            # pos++
    beq  $t0, $zero, cb_eos     # het chuoi

    li   $t1, '('
    beq  $t0, $t1, cb_open_p
    li   $t1, '['
    beq  $t0, $t1, cb_open_b
    li   $t1, '{'
    beq  $t0, $t1, cb_open_c
    li   $t1, ')'
    beq  $t0, $t1, cb_close
    li   $t1, ']'
    beq  $t0, $t1, cb_close
    li   $t1, '}'
    beq  $t0, $t1, cb_close
    j    cb_loop                # ky tu khac: bo qua

cb_open_p:
    li   $t2, ')'
    j    cb_push
cb_open_b:
    li   $t2, ']'
    j    cb_push
cb_open_c:
    li   $t2, '}'
cb_push:
    addi $sp, $sp, -4           # push ngoac dong mong doi
    sw   $t2, 0($sp)
    j    cb_loop

cb_close:
    beq  $sp, $t9, cb_err_empty # ngan xep rong -> ma 2
    lw   $t3, 0($sp)            # pop
    addi $sp, $sp, 4
    bne  $t3, $t0, cb_err_type  # khac loai -> ma 1
    j    cb_loop

cb_err_type:
    move $v0, $t8
    li   $v1, 1
    j    cb_exit
cb_err_empty:
    move $v0, $t8
    li   $v1, 2
    j    cb_exit
cb_eos:
    beq  $sp, $t9, cb_ok
    move $v0, $t8               # pos = do dai + 1
    li   $v1, 3
    j    cb_exit
cb_ok:
    li   $v0, 0
    li   $v1, 0
cb_exit:
    move $sp, $t9               # khoi phuc $sp
    jr   $ra