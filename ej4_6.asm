// considerando el mismo hardware que el 4.4 escribir un programa que ilumine
// los LEDs conectados al puerto D según las siguientes especificaciones
// Inicialmente los LED's están PARPADEANDO
// Si se aprieta un pulsador conectado a RA4 se desplaza a la izquierda
// Si se vuelve a apretar el pulsador RA4 cambia el sentido del desplazamiento
// El desplazamiento debe comenzar al soltar el pulsador
// En cualquier momento al apretar el pulsador conectado a RB0 se vuelve al parpadeo inicial

ORG 0x00
CONT1 	EQU 0x20  ; contadores para delay
CONT2 	EQU 0x21  ; 
LEDS 	EQU 0x22  ; variable de temporal para LEDs (B0 = led0, ..., B7 = led7)
CONTROL EQU 0x23  ; variable de control
; CTRL0 -> flag para RA4 
; CTRL1 -> (0 = parpadeo	/ 1 = desplazamiento)
; CTRL2 -> (0 = a izquierda 	/ 1 = a derecha)
; CTRL3 -> (0 = leds apagados	/ 1 = leds encendidos)


GOTO START

// NO ENTIENDO: todo consultar
// 1. Cómo hago para detectar el flanco decreciente

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

	BCF STATUS, RP1 ; pongo en cero el bit RP1 <0,1> -> banco 1

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
	BTFSS PORTB,0	; verificamos si se apretó el bit0
	GOTO RESETEAR_LEDs
        BTFSS PORTA,4   ; revisamos el estado del pin 4 del puerto A
                        ; RA4 == 1 --> no fue apretado (SKIP)
                        ; RA4 == 0 --> si fue apretado
        GOTO parpadear_leds

        GOTO LOOP       ; REINICIO EL CICLO


