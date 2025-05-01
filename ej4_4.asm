// escribir un programa que dependiendo del estado de dos interruptores conectados a RA4 y RB0, presente en el puerto D diferentes funciones lógicas cuya tabla de verdad es [ver tabla]

ORG 0x00
GOTO START

CONT EQU 0x20	; codificación del estado de los interruptores
		; el bit 0 del contador hace referencia al interruptor 0, CONECTADO A RB0
		; el bit 1 del contador hace referencia al interruptor 1, CONECTADO A RA4

START: 
	; CONFIGURACIÓN DE PUERTOS
	
	; el puerto RA4 ya está configurado como digital y como puerto de entrada
	; configuramos el RB0 como puerto digital (por defecto ya está configurado como puerto de entrada)
	; RB0 comparte entrada con AN12

	; me ubico en le banco 3 para manipular el ANSELH
	BSF STATUS, RP0
	BSF STATUS, RP1

	; cambio estado del RB0
	MOVLW 0x2F	; 0010 1111 dejando AN12 como entrada digital
	MOVWF ANSELH	; guardo el valor en anselh

	; todo consultar si efectivamente el puerto B ya está configurado como una entrada

	; me muevo al banco 1 para manipular TRISD
	; los pines del puerto D están configurados como entrada por defecto
	BCF STATUS, RP1	; pongo en cero el bit RP1 <0,1> -> banco 1
	
	// MOVLW 0x00	; muevo un byte en 0 a W
	// MOVWF TRISD	; guardo el 0000 0000 en el puerto D -> TODOS LOS PINES COMO SALIDA
	// ESTO DE PUEDE SIMPLIFICAR HACIENDO UN CLRF DEL TRISD
	CLRF TRISD	; TODOS LOS PINES DEL PUERTO D COMO SALIDA

	; todos los puertos configurados

	; vuelvo al banco 0 
	BCF STATUS, RP0

	; configuro el contador codificador en 00 
	MOVLW 0x00
	MOVWF CONT

MAIN:
	; LOOP PRINCIPAL
	
	; revisamos constantemente el estado de los puertos de entrada
	; lógica
	; ----------------
	; RA4 == 0
	;	RB0 == 0
	; 	RB0 == 1
	; RA4 == 1
	;	RB0 == 0
	;	RB0 == 1
	
	; actualizamos el codificador contador para el pin RA4
	BTFSS PORTA,4	; reviso el estado del pin 4 puerto A
	BCF CONT,1	; el pin está en cero -> ACTUALIZO EL CONTADOR CODIFICADOR
	BTFSC PORTA,4	; reviso el estado del pin 4 puerto A
	BSF CONT,1	; el pin está en uno -> ACTUALIZO EL CONTADOR CODIFICADOR

	; hacemos lo mismo con el segundo bit para RB0
	BTFSS PORTB,0	; reviso el estado del pin 0 puerto B
	BCF CONT,0	; pin en 0 -> actualizo el contador
	BTFSC PORTB,0	; reviso el estado del pin 0 puerto B
	BSF CONT,0 	; el pin está en 1 -> actualizo 

	; el codificador/contador se cargó con el estado de las llaves
	
	; ahora debemos actualizar la salidas del puerto D en base a la tabla
	; muevo el valor del contador a W
	MOVF CONT, 0
	CALL TABLA	; buscamos en la tabla
	
	; ahora en W tenemos cargado el resultado de la tabla
	; movemos el resultado al puerto D
	MOVWF PORTD	; se mueve el valor de la tabla al puerto D
	
	; reiniciamos el ciclo
	GOTO MAIN

TABLA: 
	ADDWF PCL,1
			; RA4/RB0 --> devolución de tabla
	RETLW 0xAA	; 00 --> 1010 1010
	RETLW 0x55	; 01 --> 0101 0101
	RETLW 0x0F	; 10 --> 0000 1111
	RETLW 0xF0	; 11 --> 1111 0000
	
