.data
# ---------- Chuoi kiem tra (Bang 16) ----------
br1:      .asciiz "(a+b)*[c-{d/e}]"
br2:      .asciiz "f(x[i]{j}))"
br3:      .asciiz "{[(])}"
br4:      .asciiz "((a)"
br5:      .asciiz ""
br6:      .asciiz "no brackets here"
br7:      .asciiz "]"
br8:      .asciiz "([)]"
brP:      .asciiz "([{([])}])"          # chuoi ca nhan, k = 5
          .align 2
br_tab:   .word br1, br2, br3, br4, br5, br6, br7, br8, brP
br_n:     .word 9

str_lp:   .asciiz "("
str_cm:   .asciiz ", "
str_rp:   .asciiz ")\n"

.text
main:
    la   $a0, brP           # chi chay chuoi P
    jal  check_brackets
    nop                     # <-- cho de dat breakpoint sau khi tra ve
    li   $v0, 10
    syscall
main_loop:
    beq  $s1, $s2, main_exit
    lw   $a0, 0($s0)            # $a0 = dia chi chuoi thu i
    jal  check_brackets
    move $s3, $v0               # cat ket qua (syscall se ghi de $v0)
    move $s4, $v1

    li   $v0, 4                 # in "("
    la   $a0, str_lp
    syscall
    li   $v0, 1                 # in v0
    move $a0, $s3
    syscall
    li   $v0, 4                 # in ", "
    la   $a0, str_cm
    syscall
    li   $v0, 1                 # in v1
    move $a0, $s4
    syscall
    li   $v0, 4                 # in ")\n"
    la   $a0, str_rp
    syscall

    addi $s0, $s0, 4            # sang chuoi ke tiep
    addi $s1, $s1, 1
    j    main_loop
main_exit:
    li   $v0, 10
    syscall

# check_brackets: kiem tra cap ngoac (), [], {} trong chuoi
# Tham so : $a0 = dia chi chuoi .asciiz
# Tra ve  : $v0 = vi tri loi (dem tu 1), $v1 = ma loi
#           (0,0) hop le; (pos,1) khac loai; (pos,2) dong khi rong;
#           (len+1,3) het chuoi con ngoac mo
# Ngan xep: dung $sp, moi phan tu 1 word; push NGOAC DONG tuong ung
#           voi ngoac mo de khi gap ngoac dong chi can so sanh bang nhau.
# Thanh ghi su dung: $t0-$t3, $t8 (pos), $t9 ($sp luc vao)
check_brackets:
    move $t9, $sp               # luu $sp luc vao: day ngan xep
    li   $t8, 0                 # pos = 0
cb_loop:
    lbu  $t0, 0($a0)            # c = ky tu hien tai
    addi $a0, $a0, 1
    addi $t8, $t8, 1            # pos++
    beq  $t0, $zero, cb_eos     # gap '\0' -> het chuoi

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
    beq  $sp, $t9, cb_ok        # het chuoi, ngan xep rong -> hop le
    move $v0, $t8               # pos luc nay = do dai + 1
    li   $v1, 3
    j    cb_exit
cb_ok:
    li   $v0, 0
    li   $v1, 0
cb_exit:
    move $sp, $t9               # khoi phuc $sp tren MOI duong thoat
    jr   $ra