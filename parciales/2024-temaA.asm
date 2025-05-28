STATUS_TEMP EQU 0x20
W_TEMP EQU 	0x21
CONT	EQU	0x22	; contador de pulsaciones

ORG 0x00
	GOTO MAIN
ISR 0x04
	GOTO ISR

MAIN:
	; configuramos los puertos
	BANKSEL ANSEL
	CLRF ANSEL	; configuro todos los puertos como digitales

	; configuro el RB0 como entrada
	BANKSEL TRISB
	CLRF TRISB	; dejo todas como salida
	BSF TRISB,0	; cambio RB0 como entrada

	; configuro el puerto C como salida
	BANKSEL TRISC
	CLRF TRISC

	; configuro interrupciones 
	BANKSEL OPTION_REG

	BCF OPTION_REG,7	; habilito las pull-ups del puerto B para RB0
	BCF OPTION_REG,6	; habilito las interrupciones como flanco desdecendente

	BSF INTCON,4		; habilito INTE para habilitar interrupciones externas
	BCF INTCON,1		; limpio la bandera de interrupciones externas
	BSF INTCON,7		; habilito las interrupciones globalmente

	CLRF CONT		; inicio el contador de pulsos en 0

	GOTO LOOP

LOOP:
	SLEEP		; el programa principal duerme
	GOTO LOOP

ISR:
	; salvo contexto de STATUS y W
	MOVWF W_TEMP		; guardo W temporalmente
	SWAPF STATUS, W		; invierto STATUS y lo guardo en W 
	MOVWF STATUS_W		; guardo STATUS temporalmente

	CALL DELAY_20		; delay de 20ms antirrebotes TODO preguntar
	INCF CONT	; incremento el valor del contador
	
	MOVF CONT,0	; W <- CONT
	CALL MOSTRAR_DISPLAY	; llamamos a la rutina de mostrar por display
	MOVWF PORTC	; muestro el resultado por pantalla
	
	BSF INTCON,7 		; vuelvo a habilitar interrupciones globales
	BCF INTCON,1		; limpio la bandera de interrupciones externas 
	
	RETFIE

MOSTRAR_DISPLAY:
	ADDWF PCL,1
	;       hgfedcba	
	RETLW D'00111111'
	RETLW D'00000110'
	RETLW D'00011011'
	RETLW D'00001111'
	RETLW D'01100110'
	RETLW D'01101101'
	RETLW D'01111101'
	RETLW D'01000111'
	RETLW D'11111111'
	RETLW D'01100111'
