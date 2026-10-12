.data
hello: .asciiz "Xin chao MARS"

.text
li $v0, 4
la $a0, hello
syscall

