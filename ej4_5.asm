// se desea que al apretar un pulsador que se conecta a RA4 parpadeen a una frecuencia de 0.5 Hz los 
// 8 leds conectados en las terminales del puerto D. 
// Si se aprieta otro pulsador conectado a RB0 se debe interrumpir el parpadeo por 3 segundos. 
// Inicialmente los pulsadores se encuentran apagados 
// El oscilador es de 4 MHz

ORG 0x00
GOTO START

CONT EQU 0x20   ; contador

START:
        ; CONFIGURACIÓN DE PUERTOS

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

// Tengo que hacer 2 delays:
// 1. Delay de 2s (0.5 Hz) --> constante
// 2. Delay de 3s 	   --> cuando apreto RB0

LOOP:
	; ---------------------
	; CICLO PRINCIPAL
	; ---------------------

	; verificamos si alguno de los
