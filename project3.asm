	.text
	.globl main
main:
	la $a0, first_num		# Prompts the user to enter the first integer
	li $v0, 4			# Prints the prompt
	syscall
	
	li $v0, 5			# User inputs the first integer
	syscall
	
	move $t0, $v0			# Store the first integer in $t0
	
	la $a0, second_num		# Prompts the user to enter the second integer
	li $v0, 4			# Prints the prompt
	syscall
	
	li $v0, 5			# User inputs the second integer
	syscall
	
	move $t1, $v0			# Store the second integer in $t1
	
	la $a0, dnl			# dnl = Double newline = "\n\n"
	li $v0, 4			# Prints the double newline
	syscall
	
	la $a0, dw_space		# dw_space = Double white space = "  "
	li $v0, 4			# Prints the double white space
	syscall
	
	li $t2, 0			# Loop counter: i = 0		
	li $t3, 2			# Loop end (# of integers): i <= 2
	li $t5, 1			# Check if i = 1 (converted the first integer)	
					# , now convert the second integer
bin_convert:
	beq $t2, $t3, print_sum		# if(i == 2): print_sum (print '----' before the sum)

	li $t4, 32			# x = 32 (number of bits)
	addi $t2, $t2, 1		# Increment loop counter: i++

	jal load_array			# Choose which integer array to use (i=1 (first_int), i=2 (second_int))
	sub $t4, $t4, 1			# x-- = 31 (subscript for the array: a[x])
	beq $t2, $t3, add_num		# if(i == 2): add_num (print '+' before the second binary #)

	loop:
		blt $t4, $zero, bin_convert		# if(x < 0): bin_convert
		
		srlv $t6, $t0, $t4			# $t6 = $t0 (first integer) >> 31
		sub $t4, $t4, 1				# x-- = 30
		and $t7, $t6, 1				# $t7 = $t6 (1 or 0) && 1
		
		jal bits				# Print the bits
		jal store				# Store the bits

		j loop					# Repeat
	
	load_array:
		beq $t2, $t5, first_array		#  if(i == 1): first_array

		second_array:
			la $a1, s_array			# $a1 = s_array[x]
			jr $ra				# Return
		
		first_array:
			la $a1, f_array			# $a1 = f_array[x]
			jr $ra				# Return

	add_num:
		la $a0, nl				# nl = Newline
		li $v0, 4				# Print a newline
		syscall

		la $a0, plus				# plus = '+'
		li $v0, 4				# Print '+'
		syscall
	
		la $a0, w_space				# w_space = white space = " "
		li $v0, 4				# Print the white space
		syscall
	
		move $t9, $t0				# Move the first integer into $t9: $t9 = $t0
		move $t0, $t1				# Move the second integer into the register of the first: $t0 = $t1

		j loop					# Jump to loop.

	bits:
		beqz $t7, zero				# if(($t6 && 1) == 0): zero (print '0')
		
		one:
			la $a0, o			# o = '1'
			li $v0, 4			# Print the bit '1'
			syscall
		
			jr $ra				# Return
		zero:
			la $a0, z			# z = '0'
			li $v0, 4			# Print the bit '0'
			syscall
		
			jr $ra				# Return
	
	store:
		beq $t2, $t3, save_second		# if(i == 2 (total # of integers)): save_second

		save_first:
			sb $t7, 0($a1)			# f_array[x] = $t7 (a bit (1 or 0))
			addi $a1, $a1, 4		# Increment the array: f_array[x+1]
			
			jr $ra				# Return

		save_second:
			sb $t7, 0($a1)			# s_array[x] = $t7 (a bit (1 or 0))
			addi $a1, $a1, 4		# Increment the array: s_array[x+1]
			
			jr $ra				# Return

	print_sum:
		la $a0, equals				# Print the equals line
		li $v0, 4				# Print the line
		syscall
	
		la $a0, dw_space			# dw_space = double white space = "  "
		li $v0, 4				# Print dw_space
		syscall
	
		j sum_bin				# Jump to sum_bin
