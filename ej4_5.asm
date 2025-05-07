// se desea que al apretar un pulsador que se conecta a RA4 parpadeen a una frecuencia de 0.5 Hz los 
// 8 leds conectados en las terminales del puerto D. 
// Si se aprieta otro pulsador conectado a RB0 se debe interrumpir el parpadeo por 3 segundos. 
// Inicialmente los pulsadores se encuentran apagados 
// El oscilador es de 4 MHz

ORG 0x00
CONT1 EQU 0x20  ; contador externo
CONT2 EQU 0x21	; contador intermedio
CONT3 EQU 0x22	; contador interno

GOTO START

START:
	; ==========================
        ; CONFIGURACIÓN DE PUERTOS
	; ==========================

        ; el puerto RA4 ya está configurado como digital y como puerto de entrada
        ; configuramos el RB0 como puerto digital (por defecto ya está configurado como puerto de entrada)
        ; RB0 comparte entrada con AN12

        ; me ubico en le banco 3 para manipular el ANSELH
        BSF STATUS, RP0
        BSF STATUS, RP1

        ; cambio estado del RB0
        MOVLW 0x2F      ; 0010 1111 dejando AN12 como entrada digital
        MOVWF ANSELH    ; guardo el valor en anselh

        ; todo consultar si efectivamente el puerto B ya está configurado como una entrada

        ; me muevo al banco 1 para manipular TRISD
        ; los pines del puerto D están configurados como entrada por defecto
        BCF STATUS, RP1 ; pongo en cero el bit RP1 <0,1> -> banco 1

        // MOVLW 0x00   ; muevo un byte en 0 a W
        // MOVWF TRISD  ; guardo el 0000 0000 en el puerto D -> TODOS LOS PINES COMO SALIDA
        // ESTO DE PUEDE SIMPLIFICAR HACIENDO UN CLRF DEL TRISD
        CLRF TRISD      ; TODOS LOS PINES DEL PUERTO D COMO SALIDA

        ; todos los puertos configurados

        ; vuelvo al banco 0 
        BCF STATUS, RP0

LOOP:
	; ====================
	; CICLO PRINCIPAL
	; ====================

	; verificamos cual de los dos pulsadores fue apretado
	; para ejecutar el delay correspondiente
	
	BTFSS PORTA,4	; revisamos el estado del pin 4 del puerto A
			; RA4 == 1 --> no fue apretado (SKIP)
			; RA4 == 0 --> si fue apretado
	GOTO parpadear_leds

	GOTO LOOP	; REINICIO EL CICLO

parpadear_leds:
	; verifico si RB0 fue apretado
	BTFSS PORTB,0
	GOTO pausa_3s

	; prendo LEDs
	MOVLW 0xFF
	MOVWF PORTD
	CALL DELAY_1S

	; verifico de nuevo si se apretó RB0
	BTFSS PORTB,0
	GOTO pausa_3s

	; apago LEDs
	MOVLW 0x00
	MOVWF PORTD
	CALL DELAY_1S

	; reinicio el ciclo
	GOTO prender_leds

PAUSA:
	CLRF PORTD	; apagamos todos los LEDs
	CALL DELAY_1S
	CALL DELAY_1S
	CALL DELAY_1S

	GOTO LOOP

; Retardo de 1s
DELAY_1S:
	MOVLW 0x04	; muevo 04 decimal a W
	MOVWF CONT1	; muevo W al contador 1
	; el ciclo se repetirá 4 veces

	LOOP1:
		MOVLW 0xFA	; muevo 250 a W
		MOVWF CONT2	; paso el contenido de W al contador intermedio
		
	LOOP2:
		MOLVW 0xFA	; muevo 250 a W
		MOVWF CONT3	; paso el contenido de W al contador interno
	LOOP3:
		NOP 		; ocupa 1 instrucción
		DECFSZ CONT3,1	; decrementa 1 al contador, si es cero salta a la siguiente
		GOTO LOOP3	; accede solo en caso de que CONT3 != 0
		
		DECFSZ CONT2,1	; decrementa 1 al contador, si es cero salta a la siguiente
		GOTO LOOP2	; accede solo en caso de que CONT2 != 0

		DECFSZ CONT1,1	; decrementa 1 al contador, si es cero salta a la siguiente
		GOTO LOOP1	; accede solo en caso de que CONT1 != 0
	RETURN
