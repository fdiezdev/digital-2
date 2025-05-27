// Escribir un código en assembler que realice una interrupción por RB cuando se
// realice un cambio de nivel en cualquiera de los puertos RB4 a RB7. En el servicio
// a la interrupción (ISR) generar un retardo de 100 mseg. Recuerde que estas
// interrupciones por nivel y debe implementar un sistema antirebote. Suponer un
// reloj de 4 Mhz.

CONFIG:
	; configuramos los puertos

	BANKSEL TRISB	; seleccionamos el banco necesario para trabajar con el puerto B
	MOVLW 0xF0		; movemos la configuración del puerto B
	MOVWF TRISB		; puerto B configurado

	; habilito las interrupciones en el puerto B
	BANKSEL IOCB
	MOVWF IOCB		; aprovecho que tengo 0xF0 en W para moverlo también a IOCB
	; los pines B del 4 a 7 quedan configurados como bits de entrada
