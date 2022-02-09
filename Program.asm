;
; The code given to you here implements the histogram calculation that 
; we developed in class.  In programming lab, we will add code that
; prints a number in hexadecimal to the monitor.
;
; Your assignment for this program is to combine these two pieces of 
; code to print the histogram to the monitor.
;
; If you finish your program, 
;    ** commit a working version to your repository  **
;    ** (and make a note of the repository version)! **


	.ORIG	x3000		; starting address is x3000


;
; Count the occurrences of each letter (A to Z) in an ASCII string 
; terminated by a NUL character.  Lower case and upper case should 
; be counted together, and a count also kept of all non-alphabetic 
; characters (not counting the terminal NUL).
;
; The string starts at x4000.
;
; The resulting histogram (which will NOT be initialized in advance) 
; should be stored starting at x3F00, with the non-alphabetic count 
; at x3F00, and the count for each letter in x3F01 (A) through x3F1A (Z).
;
; table of register use in this part of the code
;    R0 holds a pointer to the histogram (x3F00)
;    R1 holds a pointer to the current position in the string
;       and as the loop count during histogram initialization
;    R2 holds the current character being counted
;       and is also used to point to the histogram entry
;    R3 holds the additive inverse of ASCII '@' (xFFC0)
;    R4 holds the difference between ASCII '@' and 'Z' (xFFE6)
;    R5 holds the difference between ASCII '@' and '`' (xFFE0)
;    R6 is used as a temporary register
;

	LD R0,HIST_ADDR      	; point R0 to the start of the histogram
	
	; fill the histogram with zeroes 
	AND R6,R6,#0		; put a zero into R6
	LD R1,NUM_BINS		; initialize loop count to 27
	ADD R2,R0,#0		; copy start of histogram into R2

	; loop to fill histogram starts here
HFLOOP	STR R6,R2,#0		; write a zero into histogram
	ADD R2,R2,#1		; point to next histogram entry
	ADD R1,R1,#-1		; decrement loop count
	BRp HFLOOP		; continue until loop count reaches zero

	; initialize R1, R3, R4, and R5 from memory
	LD R3,NEG_AT		; set R3 to additive inverse of ASCII '@'
	LD R4,AT_MIN_Z		; set R4 to difference between ASCII '@' and 'Z'
	LD R5,AT_MIN_BQ		; set R5 to difference between ASCII '@' and '`'
	LD R1,STR_START		; point R1 to start of string

	; the counting loop starts here
COUNTLOOP
	LDR R2,R1,#0		; read the next character from the string (2 has character, 1 is pointer)
	BRz PRINT_HIST		; found the end of the string

	ADD R2,R2,R3		; subtract '@' from the character
	BRp AT_LEAST_A		; branch if > '@', i.e., >= 'A'
NON_ALPHA
	LDR R6,R0,#0		; load the non-alpha count
	ADD R6,R6,#1		; add one to it
	STR R6,R0,#0		; store the new non-alpha count 
	BRnzp GET_NEXT		; branch to end of conditional structure
AT_LEAST_A
	ADD R6,R2,R4		; compare with 'Z'
	BRp MORE_THAN_Z         ; branch if > 'Z'

; note that we no longer need the current character
; so we can reuse R2 for the pointer to the correct
; histogram entry for incrementing
ALPHA	ADD R2,R2,R0		; point to correct histogram entry
	LDR R6,R2,#0		; load the count
	ADD R6,R6,#1		; add one to it
	STR R6,R2,#0		; store the new count
	BRnzp GET_NEXT		; branch to end of conditional structure

; subtracting as below yields the original character minus '`'
MORE_THAN_Z
	ADD R2,R2,R5		; subtract '`' - '@' from the character
	BRnz NON_ALPHA		; if <= '`', i.e., < 'a', go increment non-alpha
	ADD R6,R2,R4		; compare with 'z'
	BRnz ALPHA		; if <= 'z', go increment alpha count
	BRnzp NON_ALPHA		; otherwise, go increment non-alpha

GET_NEXT
	ADD R1,R1,#1		; point to next character in string
	BRnzp COUNTLOOP		; go to start of counting loop

