// escribir un programa que prenda un LED que se va desplazando cada vez que se conecta una tecla conectada a RB0
// Al pulsar por primera vez la tecla se enciende el LED conectado a RB1 y al llegar a RB3 vuelve a RB1. Se repite
// indefinidamente. 
// EL PROGRAMA PRINCIPAL NO REALIZA TAREA ALGUNA Y TODO SE DESARROLLA EN UNA ISR
// ¿Cómo reorganizaría el software y el hardware si usara la resistencia de pull-up interna en RB0?

// Puerto B:
// -----------------
// B0 -> 1 (entrada)	
// B1 -> 0 (salida)
// B2 -> 0 (salida)
// B3 -> 0 (salida)
// B4 a B7 -> 0 (salida)

SEQ EQU 0x20	; secuencia de conteo

ORG 0x00
	GOTO START
ORG 0x04
	GOTO ISR	; vector de interrupción

START: 
	; ========================
	; CONFIGURACIÓN DE PUERTOS
	; ========================

	; selecciono el banco 3
	BSF STATUS,RP0	; 1
	BSF STATUS,RP1	; 1
	
	; configuro todos los puertos B como digitales
	CLRF ANSELH

	; selecciono el baco 1
	BCF STATUS,RP0	; 0 1
	
	; 0000 0001 -> necesito este literal en el TRISB
	MOVLW 0x01
	MOVWF TRISB
	
	; dejamos el banco 0 seleccionado para poder acceder a los puertos
	BCF STATUS, RP1 ; 0 0
	
	; configuro el estado inicial de la variable de control
	; para que el LED 1 arranque prendido al apretar el pulsador
 
	// NO -> SE TIENE QUE HACER TODO EN LA ISR
	//; verificamos si se apretó el pulsador en RB0
	//BTFSC PORTB,0
	//GOTO LOOP	; si no se apretó, vuelve a ejecutar el ciclo
	//; se apretó el pulsador -> ejecutamos debouncing
	//CALL DELAY_10	; retardo 10ms
	//
	//BTFSC PORTB,0	; volvemos a revisar
	//GOTO LOOP	; falsa alarma
	//
	//; el pulsador se apretó efectivamente
	
	BANKSEL PORTB
	CLRF PORTB	; todo arranca apagado

	; configuramos las interrupciones
	; no hace falta seleccionar bancos
	BSF INTCON, INTE	; habilita interrupción externa
	BSF INTCON, GIE		; habilita las interrupciones globales

	; configuramos el tipo de flanco
	BANKSEL OPTION_REG
	BCF OPTION_REG, INTEDG	; interrupción por flanco descendente (pulso hacia 0)
	
	; inicializamos las variables
	BANKSEL 0
	CLRF SEC
	
LOOP:
	SLEEP	; programa principal duerme ???????????
	GOTO LOOP	
	
DELAY_10:
	; =====================
	; DELAY 10ms DEBOUNCING
	; =====================
	
	; fosc = 4 MHz
	; fosc/4 = 1 MHz
	; 1/fosc/4 = 1 us
	; cada instrucción demora 1 us
	; 1.000.000 us = 1s
	; 1.000 ms = 1s
	; 1.000 ms ---- 1x10⁶ us
	; 10 ms ------- x = 10.000 INSTRUCCIONES

	; USAMOS PRESCALER PARA EJECUTAR MENOS INSTRUCCIONES
	; 10.000 / 64 = 156 instrucciones aprox
	
	CLRF TMR0
	BCF OPTION_REG, T0CS	; seleccionamos Fosc/4 como source del clock
	BCF OPTION_REG, PSA	; selecciono que vamos a usar el prescaler
	
	; configuramos el prescaler rate a 1:64 
	MOVLW 0x05	; seleccionamos 0000 0101 <PSA101>
	MOVWF OPTION_REG
	
	; si cargamos el TMR0 con 100 y sabiendo que el mismo cuenta hacia arriba
	; 0 a 255 -> 256 valores
	; como quiero que cuente 156 veces, entonces cargo 100 para que arranque de ahí
	; 256 - 100 = 156

	BCF INTCON,T0IF	; limpiamos el flag de overflow
	MOVLW d'100'	; cargamos 100 en el TMR0
	MOVWF TMR0
	
	CHECK_OVERFLOW:
		; Esperamos que se levante la flag del overflow -> esto significa que llego del 100 al 255
		BTFSS INTCON, T0IF	; flag de interrupción del TMR0
		GOTO CHECK_OVERFLOW	; repetimos hasta que sea 1
		RETURN			; hubo overflow, hizo el conteo
	
ISR:
	; ==========================
	; SUB RUTINA DE INTERRUPCIÓN
	; ==========================
	
	; revisamos si se levantó la bandera de interrupción externa
	BTFSS INTCON, INTF
	RETFIE	; si la bandera está en cero, salimos de la ISR
	; si la bandera de interrupción externa está en 1, la limpiamos y manejamos la secuencia 
	BCF INTCON, INTF	; limpiamos la bandera
	INCF SEQ,1		; aumentamos el conteo
	
	MOVF	SEQ,0		; W <- SEQ
	SUBLW	0x03		; le restamos 3 para saber si nos pasamos
	BTFSC 	STATUS,Z	; si da cero es porque la secuencia llego a 3
	CLRF 	SEQ		; lo volvemos a 0 al contador
	MOVF	SEQ,0		; W <- SEQ (actualizamos el valor de la secuencia SEQ en W por si lo modificamos)
	CALL 	TABLA_LEDS
	
	MOVWF	PORTB		; mostramos la salida de la tabla en el puerto B
	RETFIE 	; salimos de la rutina

TABLA_LEDS:	
	ADDWF PCL,1
	RETLW 0x02	; 0000 0010
	RETLW 0x04	; 0000 0100
	RETLW 0x08	; 0000 1000
