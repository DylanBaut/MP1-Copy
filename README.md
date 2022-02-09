# MP1-Copy
Copy of MP1 project created in ECE 220

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
