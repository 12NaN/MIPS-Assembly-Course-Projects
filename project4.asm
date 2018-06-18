	.text
	.globl main
main:
	jal allwork		# Start the program
	
	li $v0, 10		# Exit the program
	syscall
	
allwork:
	sw $ra, ($sp)		# Push the return address of main to the top of the stack: s[0] = $ra1
	jal input     		# Ask the user for input a, b, c
	jal check		# Check if the points make a right triangle
	jal print		# Print the results
	
input:
	addi $sp, $sp, -16	# Decrement the stack: s[4]
	sw $ra, ($sp)		# Push '$ra2' to s[4]: s[4] = $ra2
	addi $sp, $sp, 16	# Return to s[0]

	li $t4, 1		# Check for integer 1: j = 1
	li $t5, 2		# Check for integer 2: j = 2
	li $t6, 3		# Check for the last integer / End loop: j <= 3
	li $s6, 0		# Check if we've set the stack to 'a'
	
	first_num:
		
		la $a0, enterNum1	# Prompts the user to enter an integer for 'a'
		li $v0, 4		# Prints the prompt
		syscall
	
		li $v0, 5		# Take the input for 'a'
		syscall
	
		move $t0, $v0		# $t0 = $v0 = a (Mutable)
		move $s3, $v0		# $s3 = $v0 = A (Immutable)

		move $t7, $t0		# ex: x = integer 1 (Mutable)
		move $t9, $t0		# ex: X = integer 1 (Immutable)

		addi $sp, $sp, -4	# Decrement the stack: s[1]
		sw $v0, ($sp)		# Push 'a' to s[1]: s[1] = a
		
		jal pow			# Get the exponent: a^2 + b^2 = c^2
	
	second_num:

		move $s0, $t7		# Store a^2 in $s0		

		la $a0, enterNum2	# Prompts the user to enter an integer for 'b'
		li $v0, 4		# Prints the prompt
		syscall
		
		li $v0, 5		# Take the input for 'b'
		syscall
	
		move $t1, $v0		# $t1 = $v0 = b (Mutable)
		move $s4, $v0		# $s4 = $v0 = B (Immutable)
	
		move $t7, $t1		# ex: y = integer 2 (Mutable)
		move $t9, $t1		# ex: Y = integer 2 (Immutable)

		addi $sp, $sp, -4	# Decrement the stack: s[2]
		sw $v0, ($sp)		# Push 'b' to s[2]: s[2] = b

		jal pow			# Get the exponent: a^2 + b^2 = c^2

	last_num:

		move $s1, $t7		# Store b^2 in $s1
	
		la $a0, enterNum3	# Prompts the user to enter an integer for 'c'
		li $v0, 4		# Prints the prompt
		syscall

		li $v0, 5		# Take the input for 'c'
		syscall
	
		move $t2, $v0		# $t2 = $v0 = c (Mutable)
		move $s5, $v0		# $s5 = $v0 = C (Immutable)

		move $t7, $t2		# ex: z = integer 3 (Mutable)
		move $t9, $t2		# ex: Z = integer 3 (Immutable)

		addi $sp, $sp, -4	# Decrement the stack: s[3]
		sw $v0, ($sp)		# Push 'c' to s[3]: s[3] = c
	
		jal pow			# Get the exponent: a^2 + b^2 = c^2

	move $s2, $t7			# Store c^2 in $s2

	addi $sp, $sp, -4		# Decrement the stack: s[4]
	lw $ra, ($sp)			# Pop $ra2 and store it in $ra: $ra = $ra2
	addi $sp, $sp, 4		# Return to s[3]

	jr $ra				# Return to allwork

pow:
	set:
		li $t3, 1		# i = 1
		li $t8, 2		# i <= 2
		li $s6, 0		# Set to 0 to return to 'a' in the stack

		j loop				# Go to loop
		
	get_num:
		addi $t4, $t4, 1		# Next integer: j++
	
		jr $ra				# Jump back to input

	loop:
		addi $t3, $t3, 1		# i++
	
		mult $t7, $t9			# ex: x*X = x^2
		mflo $t7			# ex: x^2
		
		beq $t3, $t8, get_num		# if(i == 2): get_num
	
		j loop				# Loop again

