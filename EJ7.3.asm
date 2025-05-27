// Desarrollar un programa con 6 displays 7-segmentos que cuente desde '000000' al
// iniciarse. El contador avanza una cuenta cada segundo hasta '999999' y vuelve a '000000'
// indefinidamente. Los displays y la cuenta se manejan por interrupción en RB0 activada por flanco
// descendente.
// Los displays se conectan ÁNODO al PUERTO A, CÁTODO al PUERTO C

; digitos de los displays de 7 segmentos
DIG0 EQU 0x20
DIG1 EQU 0x21
DIG2 EQU 0x22
DIG3 EQU 0x23
DIG4 EQU 0x24
DIG5 EQU 0x25

INDEX EQU 0x26	; índice para multiplexación de ánodos (0 al 5)
POS5 EQU 0x27	; posición del 5 ???????????????
REFR EQU 0x28 	; refrescos por segundo

ORG 0x00
	GOTO CONFIG

ORG 0x04
	GOTO ISR	; vector de interrupción

CONFIG:
	; limpio todos los puertos
	CLRF PORTA
	CLRF PORTC

	BANKSEL ANSEL
	CLRF ANSEL	; configuro todos los puertos A como digitales

	BANKSEL ANSELH
	; RB0 comparte entrada con ANSELH
	MOVLW 0x1F	; 0010 1111
	MOVWF ANSELH	; solo queda AN12/RB0 como digital
	; ahora configuro RB0 como puerto de salida, todo el resto en 1
	BANKSEL TRISB
	MOVLW 0x01	; 0000 0001
	MOVWF TRISB

	; configuro los puertos TRISA y TRISC como salidas
	CLRF TRISA
	CLRF TRISC
	
	; configuro las interrupciones
	BANKSEL OPTION_REG
	BCF OPTION_REG, INTEDG 	; INTEDG = 0, flanco decreciente
	BSF INTCON, INTE	; INTE = 1, interrupciones externas habilitadas
	BSF INTCON, GIE		; GIE = 1, interrupciones globales habilitadas

	// Configuro los dígitos en 0 
	CLRF DIG0
	CLRF DIG1
	CLRF DIG2
	CLRF DIG3
	CLRF DIG4
	CLRF DIG5

	// configuro el valor inicial de refrescos 
	MOVLW 0x64	; arranco con 100 refrescos por segundo
	MOVWF REFR	; almaceno en la variable correspondiente

MAIN_LOOP:
	SLEEP		; el programa principal duerme
	GOTO MAIN_LOOP

ISR: 
	; reviso si fue una interrupción externa
	BTFSS INTCON, INTF	; INTF me dice si la interrupción fue externa (1 = ocurrió, 0 = no ocurrió)
	RETFIE			; si no ocurrió, salimos de la interrupción

	BCF INTCON, INTF	; limpiamos la bandera de interrupción

	CALL DISPLAY		; llamamos a la subrutina display (refresca un dígito)
	DECF REFR	; decrementamos la variable REFR
	BTFSC STATUS, Z	; verificamos si llegó a 0
	CALL INCREMENTAR	; si llegó a 0 incrementamos REFR

	RETFIE

DISPLAY:
	CLRF PORTA		; apagamos todos los displays
	; subrutina que se encarga de multiplexar los displays
	MOVF INDEX, 0		; W <- INDEX
	; ahora me muevo en los displays en base al índice
	ADDLW DIG0		; acá obtengo INDEX + DIGITO INICIAL
	MOVWF FSR 		; muevo el resultado anterior a FSR (me da una dirección de dígito)
	MOVF INDF,W		; muevo el valor que haya en el dígito anterior a W
	CALL TABLA_SEGMENTOS	; entro a la tabla con el valor del dígito cargado en W
	MOVWF PORTC		; mostramos el patron por el puerto C

	// Recordatorio
	// FSR = "¿A qué dirección quiero apuntar?"
	// INDF = "¿Qué hay en esa dirección?"

	MOVF INDEX, 0		; W <- INDEX
	CALL TABLA_ANODOS	; llamo a la tabla de ánodos para activar el ánodo correspondiente
				; del dígito que estoy analizando
	MOVWF PORTA		; muevo el valor del ánodo que debo activar al puerto A

	INCF INDEX,1		; incremento el índice y lo guardo en el mismo índice
	; corroboro si el índice es 5
	MOVF INDEX,0		; W <- INDEX
	SUBLW 0x05		; le resto 5
	BTFSC STATUS,Z
	CLRF INDEX		; si el índice llegó a 5 lo llevo nuevamente a 0
	RETURN

