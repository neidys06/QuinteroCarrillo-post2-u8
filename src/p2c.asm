; p2c.asm - MUL/DIV: mini calculadora de digitos 0-9
; Compilar: ..\nasm -f bin p2c.asm -o ..\bin\p2c.com

ORG 100h

jmp start

pA     db 'Primer operando (0-9): $'
nl1    db 13,10,'Segundo operando (0-9): $'
nl2    db 13,10,'Operacion (* o /): $'
nl3    db 13,10,'Resultado: $'
nl4    db 13,10,'Division por cero.$'
nl5    db 13,10,'$'

start:
    mov ah, 09h
    mov dx, pA
    int 21h
    mov ah, 01h
    int 21h
    sub al, 30h
    mov bl, al

    mov ah, 09h
    mov dx, nl1
    int 21h
    mov ah, 01h
    int 21h
    sub al, 30h
    mov cl, al

    mov ah, 09h
    mov dx, nl2
    int 21h
    mov ah, 01h
    int 21h
    mov bh, al

    mov ah, 09h
    mov dx, nl3
    int 21h

    cmp bh, 2Ah
    je op_mul
    cmp bh, 2Fh
    je op_div
    jmp op_fin

op_mul:
    mov al, bl
    xor ah, ah
    mul cl
    call imprimirAX
    jmp op_fin

op_div:
    cmp cl, 0
    je div_cero
    xor ah, ah
    mov al, bl
    div cl
    xor ah, ah
    call imprimirAX
    jmp op_fin

div_cero:
    mov ah, 09h
    mov dx, nl4
    int 21h

op_fin:
    mov ah, 09h
    mov dx, nl5
    int 21h
    mov ah, 4Ch
    xor al, al
    int 21h

imprimirAX:
    mov bx, 10
    xor cx, cx

imp_divide:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz imp_divide

imp_pop:
    pop dx
    add dl, 30h
    mov ah, 02h
    int 21h
    loop imp_pop
    ret