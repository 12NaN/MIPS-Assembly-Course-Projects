	.text
	.globl main

main:				# Loops until the user inputs a zero.
	la $a0, mess 		# Loads the address of mess into the argument register.
	li $v0, 4 		# System call code to print a string.
	syscall			# Print mess.
	
	li $v0, 5 		# System call code that reads the integer.
	syscall			# Reads the integer that the user had inputted.

	bnez $v0, increment 	# Branch if the integer doesn't equal zero.
	beqz $v0, results	# Branch if the integer equals zero.

increment:
	add $t0, $t0, 1		# Increment the integer counter by 1.
	add $t1, $t1, $v0	# Add the recently inputted integer to the current sum.

	j main			# Return to main.

calc_average:			# Calculate the average.
	div $t1, $t0		# Divide the sum in register $t1 by $t0.
	mflo $t2		# Store the quotient in $t2.
	mfhi $t3		# Store the remainder in $t3.

	li $t4, 1000		# Stores the immediate value 1000 in $t4.
	
	mult $t4, $t3		# Multiply the remainder by 1000.
	
	mflo $t5		# Stores the product in $t5.
	
	div $t5, $t5, $t0	# Divide $t5 by the number of integers 
				# and store the result in $t5.
	
	jr $ra			# Jump to the value in the return address.

results:			# Print the results.
	la $a0, sum_mess	# Loads the address of sum_mess into the argument register.
	li $v0, 4		# System call code to print a string.
	syscall			# Print sum_mess.
	
	move $a0, $t1		# Moves the sum in $t1 into the argument register.
	li $v0, 1		# System call code to print an integer.
	syscall			# Prints the sum.

	la $a0, nl 		# Loads the address of nl into the argument register.
	li $v0, 4		# System call code to print a string.
	syscall			# Print nl.
	
	move $a0, $t0		# Moves the number of integers in $t0 into the argument register.
	li $v0, 1		# System call code to print an integer.
	syscall			# Prints the number of integers that were inputted.

	la $a0, num_entered_mess # Loads the address of num_entered_mess into the argument register.
	li $v0, 4		# System call code to print a string.
	syscall			# Prints num_entered_mess.
	
	la $a0, average_mess	# Loads the address of average_mess into the argument register.
	li $v0, 4		# System call code to print a string.
	syscall			# Prints average_mess.
	
	jal calc_average 	# Jump and link to calc_average.
	
	move $a0, $t2		# Move the value of $t2 into the argument register.
	li $v0, 1		# System call code to print an integer.
	syscall			# Print the integer.
	
	la $a0, decimal		# Loads the address of decimal into the argument register.
	li $v0, 4		# System call code to print a string.
	syscall			# Prints decimal.
	
	move $a0, $t5		# Move the value of $t5 (the decimal value) to the argument register.
	li $v0,	1		# System call code to print an integer.
	syscall			# Print the decimal value.

	j exit			# Jump to exit.

exit:	
	la $a0, complete 	# Loads the address of complete into the argument register.
	li $v0, 4		# System call code to print a string.
	syscall			# Prints complete.
	
	li $v0, 10		# System call code to exit the program.
	syscall			# Exit the program.

	.data
mess: 			.asciiz 	"Enter a Number(0 to exit): "
sum_mess: 		.asciiz 	"\nThe sum is: "
num_entered_mess:	.asciiz 	" numbers were entered\n"
nl: 			.asciiz 	"\n"
average_mess: 		.asciiz 	"\nThe average is: "
decimal: 		.asciiz 	"."
complete: 		.asciiz 	"\nProgram Exited"
	