INCREMENTO:
	; Rutina encargada de incrementar los dígitos y reiniciarlos cuando llegan a 9
	; tengo que hacerlo con todos los dígitos

	MOVLW 0x64	; reinicializo REFR (variable de refresco)
	MOVWF REFR	; REFR <- W	
	
	; DIG5
	INCF DIG5,1	; incremento el dígito y lo guardo en el mismo registro
	MOVF DIG5, 0	; W <- DIG5
	XORLW 0x0A 	; (lo que sea que tenga DIG5) XOR (0000 1010)
	// Recordatorio -- si los dos valores son iguales XOR = 0
	//		-- si los valores son distintos XOR = 1
	BTFSS STATUS, Z	; ¿es 10?
	RETURN		; no -> salgo de la rutina
	CLRF DIG5	; si -> reinicio el dígito (llegó al valor máximo)

	; DIG4
	INCF DIG4,1	; incremento el dígito y lo guardo en el mismo registro
	MOVF DIG4, 0	; W <- DIG4
	XORLW 0x0A 	; (lo que sea que tenga DIG4) XOR (0000 1010)
	// Recordatorio -- si los dos valores son iguales XOR = 0
	//		-- si los valores son distintos XOR = 1
	BTFSS STATUS, Z	; ¿es 10?
	RETURN		; no -> salgo de la rutina
	CLRF DIG4	; si -> reinicio el dígito (llegó al valor máximo)
	
	; DIG3
	INCF DIG3,1	; incremento el dígito y lo guardo en el mismo registro
	MOVF DIG3, 0	; W <- DIG3
	XORLW 0x0A 	; (lo que sea que tenga DIG3) XOR (0000 1010)
	// Recordatorio -- si los dos valores son iguales XOR = 0
	//		-- si los valores son distintos XOR = 1
	BTFSS STATUS, Z	; ¿es 10?
	RETURN		; no -> salgo de la rutina
	CLRF DIG3	; si -> reinicio el dígito (llegó al valor máximo)

	; DIG2
	INCF DIG2, 1	; incremento el dígito y lo guardo en el mismo registro
	MOVF DIG2, 0	; W <- DIG2
	XORLW 0x0A 	; (lo que sea que tenga DIG2) XOR (0000 1010)
	// Recordatorio -- si los dos valores son iguales XOR = 0
	//		-- si los valores son distintos XOR = 1
	BTFSS STATUS, Z	; ¿es 10?
	RETURN		; no -> salgo de la rutina
	CLRF DIG2	; si -> reinicio el dígito (llegó al valor máximo)

	; DIG1
	INCF DIG1,1	; incremento el dígito y lo guardo en el mismo registro
	MOVF DIG1, 0	; W <- DIG1
	XORLW 0x0A 	; (lo que sea que tenga DIG1) XOR (0000 1010)
	// Recordatorio -- si los dos valores son iguales XOR = 0
	//		-- si los valores son distintos XOR = 1
	BTFSS STATUS, Z	; ¿es 10?
	RETURN		; no -> salgo de la rutina
	CLRF DIG1	; si -> reinicio el dígito (llegó al valor máximo)
	
	; DIG0
	INCF DIG0,1	; incremento el dígito y lo guardo en el mismo registro
	MOVF DIG0, 0	; W <- DIG0
	XORLW 0x0A 	; (lo que sea que tenga DIG0) XOR (0000 1010)
	// Recordatorio -- si los dos valores son iguales XOR = 0
	//		-- si los valores son distintos XOR = 1
	BTFSS STATUS, Z	; ¿es 10?
	RETURN		; no -> salgo de la rutina
	CLRF DIG0	; si -> reinicio el dígito (llegó al valor máximo)
	
	RETURN		; salimos de la rutina cuando llegamos a 0
	
	

TABLA_SEGMENTOS:
	ADDWL PCL, 1
	//	hgfedcba
    	RETLW b'01000000' ; 0
    	RETLW b'01111001' ; 1
    	RETLW b'00100100' ; 2
    	RETLW b'00110000' ; 3 
    	RETLW b'00011001' ; 4 
    	RETLW b'00010010' ; 5 
    	RETLW b'00000010' ; 6 
    	RETLW b'01111000' ; 7 
    	RETLW b'00000000' ; 8 
    	RETLW b'00010000' ; 9

TABLA_ANODOS:
	ADDWF PCL, 1
    	RETLW b'00000001' ; RA0 -> DISPLAY 0
    	RETLW b'00000010' ; RA1 -> DISPLAY 1
    	RETLW b'00000100' ; RA2 -> DISPLAY 2
    	RETLW b'00001000' ; RA3 -> DISPLAY 3
    	RETLW b'00010000' ; RA4 -> DISPLAY 4
    	RETLW b'00100000' ; RA5 -> DISPLAY 5
