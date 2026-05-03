; p2b.asm - DAA/DAS: aritmetica BCD empaquetada
; Compilar: ..\nasm -f bin p2b.asm -o ..\bin\p2b.com
; BCD empaquetado: 2 digitos decimales por byte (un nibble por digito)
; DAA corrige AL despues de ADD para mantener formato BCD valido
; DAS corrige AL despues de SUB para mantener formato BCD valido
; Ambas instrucciones usan el flag AF (auxiliary carry) y CF

ORG 100h

section .data
    ; --- Operandos suma BCD ---
    bcd1    db 47h          ; BCD empaquetado: representa "47"
    bcd2    db 38h          ; BCD empaquetado: representa "38"
    ; Esperado: 47 + 38 = 85 -> BCD 85h
    resSum  db 0            ; buffer resultado suma

    ; --- Mensajes ---
    msgSumOK  db "BCD suma: $"
    msgDasOK  db "DAS OK: $"
    msgErr    db "Error BCD.$"
    crlf      db 0Dh,0Ah,"$"

section .text
start:
    ; ==========================================
    ; SUMA BCD: 47h + 38h = 85h con DAA
    ; Sin DAA: 47h + 38h = 7Fh (NO es BCD valido)
    ; Con DAA: AL = 85h (correcto)
    ; ==========================================
    mov al, [bcd1]      ; AL = 47h
    add al, [bcd2]      ; AL = 47h + 38h = 7Fh (invalido en BCD)
    daa                 ; ajuste BCD: AL = 85h, CF segun resultado

    mov [resSum], al

    ; Verificar que el resultado sea 85h
    cmp al, 85h
    jne .errorSum

    ; Imprimir "BCD suma: "
    mov ah, 09h
    mov dx, msgSumOK
    int 21h

    ; Extraer e imprimir digito de decenas (nibble alto)
    mov al, [resSum]
    mov bl, al          ; guardar copia en BL
    shr al, 4           ; nibble alto -> AL (decenas)
    add al, 30h         ; convertir a ASCII
    mov dl, al
    mov ah, 02h
    int 21h             ; imprimir decena

    ; Extraer e imprimir digito de unidades (nibble bajo)
    mov al, bl
    and al, 0Fh         ; nibble bajo -> AL (unidades)
    add al, 30h
    mov dl, al
    mov ah, 02h
    int 21h             ; imprimir unidad

    mov ah, 09h
    mov dx, crlf
    int 21h
    jmp .restarBCD

.errorSum:
    mov ah, 09h
    mov dx, msgErr
    int 21h
    mov ah, 09h
    mov dx, crlf
    int 21h

    ; ==========================================
    ; RESTA BCD: 73h - 28h = 45h con DAS
    ; Sin DAS: 73h - 28h = 4Bh (NO es BCD valido)
    ; Con DAS: AL = 45h (correcto)
    ; ==========================================
.restarBCD:
    mov al, 73h         ; BCD "73"
    sub al, 28h         ; AL = 73h - 28h = 4Bh (invalido en BCD)
    das                 ; ajuste BCD: AL = 45h

    cmp al, 45h
    jne .errorDAS

    ; Imprimir "DAS OK: "
    mov ah, 09h
    mov dx, msgDasOK
    int 21h

    ; Imprimir resultado 45
    mov bl, al
    shr al, 4           ; decenas
    add al, 30h
    mov dl, al
    mov ah, 02h
    int 21h

    mov al, bl
    and al, 0Fh         ; unidades
    add al, 30h
    mov dl, al
    mov ah, 02h
    int 21h

    mov ah, 09h
    mov dx, crlf
    int 21h

    ; ==========================================
    ; CASO EXTRA: 20h - 01h = 19h con DAS
    ; Sin DAS: 20h - 01h = 1Fh (nibble bajo F > 9, invalido)
    ; Con DAS: AL = 19h (correcto), CF=0
    ; ==========================================
    mov al, 20h         ; BCD "20"
    sub al, 01h         ; AL = 1Fh (nibble bajo invalido)
    das                 ; AL = 19h (correcto)

    cmp al, 19h
    jne .errorDAS
    jmp .fin

.errorDAS:
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