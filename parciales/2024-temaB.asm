CONT EQU 0x20	; contador de pulsaciones
W_TEMP EQU 0x21	; salvado de contexto
STATUS_TEMP EQU 0x22
ORG 0x0000
	GOTO MAIN
ORG 0x04
	GOTO ISR

MAIN:
	; todos los puertos como digitales
	BANKSEL ANSEL
	CLRF ANSEL
	CLRD ANSLH

	; configuro B0 como entrada
	BANKSEL TRISD
	BSF TRISB,0
	; configuro todo el puerto D como salida
	CLRF TRISD

	; configuramos OPTION_REG
	BANKSEL OPTION_REG
	; 11000000
	MOVLW B'11000000'
	MOVWF OPTION_REG

	; configuramos INTCON
	; 10010000
	MOVLW B'10010000'
	MOVWF INTCON

	; limpiamos los puertos
	BANKSEL PORTD
	CLRF PORTB
	CLRF PORTD

LOOP:
	SLEEP		; el programa principal duerme esperando interrupción
	GOTO SLEEP

ISR:
	; salvamos contexto
	MOVF W,W_TEMP
	SWAPF STATUS, 0
	MOVWF STATUS_TEMP
	
	CALL DELAY_20

	INCF CONT	; incrementamos el contador de pulsaciones
	MOVLW 0x09
	SUBLW CONT

	BTFSC STATUS, Z	; vemos si es el contador es 0
	CLRF CONT
	
	; mostramos la salida por el port D
	MOVF CONT, W
	CALL TABLA_DISPLAY
	
	MOVWF PORTD
	
	; bajo la bandera de la interrupción
	BCF INTCON, INTE

	; recuperar contexto
	SWAPF STATUS_TEMP, 0
	MOVWF STATUS
	SWAPF W_TEMP,1
	SWAPF W_TEMP,0
	
	RETFIE
	
TABLA_DISPLAY:
	ADDWF PCL,F
	RETLW ...
