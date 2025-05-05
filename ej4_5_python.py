# se desea que al apretar un pulsador que se conecta a RA4 parpadeen a una frecuencia de 0.5 Hz los 
# 8 leds conectados en las terminales del puerto D. 
# Si se aprieta otro pulsador conectado a RB0 se debe interrumpir el parpadeo por 3 segundos. 
# Inicialmente los pulsadores se encuentran apagados 
# El oscilador es de 4 MHz

RA4 = 0 # pulsador RA4
		# RA4 = 0 --> apretado
		# RA4 = 1 --> no apretado
delay_1ms = 250 # 250 instrucciones son 1ms
delay_20ms = 20

def debounce():
	delay_1ms = 250 # 250 instrucciones son 1ms
	delay_20ms = 20

	while delay_20ms > 0:
		delay_20ms = delay_20ms - 1
		
		while delay_1ms > 0:
			delay_1ms = delay_1ms - 1
			print(delay_1ms)

		delay_1ms = 250
		print(delay_20ms)	

if RA4 == 0:
	print("Pulsador RA4 apretado")
	debounce()
	if RA4 == 0:
		print("Pulsador RA4 realmente apretado")
else:
	print("Pulsador RA4 no apretado")


