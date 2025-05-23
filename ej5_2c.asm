// prender un led que se va desplazando cada vez que se pulsa una tecla a RB0
// primera vez se enciende led RB1
// sucesivamente se desplaza hasta RB3 y vuelve a RB1 con la siguiente pulsación
// el programa principal no realiza ninguna tarea
// todo se desarrolla dentro de una ISR

CONTADOR EQU 0x20

ORG 0x00
	GOTO CONFIG
ORG 0x04
	GOTO ISR

CONFIG:
	; configuramos los puertos

	BANKSEL TRISB	; seleccionamos el banco necesario
	
	CLRF TRISB	; todos los puertos B como salida
	BSF TRISB,0	; configuramos el RB0 como entrada
	
	BANKSEL ANSEL
	CLRF ANSEL	; especificamos los puertos
	CLRF ANSELH	; como digitales

	; configuramos las interrupciones
		; GIE -> todas las interrupciones habilitadas
		; INTE -> habilita las interrupciones del RB0
	MOVLW 0x90	; movemos 1001 0000 a W
	MOVWF INTCON	; establecemos GIE y INTE como habilitados, el resto como deshabilitados
	
	; manipulamos el option register -- seleccionamos el banco correspondiente
	BANKSEL OPTION_REG	
	; configuramos el INTEDG para que se dispare la interrupción en flanco decreciente
	BCF OPTION_REG, INTEDG
	
	CLRF CONTADOR	; inicializamos el contador en cero

	GOTO MAIN

MAIN:
	SLEEP		; el programa principal queda haciendo noni
	GOTO MAIN	; repetimos

ISR:	
	BTFSS INTCON,INTF	; chequeamos el estado de la bandera de interrupción externa
	RETFIE			; significa que no ocurrió la interrupción
	
	MOVLW 0x03	; movemos 3 decimal al contador
	MOVWF CONTADOR
	
	// tiramos la magia --> ocurrió la interrupción
	
	DECFSZ CONTADOR
	
	BTFSS STATUS, Z
	INCF CONTADOR
	BTFSC STATUS, Z
	BCF CONTADOR
	
	MOVF CONTADOR, 0	; movemos el contador a W
	CALL TABLA

	BANKSEL PORTB	// CHEQUEAR	; seleccionamos el banco para la salida
	MOVWF	PORTB	; mostramos la salida de la tabla en el puerto B	

	BCF INTCON,INTF	; limpiamos la bandera
	RETFIE		; terminamos ISR
TABLA:
	ADDWF PCL
	RETLW b'00000010'
	RETLW b'00000100'
	RETLW b'00001000'

	
