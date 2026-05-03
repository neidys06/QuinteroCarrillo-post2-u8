; p2a.asm - ADC/SBB: aritmetica de precision multiple 32 bits
; Compilar: ..\nasm -f bin p2a.asm -o ..\bin\p2a.com
; En modo real 16 bits, numeros de 32 bits se manejan en pares DX:AX
; ADD para partes bajas, ADC propaga el acarreo CF a las partes altas
; SBB propaga el prestamo (borrow) CF de SUB a las partes altas

ORG 100h

section .data
    ; A = 0x0001FFFF = 131071 decimal
    aLo     dw 0FFFFh       ; parte baja de A
    aHi     dw 0001h        ; parte alta de A
    ; B = 0x00010001 = 65537 decimal
    bLo     dw 0001h        ; parte baja de B
    bHi     dw 0001h        ; parte alta de B
    ; Buffers resultado
    resLo   dw 0
    resHi   dw 0
    ; Mensajes
    msgSuma db "Suma OK: 0003:0000$"
    msgRest db "Resta OK: 0001:FFFF$"
    msgErr  db "Error.$"
    crlf    db 0Dh,0Ah,"$"

section .text
start:
    ; ==========================================
    ; SUMA: A + B = 0x0001FFFF + 0x00010001
    ;       Esperado: 0x00030000 (DX=0003h, AX=0000h)
    ; ==========================================
    mov ax, [aLo]       ; AX = FFFFh (parte baja de A)
    mov dx, [aHi]       ; DX = 0001h (parte alta de A)
    mov bx, [bLo]       ; BX = 0001h (parte baja de B)
    mov cx, [bHi]       ; CX = 0001h (parte alta de B)

    add ax, bx          ; FFFFh + 0001h = 0000h, CF=1 (acarreo!)
    adc dx, cx          ; 0001h + 0001h + CF(1) = 0003h

    mov [resLo], ax
    mov [resHi], dx

    ; Verificar resultado esperado
    cmp ax, 0000h
    jne .errorSuma
    cmp dx, 0003h
    jne .errorSuma

    mov ah, 09h
    mov dx, msgSuma
    int 21h
    mov ah, 09h
    mov dx, crlf
    int 21h
    jmp .restar

.errorSuma:
    mov ah, 09h
    mov dx, msgErr
    int 21h
    mov ah, 09h
    mov dx, crlf
    int 21h

    ; ==========================================
    ; RESTA: A - B = 0x00030000 - 0x00010001
    ;        Esperado: 0x0001FFFF (DX=0001h, AX=FFFFh)
    ; ==========================================
.restar:
    mov ax, 0000h       ; parte baja de A (0x00030000)
    mov dx, 0003h       ; parte alta de A
    mov bx, 0001h       ; parte baja de B (0x00010001)
    mov cx, 0001h       ; parte alta de B

    sub ax, bx          ; 0000h - 0001h = FFFFh, CF=1 (prestamo)
    sbb dx, cx          ; 0003h - 0001h - CF(1) = 0001h

    ; Verificar resultado esperado
    cmp ax, 0FFFFh
    jne .errorResta
    cmp dx, 0001h
    jne .errorResta

    mov ah, 09h
    mov dx, msgRest
    int 21h
    mov ah, 09h
    mov dx, crlf
    int 21h
    jmp .fin

.errorResta:
    mov ah, 09h
    mov dx, msgErr
    int 21h
    mov ah, 09h
    mov dx, crlf
    int 21h

.fin:
    mov ah, 4Ch
    xor al, al
    int 21h