;partners: dylanjb5, aadim2
;This code prints out the histogram to the monitor. The code above stores data in memory
; starting at the histogram address for each letter and non-alpha character, then once the
; string is fully cycled through, it branches to my code, 'PRINT_HIST'. This code first
; zeros all used registers, and loads the value at the address of the histogram pointer into
; a register. The corresponding letter or character is printed out first using an ASCII
; pointer register, then a space, then the value loaded into R3 from the memory histogram.
; This value is printed as a 4 digit hexadecimal via the Lab code. This segment loops
; through 4 digits using a counter, each time shifting the digit, testing R3 for the MSB to
; add either 1 or 0, then shifting R3 left and incrementing the bit counter. If the bit
; counter is 4, the digit is tested to be higher than 9, in which case it is added the ASCII
; distance to 'A'. The result is then printed to the monitor, and the digit counter is
; incremented. Once the code is done printing the row, a newline is printed, R5,6 is
; incremented and R4 decremented. This code repeats until 27 iterations occur per the
; NUM_BINS counter. 


PRINT_HIST

			AND R4, R4, #0; zero out R4
			AND R3, R3, #0; zero out R3
			AND R0, R0, #0; zero out R0
			LD R4, NUM_BINS ; Load the number of bins to R4

			
			AND R5, R5, #0;	zero out R5
			LD R5, SIXTYFOUR ; Load the decimal value of 64, the distance in ASCII to @
			
			AND R6, R6, #0; zero out R6
			LD R6, HIST_ADDR ;load the starting address of the histogram to R6


NEXTENTRY	
			
			LDR R3, R6, #0; R3 gets value at the address of pointer
			ADD R0, R5, #0; R0 gets the value of R5, the ASCII pointer
			TRAP x21; OUT
			LD R0, SPACE ; Load the ASCII value of a space to R0
			TRAP x21; OUT
			BRnzp PRINTRTHREE ; branch to code that prints 4digit hexadecimal of value in R3

DONEPRINT	LD R0, NEWLINE ; Load the ASCII value of a newline to R0
			TRAP x21; OUT
			ADD R6, R6, #1; Increment R6
			ADD R5, R5, #1; Increment R6
			ADD R4, R4, #-1; Decrement R4
			
			BRp NEXTENTRY ; Branch to next entry if the number of bins left is positive
			BRnzp DONE ; If it isnt, move to halt the program


PRINTRTHREE
			AND R2, R2, #0; zero out R2
			ADD R2, R2, #4; Add 4 to R2 for the number of digits


PRINTDIGIT	BRnz DONEPRINT ; if 4 digits have been printed, branch to DONEPRINT
			AND R1, R1, #0; zero out R1
			AND R0, R0, #0; zero out R0
BIT			ADD R1, R1, #-3; Test if R1, the bit counter, is 3 or less
			BRp FOURBIT ; if not, move to FOURBIT
			ADD R1, R1, #3; reverse test subtraction
			ADD R0, R0, R0; shift digit left
			ADD R3, R3, #0; test if R3 is less than 0
			BRzp POSITIVE ; if R3 is positive, the MSB is 0 and branch to positive
			ADD R0, R0, #1; if R3 is negative, the MSB is 1 so add 1 to digit
POSITIVE	ADD R3, R3, R3; shift R3 left
			ADD R1, R1, #1; increment bit counter
			BRnzp BIT	; branch back to BIT
FOURBIT		LD R1, FOURTYEIGHT ; R1 gets the value of 48, the ASCII distance to '0'
			ADD R0, R0, #-9; test if digit is less than or equal to 9
			BRnz LESSNINE ; if it is, Branch to LESSNINE
			ADD R0, R0, #7; if it isnt, add ASCII distance to 'A'
LESSNINE	ADD R0, R0, #9; reverse testing subtraction
			ADD R0, R1, R0; Add 48 to digit
			TRAP x21; OUT
			ADD R2, R2, #-1; decrement digit counter
			BRnzp PRINTDIGIT ;

DONE	HALT			; done


; the data needed by the program
NUM_BINS	.FILL #27	; 27 loop iterations 
NEG_AT		.FILL xFFC0	; the additive inverse of ASCII '@' (-64)
AT_MIN_Z	.FILL xFFE6	; the difference between ASCII '@' and 'Z'(26)
AT_MIN_BQ	.FILL xFFE0	; the difference between ASCII '@' and '`'(32)
HIST_ADDR	.FILL x3F00     ; histogram starting address
STR_START	.FILL x4000	; string starting address
FOURTYEIGHT	.FILL #48; ASCII distance to '0'
SIXTYFOUR	.FILL #64; ASCII distance to @
SPACE		.FILL #32; SPACE character
NEWLINE		.FILL x0A; Newline Character

; for testing, you can use the lines below to include the string in this
; program...
; STR_START	.FILL STRING	; string starting address
; STRING		.STRINGZ "This is a test of the counting frequency code.  AbCd...WxYz."



	; the directive below tells the assembler that the program is done
	; (so do not write any code below it!)

	.END