check:
	beqz $s6, set_to_a			# if($s6 == 0): set_to_a (set stack to 'a')
	bgt $t0, $t2, swap_a_c			# if('a' > 'c'): swap_a_c
	bgt $t1, $t2, swap_b_c			# if('b' > 'c'): swap_b_c

	jr $ra					# Return to Allwork

	swap_a_c:
		lw $t0, ($sp)			# Set $t0 = s[1] = a
		addi $sp, $sp, -8		# Decrement the stack: s[3] = c
	
		lw $t2, ($sp)			# Set $t2 = s[3] = c
		sw $t0, ($sp)			# Swap: s[3] = a
	
		addi $sp, $sp, 8		# Increment stack: s[1] = a
		sw $t2, ($sp)			# Swap: s[1] = c
		
		move $t0, $t2			# Swap: a = c
		move $t2, $s3			# Swap: c = A = a

		move $s7, $s0			# Swap: temp = a^2
		move $s0, $s2			# Swap: a^2 = c^2
		move $s2, $s7			# Swap: c^2 = temp = a^2

		j check				# Check again
		
	swap_b_c:
		addi $sp, $sp, -4		# Decrement the stack: s[2] = b
		lw $t1, ($sp)			# Set $t1 = s[2] = b
		
		addi $sp, $sp, -4		# Decrement the stack: s[3] = c
		lw $t2, ($sp)			# Set $t2 = s[3] = c
		
		sw $t1, ($sp)			# Swap: s[3] = b
		addi $sp, $sp, 4		# Increment the stack: s[2] = b
		sw $t2, ($sp)			# Swap: s[2] = c
		addi $sp, $sp, 4		# Increment the stack: s[1] = a

		move $t1, $t2			# Swap: b = c
		move $t2, $s4			# Swap: c = B = b
		
		move $s7, $s1			# Swap: temp = b^2
		move $s1, $s2			# Swap: b^2 = c^2
		move $s2, $s7			# Swap: c^2 = temp = b^2
		
		j check				# Check again
	
	set_to_a:
		li $s6, 1			# Checks if we've set the stack to 'a'
		addi $sp, $sp, 8		# Stack is at the location of 'a'		
		j check				# Jump to check

print:	
	add $s8, $s0, $s1	# total = $s8 = a^2 + b^2
	beq $s8, $s2, right	# if(total == c^2): right

	move $a0, $s3		# $s3 = A = a
	li $v0, 1		# Print A
	syscall	
		
	la $a0, comma		# comma (,)
	li $v0, 4		# Print a comma
	syscall
	
	move $a0, $s4		# $s4 = B = b
	li $v0, 1		# Print B
	syscall
	
	la $a0, comma		# comma (,)
	li $v0, 4		# Print a comma
	syscall
	
	move $a0, $s5		# $s5 = C = c
	li $v0, 1		# Print C
	syscall
		
	la $a0, not_right	# Print that it is not a right triangle
	li $v0, 4		# Print the message
	syscall

	addi $sp, $sp, 4	# Increment the stack: s[0] = $ra1
	lw $ra, ($sp)		# Pop the return address of function 'main' into $ra

	jr $ra			# Return to main and exit the program
	
	right:
		move $a0, $s3		# $s3 = A = a
		li $v0, 1		# Print A
		syscall	
			
		la $a0, comma		# comma (,)
		li $v0, 4		# Print a comma
		syscall
	
		move $a0, $s4		# $s4 = B = b
		li $v0, 1		# Print B
		syscall
	
		la $a0, comma		# comma (,)
		li $v0, 4		# Print a comma
		syscall
	
		move $a0, $s5		# $s5 = C = c
		li $v0, 1		# Print C
		syscall
	
		la $a0, right_tri	# It is a right triangle
		li $v0, 4		# Print the message
		syscall
			
		addi $sp, $sp, 4	# Increment the stack: s[0] = $ra1
		lw $ra, ($sp)		# Pop the return address of function 'main' into $ra
			
		jr $ra			# Return to main and exit the program

	.data
enterNum1:	.asciiz		"Enter value for side A: "
enterNum2:	.asciiz		"Enter value for side B: "
enterNum3:	.asciiz		"Enter value for side C: "
right_tri:	.asciiz		" - is a right triangle\n"
not_right:	.asciiz		" - is not a right triangle\n"
nl:		.asciiz		"\n"
comma:		.asciiz		", "