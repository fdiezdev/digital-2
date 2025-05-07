// escribir un programa que cuente indefinidamente de 0 a 9. 
// cada número deberá permanecer encendido por 1 segundo
// el conteo se iniciará en 0 al apretarse un pulsador
// el conteo se dentendrá al volver apretar el pulsador en el valor que esté la cuenta
// el oscilador es de 4MHz

// a	b	c	d	e	f	g	h
// RD0	RD1	RD2	RD3	RD4	RD5	RD6	RD7

CONT EQU 0x20	; conteo 0 -> 9
LEDS EQU 0x21	; valores LEDs

; B0 -> RD0
; (...)
; B7 -> RD7

PROCESSOR 16F887
ORG 0x00

GOTO START

START: 
	; TODO
	; - configurar al puerto D como salida
	; - configurar RB0 como entrada
	; - hacer loop principal para detectar cuando se presione RB0
	; - hacer secuencia que haga el conteo
	; - armar tabla para display LED 7segs
