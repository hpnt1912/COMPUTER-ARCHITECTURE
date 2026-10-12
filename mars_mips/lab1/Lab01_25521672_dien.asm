.data
DungLuong: .word 50, 50, 100, 100, 100, 9599, -1
DonGia: .word 1640, 1700, 1990, 2540, 2890, 3040

nhap: .asciiz "Nhap so kWh (0..9999): "
koHopLe: .asciiz "Gia tri khong hop le, nhap lai\n"
tienDien: .asciiz "Tien dien: "
dong: .asciiz " dong\n"

.text
.globl main

main:

loop:
    li $v0, 4 #in thong bao nhap x
    la $a0, nhap
    syscall
    
    li $v0, 5 #nhap x tu ban phim
    syscall
    move $s0, $v0 # $s0 = x
    
    sltiu $t3, $s0, 10000 # neu (unsigned)x < 10000 -> $t3 = 1, nguoc lai $t3 = 0
    beq $t3, $zero, NhapLai # neu $t3 = 0, thi nhay den nhap lai
    j xu_ly
    NhapLai:
           li $v0, 4 #in ra thong bao so ko hop le, nhap lai
           la $a0, koHopLe
           syscall
           
    j loop

xu_ly:
     li $t0, 0 #tao i = 0
     li $s1, 0 #tao res = 0
     la $s2, DungLuong #dia chi goc Dung Luong
     la $s3, DonGia #dia chi goc Don Gia
     
     loop_tinh:
          #kiem tra x <= 0 thi dung 
          blez $s0, end_loop
     
          #tinh dia chi phan tu DungLuong[i] 
          sll $t4, $t0, 2
          add $t4, $t4, $s2
          lw $t1, 0($t4) # DungLuong[i] = $t1
     
          #kiem tra DuongLuong[i] = -1 thi dung
          li $t4, -1
          beq $t1, $t4, end_loop
           
          #tinh dia chi phan tu DonGia[i]
          sll $t4, $t0, 2
          add $t4, $t4, $s3
          lw $t2, 0($t4) # DonGia[i] = $t2
          
          move $t3, $s0 # gan kWh_bac = x
          ble $s0, $t1, skip_kWh # neu x <= DungLuong[i] thi nhay toi skip_kWh
          move $t3, $t1 #neu x > DungLuong[i] thi gan kWh_bac = DungLuong[i] 
          
          skip_kWh: 
                  mul $t5, $t3, $t2 # $t5 = kWh_bac * DonGia[i]
                  add $s1, $s1, $t5 # res = res + $t5
                  sub $s0, $s0, $t3 # x = x - kWh_bac($t3)
                  addi $t0, $t0, 1 # i = i + 1
                  j loop_tinh
      
      end_loop:
              li $v0, 4 #in ra dong chu tien dien
              la $a0, tienDien
              syscall
              
              li $v0, 1 #ghi gia tri cua res va xuat ra man hinh
              move $a0, $s1
              syscall
               
              li $v0, 4 #in dong va xuong dong
              la $a0, dong
              syscall
              
end_program:
           li $v0, 10
           syscall
     
     
     
     
     
     
     
     
     
     
     
     
     
