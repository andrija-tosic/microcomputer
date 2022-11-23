;====================================================================
; Main.asm file generated by New Project wizard
;
; Created:   Mon Mar 7 2022
; Processor: 8086
; Compiler:  MASM32
;
; Before starting simulation set Internal Memory Size 
; in the 8086 model properties to 0x10000
;====================================================================

CODE    SEGMENT 
        ASSUME CS:CODE

	PORTA EQU 83F0h
	PORTB EQU 83F2h
	PORTC EQU 83F4h
	CW    EQU 83F6h
	
	CW_C_IN EQU 10101110b
	CW_C_OUT EQU 10100110b
	
	CW_B_IN EQU 0A7h
	
	; patch
	out 00h, al
	in al, 00h

START:	
	; konfiguracija
	mov al, CW_C_IN
	mov dx, CW
	out dx, al
	
	mov si, 0
	
prekidac:
	mov dx, PORTC
	in ax, dx
	cmp al, 22h
	je prekidac ; sve dok je prekidac otvoren

	
glavna:
	mov al, CW_C_OUT
	mov dx, CW
	out dx, al
	
	mov al, 0FFh
	mov dx, PORTC
	out dx, al
   
	mov cx, 1FFFh
delay:
	loop delay ; upaljena dioda
	
	
	
	mov al, niz1[si]
	mov dx, PORTA
	out dx, al
	
	mov cx, 1fffh
delay2:
	loop delay2
	
	
	
	mov dx, PORTB
	in al, dx
	mov niz2[si], al
	
	mov al, 0h
	
	mov dx, PORTC
	out dx, al ; izgasena dioda
		
	inc si
	cmp si, 10
	jl glavna
	
	jmp START
		
	ORG 100h
	niz1 db 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'
	
	ORG 200h
	niz2 db 10 dup(0FFh)

CODE ENDS
END