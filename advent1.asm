;The newly-improved calibration document consists of lines of text; each line originally contained a specific calibration value that the Elves now need to recover. On each line, the calibration value can be found by combining the first digit and the last digit (in that order) to form a single two-digit number.

;For example:

;1abc2
;pqr3stu8vwx
;a1b2c3d4e5f
;treb7uchet

;In this example, the calibration values of these four lines are 12, 38, 15, and 77. Adding these together produces 142.

;Consider your entire calibration document. What is the sum of all of the calibration values?

section .data
    infile  db '/home/chloge/Desktop/advent_in1.txt', 0 ; path to calibration values
    bufsize equ 21182
    buf times bufsize db 0

section .text
    global _start

_start:
    _read:
    ; syscall to open infile
    mov rax, 2 
    lea rdi, infile
    ;xor rsi, rsi (unneccesary because rsi starts at 0)
    syscall

    ; syscall to read from infile, 
    mov rdi, rax
    xor rax, rax
    lea rsi, buf ; buffer addr
    mov rdx, bufsize ; size of buffer
    syscall 
    
    ; At this point, rsi contains a ptr to the address of the file data
    ; It can be read in intervals of 4 for use

    ; adds the first and last digit between each the newline
    mov r10, 21172 ; length of file in bytes + 1
    mov rdi, rsi
    dec rdi
    xor rax, rax
    _newline:
        cmp r10, 21172 ; skip addition on first iteration
        je _handling
        test r9, r9
        jz _skip8
        movzx rcx, r8b ; int concat
        imul rcx, 10     
        movzx rdx, r9b
        add rcx, rdx
        jmp _endskip ; handling in case there is only one number in the str

        _skip8:
        movzx rcx, r8b ; int concat
        imul rcx, 10     
        movzx rdx, r8b
        add rcx, rdx

        _endskip:
        add rax, rcx

        _handling:
        xor rdx, rdx ; reset rdx, rbp, and r8
        xor r8, r8
        xor r9, r9
        jmp _validatebyte

        _first: ; Handler for first digit
            mov r8, rbx

        _validatebyte:
        dec r10
        inc rdi
        test r10, r10 ; jump to print if out of bytes to read
        jz _inttostr
        mov bl, [rdi]
        cmp bl, 0xa ; test if newline, if so jump to newline
        je _newline
        cmp bl, 47 ; test if digit, if not jump to start
        jg _greater
            _greater:
                cmp bl, 58 ; ^
                jl _parse
        jmp _validatebyte

        ; bl contains a valid byte
        ; rcx contains the current byte in the file
        ; rdi contains the ptr to the full string we're working with

        ; r8 will contain first digit
        ; r9 will contain current digit
        ; rax will contain sum

        _parse:
            sub rbx, 48
            test r8, r8
            jz _first ; jump to first if there isn't one
            mov r9, rbx
            jmp _validatebyte 

        
    
    _inttostr:
        ; takes in rax as the number to convert
        add rsi, 21182 
        mov rcx, 10
        _loop:
            cmp rax, 10
            jl _inttstrend ; checks if only a single digit is left
            xor dx, dx ; ensures dx is empty for remainder
            div rbx
            add rdx, 48 ; ascii int conversion magic
            mov [rsi], rdx
            inc r8 ; r8 will be used as the str len
            inc rsi
            jmp _loop
        _inttstrend:
            add rax, 48 ; same deal as before, without the division
            mov [rsi], rax
            inc rsi
            inc r8
            sub rsi, r8 ; heads back to the beginning of the buffer
            mov rax, rsi
            jmp _print

    
    _print:
        ; syscall to print
        mov rsi, rax 
        mov rax, 1
        mov rdi, 1
        mov rdx, r8
        syscall

    _exit:
    mov rax, 60 ; syscall to exit
    xor rdi, rdi
    syscall
