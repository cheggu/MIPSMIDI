.data
	filename:	.asciiz "extracredit/songofstorms.mid"		#name of file to read
	buffer:		.space 512000			#buffer for future file reading
	curChar:	.asciiz ""			#iterator
	startBuffer:	.space 32			#buffer for our start values we get from the txt file
	keyBuffer:	.space 32			#buffer for our key values
	durationBuffer:	.space 32			#buffer for our duration values
	volumeBuffer:	.space 32			#buffer for our volume values		
	
.text	
	j	pass
	checkDigits:
		bne	$a0, '0', check1
		j	endCheckDigits
		check1:
		bne	$a0, '1', check2
		j	endCheckDigits
		check2:
		bne	$a0, '2', check3
		j	endCheckDigits
		check3:
		bne	$a0, '3', check4
		j	endCheckDigits
		check4:
		bne	$a0, '4', check5
		j	endCheckDigits
		check5:
		bne	$a0, '5', check6
		j	endCheckDigits
		check6:
		bne	$a0, '6', check7
		j	endCheckDigits
		check7:
		bne	$a0, '7', check8
		j	endCheckDigits
		check8:
		bne	$a0, '8', check9
		j	endCheckDigits
		check9:
		bne	$a0, '9', concatinate	
				
		endCheckDigits:
		jr $ra
	pass:

	#OPEN FILE FOR READING
	li	$v0, 13					#load open file syscall code
	li	$a1, 0					#set mode to read
	la	$a0, filename				#set filename
	li	$a2, 0					#unsued flag
	syscall
	
	#SAVE FILE DESCRIPTOR
	move	$s0, $v0				#move the file handle to another register
	
	#READ FROM FILE
	li	$v0, 14					#load read file syscall code
	move	$a0, $s0
	la	$a1, buffer				#buffer location
	li	$a2, 512000				#size of the buffer
	syscall
	
	la	$s1, buffer				#save buffer
	
	#CLOSE FILE
	li	$v0, 16       				# system call for close file
	move	$a0, $s6      				# file descriptor to close
	syscall            				# close file
	
	#READING CHARS
	la 	$t0, buffer#($s1)			#load string into temp
	addi	$s0, $zero, 0				#set iterator to 0
	li	$v0, 1#11				#load print int syscall code
	
	addi	$s3, $zero, 0				#key
	addi	$s4, $zero, 0				#duration
	addi	$s5, $zero, 0				#start time
	addi	$s0, $s0, 0				#last time
	addi	$s6, $zero, 0				#volume
	
	
	loop0:
	lb	$a0, 0($t0)				#load the char into a0 for printing
	
	#CHECK FOR DATA HEADERS
	checkStart:	
		bne	$a0, 'S', checkKey		#check for 'S'
		
		addi	$t0,$t0, 1			#iterator++
		lb	$a0, 0($t0)			#load the next byte
		bne	$a0, 't', checkKey		#check for 't'
		
		addi	$t0,$t0, 1			#iterator++
		lb	$a0, 0($t0)			#load the next byte
		bne	$a0, 'a', checkKey		#check for 'a'
		
		addi	$t0,$t0, 8			#move to value
		lb	$a0, 0($t0)			#load the first number
		sub	$a0, $a0, 48			#convert from char to int
		#syscall
		
		#GRAB ANY VALID DATA
		
		la	$a1, startBuffer		#copy the array
		addi	$t7, $zero, 0			#create temp counter
		addi	$s7, $zero, 's'			#set function variable to start 
		
		appendToBuffer:
			sb	$a0, -2($a1)		#store byte in array
			addi	$t0, $t0, 1		#iterate through array counter
			addi	$t7, $t7, 1		#i++
			lb	$a0, 0($t0)		#load the next number	
			jal	checkDigits
			sub	$a0, $a0, 48		#convert from char to int
						
			sb	$a0, 2($a1)		#store byte in array
			addi	$t0,$t0, 1		#iterate
			addi	$t7, $t7, 1		#i++			
			lb	$a0, 0($t0)		#load the next number			
			jal	checkDigits		#if the character isn't what we want, skip ahead to concatination		
			sub	$a0, $a0, 48		#convert from char to int
			
			sb	$a0, 6($a1)		#store byte in array
			addi	$t0,$t0, 1		#iterate
			addi	$t7, $t7, 1		#i++			
			lb	$a0, 0($t0)		#load the next number			
			jal	checkDigits		#if the character isn't what we want, skip ahead to concatination	
			sub	$a0, $a0, 48		#convert from char to int
			
			sb	$a0, 10($a1)		#store byte in array
			addi	$t0,$t0, 1		#iterate
			addi	$t7, $t7, 1		#i++			
			lb	$a0, 0($t0)		#load the next number
			jal	checkDigits		#if the character isn't what we want, skip ahead to concatination			
			sub	$a0, $a0, 48		#convert from char to int
			
			sb	$a0, 14($a1)		#store byte in array
			addi	$t0,$t0, 1		#iterate
			addi	$t7, $t7, 1		#i++			
			lb	$a0, 0($t0)		#load the next number
			jal	checkDigits		#if the character isn't what we want, skip ahead to concatination		
			sub	$a0, $a0, 48		#convert from char to int
			

			
			#CONCATiNATE INTS FROM ARRAY INTO ONE INT
			concatinate:
				beq	$t7, 1, length1
				beq	$t7, 2, length2
				beq	$t7, 3, length3
				beq	$t7, 4, length4
				beq	$t7, 5, length5
				beq	$t7, 6, length6
			
			length1:
				lb	$t2, -2($a1)		#copy element {x}
				add	$s2, $zero, $t2		#ones place
				
				j endConcatenate
			length2:
				lb	$t2, 2($a1)		#copy 2nd element {0, x}
				add	$s2, $zero, $t2		#ones place
				
				addi	$t3, $zero, 10		#create 10 variable to multiply to 10th place
				lb	$t2, -2($a1)		#copy 1st element {x, 0}
				mult	$t2, $t3		#10s place
				mflo 	$t3
				add	$s2, $s2, $t3
				
				j endConcatenate
			length3:
				lb	$t2, 6($a1)		#copy 3rd element {0, 0, x}
				add	$s2, $zero, $t2		#ones place
				
				addi	$t3, $zero, 10		#create variable to multiply to 10th place
				lb	$t2, 2($a1)		#copy 2nd element {0, x, 0}
				mult	$t2, $t3		#10s place
				mflo 	$t3			#get result
				add	$s2, $s2, $t3		#add to total (10 + 1)
				
				addi	$t3, $zero, 100		#modify variable to multiply to 100th place
				lb	$t2, -2($a1)		#save 1st element from array {x, 0, 0}
				mult	$t2, $t3		#100s place
				mflo 	$t3
				add	$s2, $s2, $t3
				
				j endConcatenate
			length4:
				lb	$t2, 10($a1)		#copy 4th element {0, 0, 0, x}
				add	$s2, $zero, $t2		#ones place
				
				addi	$t3, $zero, 10		#create variable to multiply to 10th place
				lb	$t2, 6($a1)		#copy 3rd element {0, 0, x, 0}
				mult	$t2, $t3		#10s place
				mflo 	$t3
				add	$s2, $s2, $t3
				
				addi	$t3, $zero, 100		#modify variable to multiply to 100th place
				lb	$t2, 2($a1)		#save 2nd element from array {0, x, 0, 0}
				mult	$t2, $t3		#100s place
				mflo 	$t3
				add	$s2, $s2, $t3
				
				addi	$t3, $zero, 1000	#modify variable to multiply to 1000th place
				lb	$t2, -2($a1)		#save 1st element from array {x, 0, 0, 0}
				mult	$t2, $t3		#1000s place
				mflo 	$t3
				add	$s2, $s2, $t3				
				
				j endConcatenate
			length5:
				lb	$t2, 14($a1)		#copy 5th element {0, 0, 0, 0, x}
				add	$s2, $zero, $t2		#ones place
				
				addi	$t3, $zero, 10		#create variable to multiply to 10th place
				lb	$t2, 10($a1)		#copy 4th element {0, 0, 0, x, 0}
				mult	$t2, $t3		#10s place
				mflo 	$t3
				add	$s2, $s2, $t3
				
				addi	$t3, $zero, 100		#modify variable to multiply to 100th place
				lb	$t2, 6($a1)		#save 3rd element from array {0, 0, x, 0, 0}
				mult	$t2, $t3		#100s place
				mflo 	$t3
				add	$s2, $s2, $t3
				
				addi	$t3, $zero, 1000	#modify variable to multiply to 1000th place
				lb	$t2, 2($a1)		#save 2nd element from array {0, x, 0, 0, 0}
				mult	$t2, $t3		#1000s place
				mflo 	$t3
				add	$s2, $s2, $t3				

				addi	$t3, $zero, 10000	#modify variable to multiply to 1000th place
				lb	$t2, -2($a1)		#save 1st element from array {x, 0, 0, 0, 0}
				mult	$t2, $t3		#10000s place
				mflo 	$t3
				add	$s2, $s2, $t3					
				
				j endConcatenate
			length6:
				lb	$t2, 18($a1)		#copy 6th element {0, 0, 0, 0, 0, x}
				add	$s2, $zero, $t2		#ones place
				
				addi	$t3, $zero, 10		#create variable to multiply to 10th place
				lb	$t2, 14($a1)		#copy 5th element {0, 0, 0, 0, x, 0}
				mult	$t2, $t3		#10s place
				mflo 	$t3
				add	$s2, $s2, $t3
				
				addi	$t3, $zero, 100		#modify variable to multiply to 100th place
				lb	$t2, 10($a1)		#save 4th element from array {0, 0, 0, x, 0, 0}
				mult	$t2, $t3		#100s place
				mflo 	$t3
				add	$s2, $s2, $t3
				
				addi	$t3, $zero, 1000	#modify variable to multiply to 1000th place
				lb	$t2, 6($a1)		#save 3rd element from array {0, 0, x, 0, 0, 0}
				mult	$t2, $t3		#1000s place
				mflo 	$t3
				add	$s2, $s2, $t3				

				addi	$t3, $zero, 10000	#modify variable to multiply to 1000th place
				lb	$t2, 2($a1)		#save 2nd element from array {0, x, 0, 0, 0, 0}
				mult	$t2, $t3		#10000s place
				mflo 	$t3
				add	$s2, $s2, $t3	
				
				addi	$t3, $zero, 100000	#modify variable to multiply to 1000th place
				lb	$t2, -2($a1)		#save 1st element from array {x, 0, 0, 0, 0, 0}
				mult	$t2, $t3		#100000s place
				mflo 	$t3
				add	$s2, $s2, $t3													
				
				j endConcatenate
						
			endConcatenate:	
			addi	$a0, $zero, 1			#in case the num we read is zero, we set a0 to 1 so the whole loop doesn't end					
			
			beq	$s7, 's', saveStart
			beq	$s7, 'k', saveKey
			beq	$s7, 'd', saveDur
			beq	$s7, 'v', saveVol
			saveStart:
				move	$s5, $s2			#move the found start value into s5
				j	checkKey
			saveKey:
				move	$s3, $s2			#move the found key value into s3
				j	checkDur
			saveDur:
				move	$s4, $s2			#move the found duration value into s4
				j	checkVol
			saveVol:
				move	$s6, $s2			#move the found volume value into s6
				j	stopCheck																		
	
	checkKey:
		addi	$s7, $zero, 0 			#set function variable to 0 (counter)
		bne	$a0, 'K', checkDur		#check for 'K'
		
		addi	$t0,$t0, 1			#iterator++
		lb	$a0, 0($t0)			#load the next byte
		bne	$a0, 'e', checkDur		#check for 'e'
		
		addi	$t0,$t0, 1			#iterator++
		lb	$a0, 0($t0)			#load the next byte
		bne	$a0, 'y', checkDur		#check for 'y'
		
		addi	$t0,$t0, 2			#move to value
		lb	$a0, 0($t0)			#load the first number
		sub	$a0, $a0, 48			#convert from char to int
		#syscall
		
				#GRAB ANY VALID DATA
		la	$a1, keyBuffer		#copy the array
		addi	$t7, $zero, 0			#create temp counter
		addi	$s7, $zero, 'k' 
		j	appendToBuffer
		
		addi	$a0, $zero, 1			#in case the num we read is zero, we set a0 to 1 so the whole loop doesn't end
		
		
		
	checkDur:
		addi	$s7, $zero, 0 			#set function variable to 0	
		bne	$a0, 'D', checkVol		#check for 'D'
		
		addi	$t0,$t0, 1			#iterator++
		lb	$a0, 0($t0)			#load the next byte
		bne	$a0, 'u', checkVol		#check for 'u'
		
		addi	$t0,$t0, 1			#iterator++
		lb	$a0, 0($t0)			#load the next byte
		bne	$a0, 'r', checkVol		#check for 'r'
		
		addi	$t0,$t0, 7			#move to value
		lb	$a0, 0($t0)			#load the first number
		sub	$a0, $a0, 48			#convert from char to int
		#syscall
		
		#GRAB ANY VALID DATA
		la	$a1, durationBuffer		#copy the array
		addi	$t7, $zero, 0			#create temp counter
		addi	$s7, $zero, 'd' 
		j	appendToBuffer
		
		addi	$a0, $zero, 1			#in case the num we read is zero, we set a0 to 1 so the whole loop doesn't end		

		
		
	checkVol:
		addi	$s7, $zero, 0 			#set function variable to 0
		bne	$a0, 'V', stopCheck		#check for 'V'
		
		addi	$t0,$t0, 1			#iterator++
		lb	$a0, 0($t0)			#load the next byte
		bne	$a0, 'e', stopCheck		#check for 'e'
		
		addi	$t0,$t0, 1			#iterator++
		lb	$a0, 0($t0)			#load the next byte
		bne	$a0, 'l', stopCheck		#check for 'l'
		
		addi	$t0,$t0, 7			#move to value
		lb	$a0, 0($t0)			#load the first number
		sub	$a0, $a0, 48			#convert from char to int
		#syscall
		
		#GRAB ANY VALID DATA
		la	$a1, volumeBuffer		#copy the array
		addi	$t7, $zero, 0			#create temp counter
		addi	$s7, $zero, 'v' 		#set function variable to v
		j	appendToBuffer
		
		addi	$a0, $zero, 1			#in case the num we read is zero, we set a0 to 1 so the whole loop doesn't end		
	
	stopCheck:					#label we branch to if we don't find any good chars
	
	addi	$t0,$t0, 1				#iterate + i
	
	#PLAY CURRENT NOTE
	
	li	$v0, 1

	bnez	$s3,goodKey
	j	skipNote
	goodKey:
		#move	$a0, $s3
		#syscall
		bnez	$s4, goodDur
		j	skipNote
	goodDur:
		#move	$a0, $s4
		#syscall
		bnez	$s6, goodVol
		j	skipNote
	goodVol:
		#move	$a0, $s6
		#syscall
		
		sub	$s0, $s5,$s0			#subtract the current time from the last time to get the sleep time
		
		li	$v0, 32					#set syscall to sleep
		
		move	$a0, $s0
		syscall						#sleep
		
		li	$v0, 31
		li	$a2, 0					#set instrument to piano
	
		move	$a0, $s3				#get key
		move	$a1, $s4				#get duration
		move	$a3, $s6				#get volume
		syscall						#play note
		
		

		addi	$a0, $zero, 1
		move 	$s0, $s5				#lastTime = curTime
		
		addi	$s3, $zero, 0				#key
		addi	$s4, $zero, 0				#duration
		addi	$s5, $zero, 0				#start time
		addi	$s6, $zero, 0				#volume		
		
	skipNote:
	
	bnez	$a0, loop0				#loop if the char is not null terminator
	
	li	$v0, 10
	syscall
