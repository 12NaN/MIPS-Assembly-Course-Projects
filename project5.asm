	.text
	.globl main
main:
	la $a0, sign_integer		# Prompts the user to enter a signed integer	
	li $v0, 4			# Print the prompt
	syscall			

	li $v0, 5 			# Enter the signed integer: ex: -3
	syscall			
	
	beqz $v0, done			# if($v0 == 0): done
	move $t0, $v0			# else: x = $v0

	li $s1, 0x80000000		# Bitmask to get sign 
	and $a3, $t0, $s1		# $a3 = $t0 && $s1 = -3 && 0x80000000 = 1 && 1 = 1
	
	jal sign_check			# Check the sign in $a3
	
	la $a0, decimal_num		# Prompts the user to enter a decimal number in binary
	li $v0, 4			# Prints the prompt
	syscall				
			 
	la $a0, dec_bin_string		# $a0 = dec_bin_string (stores the binary string)
	li $a1, 32			# Size of the bin_string
	li $v0, 8 			# Reads the users input as a string.	
	syscall	
	
	bltz $t0, make_positive		# if($t0 < 0): (i.e. a negative #) make_positive

	j print_sign_bit		# Print the sign bit

sign_check:
	beqz $a3, zero_sign		# if($a3 == 0): zero_sign (0 for sign bit)
	li $a3, 1			# else: 1 for sign bit
	jr $ra				# return to main
	
	zero_sign:
		li $a3, 0		# $a3 = 0 (0 for sign bit)
		jr $ra			# return to main
make_positive:
	li $s6, -1			# $s6 = -1
	
	mult $t0, $s6			# ex: -3 * -1 = 3
	mflo $t0			# ex: x = 3

print_sign_bit:
	la $a0, sign_bit		# Prompt "sign bit = "
	li $v0, 4			# Print the prompt
	syscall
	
	beqz $a3, print_zero_sign_bit	# if($a3 == 0): print_zero_sign_bit

	la $a0, one			# ex: $a0 = $a3 = 1 (sign bit)
	li $v0, 4			# Print the sign bit
	syscall
	
	sll $a3, $a3, 31		# ex: $a3 = 1 << 31 = 1000 0000 0000 0000 0000 0000 0000 0000

	j decimal_point			# Jump to decimal_point

print_zero_sign_bit:
	la $a0, zero			# ex: $a0 = $a3 = 0 (sign bit)
	li $v0, 4			# Print the sign bit
	syscall
	
	sll $a3, $a3, 31		# ex: $a3 = 0 << 31 = 0000 0000 0000 0000 0000 0000 0000 0000

decimal_point:
	la $a0, dec_bin_string		# $a0 = dec_bin_string
	li $a1, 0x2e			# hex for decimal point = '.'
	
	lb $t2, 0($a0)			# if dec_bin_string has a decimal point $t2 = . = $a0[0]
	bne $t2, $a1, conversion	# if($t2 != '.'): conversion
	
	li $t1, 0			# i = 0
	la $a1, dec_bin_string		# $a1 = dec_bin_string with decimal point = .101
	addi $a0, $a0, 1		# $a0[1] = dec_bin_string without decimal point = 101

	without_decimal_point:
		bgt $t1, 32, conversion	# if(i > 32): conversion

		lb $t2, 0($a0)		# ex: $t2 = $a0[1] = 1
		sb $t2, 0($a1)		# ex: $a1[0] = 1

		addi $a0, $a0, 1	# $a0[1 + 1] = $a0[2]
		addi $a1, $a1, 1	# $a1[0 + 1] = $a1[1]
		addi $t1, $t1, 1	# i++

		j without_decimal_point	# for(int i = 0; i <= 32; i++): repeat

