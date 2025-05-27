
TECLA EQU 0x30        ; índice de tecla pulsada [0,15]
COL   EQU 0x31        ; índice de columna en el que estoy [0,3]
FIL   EQU 0x32        ; ínidce de la fila en la que estoy [0,3]
MASK  EQU 0x33        ; máscara para la detección 
SNAPSHOT_PORTB EQU 0x20   ; último valor del PORTB
CONT0 EQU 0x21
CONT1 EQU 0x22

ORG 0x00

CONFIG:
    ; configuro el puerto B como digital
    BANKSEL ANSELH
    
    MOVLW 0x00
    MOVWF ANSELH
    
    ; configuro RB0 a RB3 como salida
    BANKSEL TRISB
    MOVLW 0x00
    MOVWF TRISB
    ; configuro RB4 a RB7 como entradas
    MOVLW 0xF0
    
    ; dejo al puerto B bajo
    BANKSEL PORTB
    MOVLW 0x00
    MOVWF PORTB

    GOTO LOOP

LOOP_POLLING:
    ; guardo el valor de PORTB en SNAPSHOT
    MOVF PORTB, SNAPSHOT_PORTB

    ; guardo el snapshot W
    MOVF SNAPSHOT_PORTB, 0

    ; veo si hubo cambios en el puerto en comparación del snapshot
    CHECK:
        ; hago la resta entre el snapshot y el puerto B
        SUBWF PORTB
        
        ; reviso si la operación dio cero -> significa que son iguales y no hubo cambio
        ; si Z = 1 significa que no hubo cambios
        ; si Z =  0 significa que hubo cambios
        BTFSS STATUS,Z
        GOTO LEER_TECLAS
        GOTO CHECK
    
LEER_TECLAS:
    ; primero hago un anti rebotes de 20ms
    CALL DELAY_20
    
    ; reviso nuevamente si hubo cambios en PORTB
    MOVF PORTB, 0    ; W <- PORTB
    SUBWF SNAPSHOT_PORTB
    
    BTFSC STATUS,Z
    GOTO LOOP_POLLING
    
    CALL ESCANEAR_TECLAS
    
ESCANEAR_TECLAS:
    CLRF COL    	; limpio el índice de columna escaneada
                	; empiezo a escanear desde la columna 0
    MOVLW 0x08  	; empezamos de la RB3
    MOVWF COLMASK	; guardo el valor de la columna activa inicial en COLMASK

    ; Ahora vamos a tener una columna activa, debemos ver fila por fila en cuál hay una activa
    ESCANEAR_FILAS:
	CLRF INDICE	; empezamos desde la fila 0
	MOVF COLMASK,W	; movemos la posición de columna actual
	MOVWF PORTB
	
	; revisamos fila por fila
	; fila 1
	BTFSC PORTB,4	; ¿fila 1 en alto? (RB4)
	GOTO OFFSET	; si -> offset
	CALL SUMAR_4	; no -> sumo 4 al índice
	; fila 2
	BTFSC PORTB,5	; ¿fila 2 en alto? (RB5)
	GOTO OFFSET	; si -> offset
	CALL SUMAR_4	; no -> sumo 4 al índice
	; fila 3
	BTFSC PORTB,6	; ¿fila 3 en alto? (RB6)
	GOTO OFFSET	; si -> offset
	CALL SUMAR_4	; no -> sumo 4 al índice
	; fila 4
	BTFSC PORTB,7	; ¿fila 4 en alto? (RB7)
	GOTO OFFSET	; si -> offset
	
	; si no se detectó ninguna fila activa, pasamos a la siguiente col
	RRF COLMASK
	INCF CONT	; incrementamos el contador de columna
	
	; verificar que no se hayan recorrido las 4 columnas
	MOVLW 0x04 
	SUBWF COL
	BTFSS STATUS,Z	; verificamos si la operación da 0
	GOTO ESCANEAR_FILAS	; si no llegó a 4 entonces que siga escaneando la siguiente columna
	; si se llegó a la columna 4 
	MOVLW 0xFF	; movemos 11111111 a W 
	MOVWF INDICE,1	; ponemos el índice en este valor (tecla no válida)

	RETURN

OFFSET_COL:	
	; cuando detectamos una tecla presionada, calculamos el índice de la tecla presionada
	MOVF COL, 0	; W <- COL
	ADDWF INDICE, 1	; suma indice (fila * 4 + columna)

	RETURN

SUMAR_4:	
	; sumamos 4 al índice 
	MOVLW 0x04	; cargo 4 en W
	ADDWF INDICE	; sumo a 4 a índice
	
	RETURN

DELAY_20:
	MOVLW 0x14	; muevo 20 a W
	MOVWF CONT1	; CONT1 <- 20
RETARDO1:
	MOVLW 0xFA	; muevo 250 a W
	MOVWF CONT0	; CONT0 <- 250
RETARDO2:
	NOP		; 1 ciclo
	DECFSZ CONT0,1	; 1 ciclo si no es 0, 2 si es 0
	GOTO RETARDO2	;
	DECFSZ CONT1	; 1 ciclo si no es 0, 2 si es 0
	GOTO RETARDO1	;
	RETURN

// Bucle 1: 1 NOP + 1 DECFSZ + 2 GOTO = 4 ciclos * 249 = 996 ciclos
// Bucle 1: 1 NOP + 2 DECFSZ = 3 ciclos
// Total bucle 1 = 999 ciclos

// Bucle 2: 999 ciclos + 1 DECFSZ + 2 GOTO = 1002 ciclos * 19 = 19038 ciclos
// Bucle 2: 999 ciclos + 1 DECFSZ = 1001 ciclos * 1  = 1001 ciclos
// Total bucle 2 = 20039 ciclos
// Total delay = 20039 * 1us = 0.020039 segundos