sum_bin:
	li $t4, 31			# Number of bits in the array
	li $s3, 0			# Set carry to 0

	la $a1, f_array			# $a1 = f_array[x]
	la $a2, s_array			# $a2 = s_array[x]
	la $a3, sum_array		# $a3 = sum_array[x]
	
	addi $a1, $a1, 124		# Start at the end of the array: f_array[124]
	addi $a2, $a2, 124		# Start at the end of the array: s_array[124]
	addi $a3, $a3, 124		# Start at the end of the array: sum_array[124]

	sum_loop:
		blt $t4, $zero, sum_print		# if($t4 < 0): sum_print
		
		lb $s0, ($a1)				# $s0 = f_array[x]
		lb $s1, ($a2)				# $s1 = s_array[x]

		xor $s2, $s0, $s1			# $s2 = $s0(1 or 0) ^ $s1(1 or 0)
		xor $s2, $s2, $s3			# $s2 = $s2 ($s0 ^ $s1) ^ $s3 (carry)

		jal carry				# Set carry

		move $s5, $s0				# $s5 = $s0 (bit from f_array)
		move $s6, $s1				# $s6 = $s1 (bit from s_array)

		sb $s2, ($a3)				# sum_array[x] = $s2
		
		sub $t4, $t4, 1				# x-- = 31 - 1 = 30 (Number of bits in the array)

		sub $a1, $a1, 4				# f_array[x-1]
		sub $a2, $a2, 4				# s_array[x-1]
		sub $a3, $a3, 4				# sum_array[x-1]

		j sum_loop				# Repeat
		
	sum_print:
		li $t4, 31				# Number of bits in the array
		la $a3, sum_array			# $a3 = sum_array[x]

		sum_print_loop:
			blt $t4, $zero, hex_convert 	# if($t4 < 0): hex_convert

			lb $s2, ($a3)			# $s2 = sum_array[x]
			addi $a3, $a3, 4		# sum_array[x+1]
			
			sub $t4, $t4, 1			# x-- = 31 - 1 = 30

			move $t7, $s2			# Move the bit from sum_array into $t7: $t7 = $s2
			jal bits			# Print the bits
			move $s2, $t7			# Move the bit back into $s2: $s2 = $t7
		
			j sum_print_loop		# Repeat
		
	carry:
		beq $s0, $s1, carry_one			# if($s0(first_int_bit) == $s1(second_int_bit)): carry_one
		beq $s2, $s3, carry_one_2		# if($s2(sum_array_bit) == $s3(carry)): carry_one_2

		jr $ra					# Return

		carry_one:
			beqz $s0, check			# if($s0(first_int_bit) == 0): check
			li $s3, 1			# Set carry to 1

			jr $ra				# Return

		carry_one_2:				# Carry again
			li $s3, 1			# Set carry to 1

			jr $ra				# Return

		check:
			xor $s7, $s5, $s6		# $s7 = $s5(1 or 0) ^ $s6(1 or 0)
			beq $s7, $s0, reset		# if(($s5 ^ $s6) == $s0): reset
			
			li $s3, 0			# Set carry to 0
			jr $ra				# Return

		reset:
			li $s3, 0			# Reset carry
			jr $ra				# Return
		
	return:
		jr $ra			# Return
