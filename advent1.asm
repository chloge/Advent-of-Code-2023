;The newly-improved calibration document consists of lines of text; each line originally contained a specific calibration value that the Elves now need to recover. On each line, the calibration value can be found by combining the first digit and the last digit (in that order) to form a single two-digit number.

;For example:

;1abc2
;pqr3stu8vwx
;a1b2c3d4e5f
;treb7uchet

;In this example, the calibration values of these four lines are 12, 38, 15, and 77. Adding these together produces 142.

;Consider your entire calibration document. What is the sum of all of the calibration values?

section .data
    infile  db '/home/chloge/Desktop/advent_in1.txt', 0 ; Path to calibration values
    bufsize equ 21182
    buf times bufsize db 0

section .text
    global _start

_start:
    _read:
    ; Syscall to open infile
    mov rax, 2 
    lea rdi, infile
    ;xor rsi, rsi (unneccesary because rsi starts at 0)
    syscall

    ; Syscall to read from infile, 
    mov rdi, rax ; File descriptor from open
    xor rax, rax ; Set to 0 for read syscall
    lea rsi, buf ; Buffer addr
    mov rdx, bufsize ; Size of buffer addr
    syscall 
    
    ; At this point, rsi contains a ptr to the address of the file data
    ; It can be read in intervals of 4 for use

    ; Adds the first and last digit between each the newline
    mov r10, 21172 ; Length of file in bytes + 1
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
        jmp _endskip

        _skip8:
        movzx rcx, r8b ; int concat
        imul rcx, 10     
        movzx rdx, r8b
        add rcx, rdx

        _endskip:
        add rax, rcx

        _handling:
        xor rdx, rdx ; Reset rdx, rbp, and r8
        xor r8, r8
        xor r9, r9
        jmp _validatebyte

        _first: ; Handler for first digit
            mov r8, rbx

        _validatebyte:
        dec r10
        inc rdi
        test r10, r10 ; Jump to print if out of bytes to read
        jz _exit
        mov bl, [rdi]
        cmp bl, 0xa ; Test if newline, if so jump to newline
        je _newline
        cmp bl, 47 ; Test if digit, if not jump to start
        jg _greater
            _greater:
                cmp bl, 58 ; ^
                jl _parse
        jmp _validatebyte

        ; At this point:
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


    _exit:
    mov rax, 60
    xor rdi, rdi
    syscall


