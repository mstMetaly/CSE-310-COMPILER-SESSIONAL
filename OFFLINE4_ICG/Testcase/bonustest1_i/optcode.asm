.MODEL SMALL
.STACK 1000H
.Data
	number DB "00000$"
.CODE
foo PROC
	PUSH BP
	MOV BP, SP
	MOV AX, [BP+4]       ; Line 2
	MOV DX, AX
	MOV AX, [BP+6]       ; Line 2
	ADD AX, DX
	PUSH AX
	MOV AX, 5       ; Line 2
	MOV DX, AX
	POP AX       ; Line 2
	CMP AX, DX
	JLE L1
	JMP L3
L1:
	MOV AX, 7       ; Line 3
	JMP L5
L2:
L3:
	MOV AX, 2       ; Line 5
	MOV DX, AX
	MOV AX, [BP+6]       ; Line 5
	SUB AX, DX
	PUSH AX
	POP AX       ; Line 5
	PUSH AX
	MOV AX, 1       ; Line 5
	MOV DX, AX
	MOV AX, [BP+4]       ; Line 5
	SUB AX, DX
	PUSH AX
	POP AX       ; Line 5
	PUSH AX
	CALL foo
	PUSH AX
	MOV AX, 1       ; Line 5
	MOV DX, AX
	MOV AX, [BP+6]       ; Line 5
	SUB AX, DX
	PUSH AX
	POP AX       ; Line 5
	PUSH AX
	MOV AX, 2       ; Line 5
	MOV DX, AX
	MOV AX, [BP+4]       ; Line 5
	SUB AX, DX
	PUSH AX
	POP AX       ; Line 5
	PUSH AX
	CALL foo
	PUSH AX
	POP AX       ; Line 5
	MOV CX, AX
	MOV AX, 2       ; Line 5
	CWD
	MUL CX
	PUSH AX
	POP AX       ; Line 5
	MOV DX, AX
	POP AX       ; Line 5
	ADD AX, DX
	PUSH AX
	POP AX       ; Line 5
	JMP L5
L4:
L5:
	POP BP
	RET 4
foo ENDP
main PROC
	MOV AX, @DATA
	MOV DS, AX
	PUSH BP
	MOV BP, SP
	SUB SP, 2
	SUB SP, 2
	SUB SP, 2
L6:
	MOV AX, 7       ; Line 11
	MOV [BP-2], AX
L7:
	MOV AX, 3       ; Line 12
	MOV [BP-4], AX
L8:
	MOV AX, [BP-2]       ; Line 14
	PUSH AX
	MOV AX, [BP-4]       ; Line 14
	PUSH AX
	CALL foo
	PUSH AX
	POP AX       ; Line 14
	MOV [BP-6], AX
L9:
	MOV AX, [BP-6]       ; Line 15
	CALL print_output
	CALL new_line
L10:
	MOV AX, 0       ; Line 17
	JMP L12
L11:
L12:
	ADD SP, 6
	POP BP
	MOV AX,4CH
	INT 21H
main ENDP
;-------------------------------
;         print library         
;-------------------------------
;------------------------------- 
new_line proc
    push ax
    push dx
    mov ah,2
    mov dl,0Dh
    int 21h
    mov ah,2
    mov dl,0Ah
    int 21h
    pop dx
    pop ax
    ret
    new_line endp
print_output proc  ;print what is in ax
    push ax
    push bx
    push cx
    push dx
    push si
    lea si,number
    mov bx,10
    add si,4
    cmp ax,0
    jnge negate
    print:
    xor dx,dx
    div bx
    mov [si],dl
    add [si],'0'
    dec si
    cmp ax,0
    jne print
    inc si
    lea dx,si
    mov ah,9
    int 21h
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
    negate:
    push ax
    mov ah,2
    mov dl,'-'
    int 21h
    pop ax
    neg ax
    jmp print
    print_output endp
END main
