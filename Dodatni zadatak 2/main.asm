proc1 segment
    int3_proc proc far
    assume cs:proc1, ds:data
    ; kontekst procesora
;ORG 8000H
    PUSHF
    PUSH ax
    PUSH dx
    
    ; ispisivanje trojke
    mov al, CIFRE[3]
    out PORTA, al

	; OCW2
	mov al, 11100100b ; rotacija prioriteta
	out MASTER_A0, al

	mov al, 00100000b ; EOI
	out MASTER_A0, al

	mov al, 00100000b ; EOI
	;out SLAVE_A0, al

    POP dx
    POP ax
    POPF
    IRET
    int3_proc ENDP
proc1 ENDS

proc2 segment
    int5_proc proc far
    assume cs:proc2, ds:data
    ; kontekst procesora
;ORG 9000H
    PUSHF
    PUSH AX
    PUSH DX
    
    ; ispisivanje petice
    mov al, CIFRE[5]
    out PORTA, al

	; OCW2
	mov al, 11100101b ; rotacija prioriteta
	out MASTER_A0, al

	mov al, 00100000b ; EOI
	out MASTER_A0, al

	mov al, 00100000b ; EOI
	out SLAVE_A0, al

    POP dx
    POP dx
    POPF
    IRET
    int5_proc ENDP
proc2 ENDS

data segment
;ORG 0F000H
	PORTA EQU 58h
	PORTB EQU 5Ah
	PORTC EQU 5Ch
	CW    EQU 5Eh
	
	MASTER_A0 EQU 34h
	MASTER_A1 EQU 36h
	
	SLAVE_A0 EQU 38h
	SLAVE_A1 EQU 3Ah
	
	ICW1 EQU 11h
	ICW2_MASTER EQU 0B0h
	ICW2_SLAVE EQU 0A8h
	
	ICW3_MASTER EQU 01000000b
	ICW3_SLAVE EQU 00000110b
	
	ICW4_MASTER EQU 00000011b
	ICW4_SLAVE  EQU 00000011b ; specifikacija kaze slave ne moze biti u AEOI modu
	
	OCW1_MASTER EQU 10011111b
	OCW1_SLAVE  EQU 11110111b

	OCW2_MASTER EQU 10000000b
	OCW2_SLAVE  EQU 00100000b
	
	CIFRE DB 11000000B
	      DB 11111001B
	      DB 10100100B
	      DB 10110000B
	      DB 10011001B
	      DB 10010010B
	      DB 10000010B
	      DB 11011000B
	      DB 10000000B
	      DB 10010000B
data ends

stek segment stack
   dw 64 dup(0ffffh)
   tos label word
stek ends


CODE    SEGMENT 
        ASSUME CS:CODE, ds:data, ss:stek
;ORG 0E000H
START:	
	cli
	mov ax, data
	mov ds, ax
	
	mov ax, stek
	mov ss, ax
	lea sp, tos
	
	; patch
	out 00h, al
	in al, 00h

	; konfiguracija 8255A
	mov al, 10000000b
	out CW, al
	
	; konfiguracija 8259
	
	; ICW1
	mov al, ICW1
	out MASTER_A0, al
	out SLAVE_A0, al
	
	; ICW2
	mov al, ICW2_MASTER
	out MASTER_A1, al
	
	mov al, ICW2_SLAVE
	out SLAVE_A1, al
	
	; ICW3
	mov al, ICW3_MASTER
	out MASTER_A1, al
	
	mov al, ICW3_SLAVE
	out SLAVE_A1, al
	
	; ICW4
	mov al, ICW4_MASTER
	out MASTER_A1, al

	mov al, ICW4_SLAVE
	out SLAVE_A1, al
	
	; OCW1
	mov al, OCW1_MASTER
	out MASTER_A1, al
	
	mov al, OCW1_SLAVE
	out SLAVE_A1, al

	; OCW2
	mov al, OCW2_MASTER
	out MASTER_A0, al

	mov al, OCW2_SLAVE
	out SLAVE_A0, al
	
	; interrupt tabela
	mov ax, offset int3_proc
	mov [es:2ACh], ax
	mov ax, seg int3_proc
	mov [es:2AEh], ax
	
	mov ax, offset int5_proc
	mov [es:2D4h], ax
	mov ax, seg int5_proc
	mov [es:2D6h], ax
	
	; ispis nule
	mov al, 11000000b
	out PORTA, al
	
	sti
infinite:
   jmp infinite

CODE ENDS
END START