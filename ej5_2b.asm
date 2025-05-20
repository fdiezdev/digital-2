// prender un led que se va desplazando cada vez que se pulsa una tecla a RB0
// primera vez se enciende led RB1
// sucesivamente se desplaza hasta RB3 y vuelve a RB1 con la siguiente pulsación
// el programa principal no realiza ninguna tarea
// todo se desarrolla dentro de una ISR

ORG 0x00
	GOTO CONFIG
ORG 0x04
	GOTO ISR

CONT EQU 0x20

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
	
	// tiramos la magia --> ocurrió la interrupción
	MOVLW 0x02
	SUBWF CONTADOR
	; reivsamos el flag
	BTFSS STATUS, Z
	INCF CONTADOR
	BTFSC STATUS, Z
	BCF CONTADOR
	
	MOVFW CONTADOR
	CALL TABLA

	BANKSEL PORTB	// CHEQUEAR	; seleccionamos el banco para la salida
	MOVWF	PORTB	; mostramos la salida de la tabla en el puerto B	

	BCF INTCON,INTF	; limpiamos la bandera
	RETFIE		; terminamos ISR
TABLA:
	ADDWF PCL
	RETLW 0x01
	RETLW 0x02
	RETLW 0x03

	
