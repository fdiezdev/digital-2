// escribir un programa que cuente el número de veces que se pulsó una tecla conectada 
// a la terminal RA4 y que saque el valor binario natural por el puerto B.
// Para mostrar la salida se utilizarán los bit RB0, RB1, RB2 y RB3 que son los que tienen
// conectados los LEDS. 

// puertos compartidos
// RB0 --> AN12
// RB1 --> AN10
// RB2 --> AN8
// RB3 --> AN9
// son todos puertos del ANSELH

// CORRECIÓN: Faltó agregar eliminador de rebotes! Con un delay

ORG 0x00
GOTO START

; defino una variable auxiliar CONT que almacene la cantidad de veces que se 
; aprete el pulsador
CONT EQU 0x20
CONT_DELAY EQU 0x21

START:
	; ------------------------
	; CONFIGURACIÓN DE PUERTOS
	; ------------------------
	
	; seleccionamos banco 3 para modificar ANSELH
	BSF STATUS, RP0
	BSF STATUS, RP1
	
	; el puerto RA4 es digital y ya está como entrada por defecto por lo que no hace falta configurarlo
	; configuro los puertos RB0 a RB3 como digitales
	MOVLW 0x28	; 0010 1000 configura a rb0, rb1, rb2 y rb3 como puertos digitales
	MOVWF ANSELH	; movemos la configuración al registro analog select high
	
	; nos movemos al banco 1 para manipular los tristate register
	BCF STATUS, RP1

	; ahora configuramos los puertos como entrada/salida
	; los pines del TRISB están configurados por defecto como entrada
	MOVLW 0x00	; movemos el valor 0000 0000
	MOVWF TRISB	; todos los puertos B como digitales y como salida
	
	; volvemos al banco 0 para leer los valores de los puertos
	BCF STATUS, RP0
	
	; iniciamos el contador de pulsaciones en 0 
	CLRF CONT

	; inicio la variable contador delay en 250 ciclos
	MOVLW 0xFA	; 250D en W
	MOVWF CONT_DELAY	; 250 en el contador

LOOP:
	; -------------------------
	; LECTURA DE PUERTOS
	; -------------------------
	; lógica de funcionamiento:
	; -------------------------
	; si RA4 == 1 => el pulsador no se apretó
	; si RA4 == 0 => el pulsador fue apretado

	BTFSS PORTA,4	; chequeamos el estado del puerto, si está en uno, salteamos
	GOTO DELAY	; si está en cero, ejecutamos antirrebotes
	BTFSC PORTA,4	; al volver del antirrebotes, comprobamos nuevamente
	GOTO LOOP 	; si al volver del antirrebotes sigue en 1, entonces vuelve a iniciar el loop
	INCF CONT	; si al volver del antirrebotes está en 0, entonces incrementa el contador de pulsos
	GOTO DISPLAY	; mostramos el valor en los LEDs
	GOTO LOOP	; ejecutamos nuevamente

DELAY:
	; ------------------------
	; ANTIRREBOTES (1ms)
	; ------------------------

	DECFSZ CONT_DELAY	; reducimos el valor del contador (250) -> si es cero, saltamos la línea siguiente
	GOTO DELAY		; si no es 0 el contador, vuelve a ejecutar el ciclo 
	RETURN			; si el contador quedó en cero, volvemos al loop principal

DISPLAY:
	; ------------------------
	; MOSTRAR CONTEO
	; ------------------------
	
	; motrar el valor de la variable CONT en el puerto B
	MOVF CONT, 0	; movemos el contador a W
	MOVWF PORTB	; movemos el contador al puerto B desde W
	RETURN

END