hex_convert:
	li $t2, 0			# Loop counter: i = 0		
	li $t3, 2			# Loop end (# of integers): i <= 2
	li $t5, 1			# Check if i = 1 (converted the first integer)
	li $t4, 32			# Number of bits
	li $a2, 4			# Size of hex digit

	move $t1, $t0			# Move the second integer in $t0 back into $t1: $t1 = $t0
	move $t0, $t9			# Move the first integer in $t9 back into $t0: $t0 = $t9

	li $t7, 1			# Set $t7 = 1
	sllv $t7, $t7, $a2		# $t7 = $t7 << 4
	sub $t7, $t7, 1			# $t7 = $t7 - 1

	la $a1, hex_digits		# $a1 = hex_digits = "0123...DEF"
	la $a0, hex_mess		# Prompts the user that the program will now print the numbers in hex
	li $v0, 4			# Prints the message
	syscall
	
	la $a0, dw_space		# dw_space = double white space = "  "
	li $v0, 4			# Print dw_space
	syscall

	conversion:
		beq $t2, $t3, done			# if(i == $t3): done (end program)
		beqz $t2, first_hex_num			# if(i == 0): first_hex_num (Convert the first integer)
		addi $t2, $t2, 1			# i++

		li $t4, 32				# Number of bits

		la $a0, nl				# nl = newline
		li $v0, 4				# Print nl
		syscall
		
		la $a0, plus				# plus = '+'
		li $v0, 4				# Print '+'
		syscall

		la $a0, w_space				# w_space = white space = " "
		li $v0, 4				# Print the white space
		syscall
		
		la $a3, hex_sarray			# $a3 = hex_sarray 
		move $t6, $t1				# Move the second integer into $t6: $t6 = $t1

	hex_loop:
		and $t8, $t6, $t7			# $t8 = $t6(1 or 0) && $t7(1 or 0)
		lb $t8,  hex_digits($t8)		# $t8 = hex_digits($t8) (Gets the hex digit)
		
		sub $a3, $a3, 1			# Decrement the array by 1: hex_a[x-1]
		sb $t8, 0($a3)				# hex_a[x-1] = $t8
		
		srlv $t6, $t6, $a2			# $t6 = $t6 (integer(first or second)) >> 4
		sub $t4, $t4, $a2			# $t4 = 32 - 4 = 28
		bgtz $t4, hex_loop			# if($t4 > 0): hex_loop
		
		move $a0, $a3				# Move $a3 (array of the integer in hex) to $a0
		li $v0, 4				# Print the integer in hex
		syscall	
		
		bgt $t2, $t3, done			# if($t2 > $t3): done
		beq $t2, $t3, print_hex_sum		# if($t2 == $t3): print_hex_sum
		
		j conversion				# Jump to conversion
		
	first_hex_num:
		addi $t2, $t2, 1			# i++
		la $a3, hex_farray			# $a3 = hex_farray
		move $t6, $t0				# Move the first integer into $t6: $t6 = $t0

		j hex_loop				# Jump to hex_loop
	
	print_hex_sum:
		la $a0, equals				# Print the equals line
		li $v0, 4				# Print the line
		syscall
	
		la $a0, dw_space			# dw_space = double white space
		li $v0, 4				# Print dw_space
		syscall
		
		j sum_hex_num				# Jump to sum_hex_num (Print the sum in hex)
	
	sum_hex_num:
		la $a3, hex_sum_array			# $a3 = hex_sum_array
		addi $t2, $t2, 1			# i++
		add $t9, $t0, $t1			# $t9 (sum) = $t0 (integer 1) + $t1 (integer 2)

		move $t6, $t9				# Move the sum of the integers in $t9 into $t6: $t6 = $t9
		li $t4, 32				# Reset $t4 to 32 (Number of bits)

		j hex_loop				# Jump to hex_loop

done:
	la $a0, complete		# Prompt the user that the program is complete.
	li $v0, 4			# Print the message.
	syscall
	
	li $v0, 10			# Exit the program
	syscall	

	.data
first_num:		.asciiz			"Enter the first number: "
second_num:		.asciiz			"Enter the second number: "
o:			.asciiz			"1"
z:			.asciiz			"0"
nl:			.asciiz			"\n"
dnl:			.asciiz			"\n\n"
f_array:		.space			128
s_array:		.space			128
sum_array:		.space			128
complete:		.asciiz			"\n\nprogram complete"
plus:			.asciiz			"+"
w_space:		.asciiz			" "
dw_space:		.asciiz			"  "
equals:			.asciiz 		"\n------------------------------------------\n"
hex_mess:		.asciiz			"\n\nIn Hex: \n"
hex_farray:		.space			32
hex_sarray:		.space			32
hex_sum_array:		.space			32
hex_digits:		.asciiz			"0123456789ABCDEF"