conversion:			
	la $a0, dec_bin_string		# $a0 = dec_bin_string
	la $a1, store_dec_bin_string	# $a1 = store_dec_bin_string
	li $t1, 0			# i = 0
	li $s1, 0x01010101		# Bitmask to find the exponent

	exponent:	
		bgt $t1, 8, exponent_digits	# if(i > 8 (# of bits for exponent)): exponent_digits

		lw $t2, 0($a0)			# $t2 = $a0[0]
		and $t2, $t2, $s1		# ex: $t2 = $t2 && $s1 = 1 && 1 = 1
		sw $t2, 0($a1)			# $a1[0] = $t2

		addi $a0, $a0, 4		# $a0[0 + 1] = $a0[1]
		addi $a1, $a1, 4		# $a1[0 + 1] = $a1[1]
		addi $t1, $t1, 1		# i = i + 1

		j exponent			# Repeat

	exponent_digits:
		la $t1, store_dec_bin_string	# $t1 = store_dec_bin_string
		li $t2, 31			# Total number of bits: 0 -> 31
		li $s6, 0			# y =  0

	get_exponent_digits:
		bltz $t2,fraction		# if($t2 < 0): fraction

		lb $t3, 0($t1)			# $t3 = $t1[0]
		sllv $t3, $t3, $t2		# ex: $t3 = $t3 << $t2 = 1 << 31 = 1000...0000 (31 zeros following 1)
		or $s6, $s6, $t3		# ex: $s6 = 0 || 1 = 1

		add $t1, $t1, 1			# $t1[0+1] = $t1[1]
		sub $t2, $t2, 1			# $t2 = $t2 - 1 = 31 - 1

		j get_exponent_digits		# Repeat
	
	fraction:
		move $t2, $t0			# $t2 = signed integer
		li $t1, 32			# i = 32
		li $s1, 0x80000000		# Bit mask to get the fraction bits
	
	fraction_digits:
		and $t3, $t2, $s1		# $t3 = $t2 && $t1 = 1 && 1 = 1
		beq $t3, $s1, get_fraction_digits	# if($t3 == 8): get_fraction_digits

		sll $t2, $t2, 1			# ex: $t2 = $t2 << 1 = 1 << 1 = 10
		sub $t1, $t1, 1			# i-- = i - 1 = 32 - 1 = 31
	
		j fraction_digits		# Repeat

	get_fraction_digits:				
		move $t2, $s6			# ex: $t2 = 0

		sub $t3, $t1, 1			# $t3 = 8 - 1
		srlv $t2, $t2, $t3		# ex: $t2 = $t2 >> $t3 = 0 >> 7 = 0000 0000
		li $s3, 33			# $s3 = 33

		sub $s3, $s3, $t1		# $s3 = 33 - 8
		sllv $t3, $t0, $s3		# ex: $t3 = 1 << 25 = 1000 0000 0000 0000 0000 0000 0
	
		or $s3, $t3, $t2		# ex: $s3 = $t3 || $t2 = 1 || 0 = 1
		srl $a2, $s3, 9			# ex: $a2 = 1 >> 9 = 00 0000 0001

	print_exponent_in_decimal:
		# exponent - biased
		sub $t1, $t1, 1			# exponent - 1
		add $a1,$t1,127			# $a1 = exponent + 127 

		la $a0, dec_point		# Prompt the user: "Exponent in decimal ="
		li $v0, 4			# Print the prompt
		syscall	
		
		move $a0, $a1			# $a0 = $a1 = exponent in decimal
		li $v0, 1			# Print the exponent in decimal	
		syscall		
		
		sll $a1, $a1, 23		# ex: $a1 = $a1 << 23 = 1 << 23 = 1000 0000 0000 0000 0000 0000

		or $s0, $a3, $a1		# $s0 = $a3(sign bit) || $a1(exponent)
		or $s0, $s0, $a2		# $s0 = $s0 || $a2(fraction) 

floating_point:
	la $a0, bits_float			# Prompt the user: "All bits of the floating point number are:"
	li $v0, 4				# Print the prompt
	syscall			

	li $t1, 0				# i = 0
	move $t2, $s0				# $t2 = floating point number

	li $t3, 0x80000000			# bit mask for floating point bits
	li $s7, 0				# j = 0
	li $t8, 4				# j == 4

	print_floating_point_bits:
		beq $t1, 32, print_floating_point_num	# if(i == 32): print_floating_point_num
		beq $s7, $t8, bit_space			# if(j == 4): bit_space (print white space after printing four bits = a nibble)

		and $a0, $t2, $t3			# ex: $a0 =  $t2 && $t3 = 1 && 0 = 0
		srl $a0, $a0, 31			# ex: $a0 = 0 >> 31 = 0000 ... 0000 (31 0 bits following 0 ($a0))
		beqz $a0, print_zero			# if($a0 == 0): print_zero

		la $a0, one				# else: print "1"
		li $v0, 4				# print "1"
		syscall
		
		sll $t2, $t2, 1				# ex: $t2 = 1 << 1 = 10
		addi $s7, $s7, 1			# j = j + 1
		addi $t1, $t1, 1			# i = i + 1
	
		j print_floating_point_bits		# Repeat

	print_zero:
		la $a0, zero		# $a0 = "0"
		li $v0, 4		# Print "0"
		syscall
	
		sll $t2, $t2, 1		# ex: $t2 =  1 << 1 = 10
		addi $s7, $s7, 1	# j = j + 1
		addi $t1, $t1, 1	# $t1 =  $t1 + 1
	
		j print_floating_point_bits		# Jump to floating_point_bits

	bit_space:
		li $s7, 0		# Reset j to 0

		la $a0, white_space	# $a0 =  " "
		li $v0, 4		# Print the whitespace
		syscall

		j print_floating_point_bits	# Jump to floating_point_bits

	print_floating_point_num:
		la $a0, float_point_num 	# Prompt the user: "The floating point number is: "
		li $v0, 4			# Print the prompt
		syscall
	
		mtc1 $s0, $f12		# ex: float = $s0 = 1100 0000 0110 1000 0000 0000 0000 0000
		li $v0, 2		# System call to print a floating point integer
		syscall			

done:
	la $a0, complete	# Prompts the user that the program is complete
	li $v0, 4		# Print the prompt
	syscall
	
	li $v0, 10		# Exit the program
	syscall	

			.data
sign_integer:		.asciiz		"Enter signed integer part.\n"
decimal_num:		.asciiz		"Enter fraction as a binary string.\n"
nl:			.asciiz		"\n"
sign_bit:		.asciiz		"\nsign bit = "
dec_point:		.asciiz		"\nExponent in decimal = "
bits_float:		.asciiz		"\nAll bits of the floating point number are:\n"	
float_point_num:	.asciiz		"\nThe floating point number is:\n"
			.align		2
dec_bin_string:		.space		128
store_dec_bin_string:	.space		128
one:			.asciiz		"1"
zero:			.asciiz		"0"
white_space:		.asciiz		" "
complete:		.asciiz		"\n\nProgram Complete"