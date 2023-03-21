;*******************************************************************************
;UNIVERSIDAD DEL VALLE DE GUATEMALA
;IE2023 PROGRAMACIÓN DE MICROCONTROLADORES
;Autor: SHAGTY VALERIA FUENTES GARCÍA
;Compilador: PIC-AS (v2.36), MPLAB X IDE (v6.00)
;Proyecto: PROYECTO_01, GENERADOR DE FRECUENCIAS
;Hardware: PIC16F887
;Creado: 28/02/2023
;Última modificación: 28/02/2023
;*******************************************************************************
    
PROCESSOR 16F887
#include <xc.inc>
    
;*******************************************************************************
;   PALABRA DE CONFIGURACIÓN
;*******************************************************************************
    
;CONFIG1
    
    CONFIG FOSC=INTRC_NOCLKOUT ;OSCILADOR INTERNO SIN SALIDAS
    CONFIG WDTE=OFF            ;WDT DISEABLED (REINIC2IO REPETITIVO DEL PIC)
    CONFIG PWRTE=OFF           ;PWRT ENABLED (ESPERA DE 72ms AL INICIAR)
    CONFIG MCLRE=OFF           ;EL PIN DE MCLR SE UTILIZA COMO I/0
    CONFIG CP=OFF	       ;SIN PROTECCIÓN DE CÓDIGO
    CONFIG CPD=OFF	       ;SIN PROTECCIÓN DE DATOS
    CONFIG BOREN=OFF           ;SIN REINICIO CUÁNDO EL VOLTAJE DE ALIMENTACIÓN 
			       ;BAJA DE 4V
    CONFIG IESO=OFF            ;REINCIO SIN CAMBIO DE RELOJ DE INTERNO A EXTERNO
    CONFIG FCMEN=OFF           ;CAMBIO DE RELOJ EXTERNO A INTERNO EN CASO DE 
			       ;FALLO
    CONFIG LVP=OFF             ;PROGRAMACIÓN EN BAJO VOLTAJE PERMITIDA
    
;CONFIG2
    
    CONFIG WRT=OFF	       ;PROTECCIÓN DE AUTOESCRITURA POR EL PROGRAMA 
			       ;DESACTIVADA
    CONFIG BOR4V=BOR40V        ;REINICIO ABAJO DE 4V, (BOR21V=2.1V)
    
;*******************************************************************************
;   MACROS
;*******************************************************************************
    
MUX macro mux_reg, resta_lit
 
    MOVF    mux_reg, W
    SUBLW   resta_lit
    BTFSS   STATUS, 2		
    
    endm
    
DIVISION macro dividendo_reg, divisor_lit, cociente_reg, residuo_reg 
 
    clrf    cociente_reg
    MOVF    dividendo_reg, W
    MOVWF   residuo_reg
    INCF    cociente_reg
    MOVLW   divisor_lit
    SUBWF   residuo_reg, F
    BTFSC   CARRY
    GOTO    $-4
    DECF    cociente_reg
    MOVLW   divisor_lit
    ADDWF   residuo_reg, F
    
    endm
    
;*******************************************************************************
;   VARIABLES
;*******************************************************************************
    
PSECT udata_bank0
    
    W_TEMP:
    DS 1
    STATUS_TEMP:
    DS 1
    MULTIPLEXADO:	    ; VARIABLE PARA EL MULTIPLEXADO
    DS 1
    VALOR_TMR0:		    ; VARIABLE PARA CAMBIARLE EL VALOR AL N DEL TMR0
    DS 1
    UNIDADES:		    ; VARIABLE PARA LAS UNIDADES
    DS 1
    DECENAS:		    ; VARIBALE PARA LAS DECENAS
    DS 1
    CENTENAS:		    ; VARIBALE PARA LAS CENTENAS
    DS 1
    MILESIMAS:		    ; VARIBALE PARA LAS MILESIMAS
    DS 1 
    ESTADO:		    ; VARIABLE PARA MAQUINA DE ESTADOS EN LOOP
    DS 1
    VALOR_CONTADOR:	    ; VARIABLE PARA TOMAR EL VALOR DEL CONTADOR
    DS 1
    CUADRADA:		    ; VARIABLE PARA SACAR LA ONDA CUADRADA
    DS 1   
    VALOR_HZ:
    DS 1
    VALOR_KHZ:
    DS 1
    DISP_UNI:
    DS 1
    DISP_DEC:
    DS 1
    DISP_CEN:
    DS 1
    DISP_MIL:
    DS 1
    TABLITAS:
    DS 1
    BANDERA_T:
    DS 1
    
   
;*******************************************************************************
;   VECTOR RESET
;*******************************************************************************
    
PSECT CODE, delta = 2, abs
 ORG 0X000
    GOTO Main
    
;******************************************************************************* 
;   VECTOR ISR INTERRUPCIONES    
;*******************************************************************************
    
PSECT CODE, delta=2, abs
 ORG 0x0004
 
PUSH:
    MOVWF W_TEMP
    SWAPF STATUS, W
    MOVWF STATUS_TEMP
    
;________________________________INT. TMR1______________________________________
    
ITMR1:
    BANKSEL PIR1
    BTFSS   PIR1, 0		    ; BANDERA TMR1IF = 1?
    GOTO    ITMR0 
    
    CALL    REINICIO_TMR1
    BCF	    PIR1, 0		    ; BORRAMOS LA BANDERA DEL TMR1IF
    
    CALL    MUX_DISPLAY		    ; LLAMAMOS A LA SUBRUTINA DEL MULTIPLEXADO DE LOS 4 DISPLAYS
    
;________________________________INT. TMR0______________________________________
    
ITMR0:
    BANKSEL INTCON
    BTFSS   T0IF
    GOTO    IRBIF
    
    CALL    SIGNAL_TRIANGULAR	; LLAMAMOS A LA SUBRUTINA PARA SACAR LA SEÑAL TRIANGULAR
    
    CALL    REINICIO_TMR0
    
			    ; TABLA DE VERDAD ESTADOS
			    ;		|X| 
			    ;		|0| BIT EN 0
			    ;		|1| BIT EN 1
			    
    BTFSS   CUADRADA, 0	    ; X = 1
    GOTO    BIT_0	    ; X = 0
    GOTO    BIT_1	    ; X = 1
    
BIT_0:
    
    BSF	    CUADRADA, 0	    ; PONEMOS EL BIT EN 1 PARA EL CAMBIO
    BSF	    PORTC, 6	    ; ENCENDEMOS EL PRIMER BIT DEL PUERTO D
    BCF	    T0IF	    ; BORRAMOS LA BANDERA T0IF
    
    GOTO    IRBIF
    
BIT_1:
    
    BCF	    CUADRADA, 0	    ; PONEMOS EL BIT EN 0 PARA EL CAMBIO
    BCF	    PORTC, 6	    ; APAGAMOS EL PRIMER BIT DEL PUERTO D
    BCF	    T0IF	    ; BORRAMOS LA BANDERA T0IF
    
    GOTO    IRBIF

;______________________________INT. BOTONES_____________________________________
    
IRBIF:
    
    BTFSS   INTCON, 0
    GOTO    POP
    
			    ; TABLA DE VERDAD ESTADOS
			    ;		|X| 
			    ;		|0| S0 Hz
			    ;		|1| S1 KHz		
IESTADO:			
			
    BTFSS   ESTADO, 0	    ; X = 1?
    GOTO    IESTADO0	    ; X = 0, ESTADO 0 (Hz)
    GOTO    IESTADO1	    ; X = 1, ESTADO 1 (KHz)
    
    IESTADO0:
    
    MOVLW   0b00000001
    BTFSS   PORTB, 2	    ; VERIFICAMOS SI EL BOTÓN DE CAMBIO DE ESTADO ESTÁ PRESIONADO
    MOVWF   ESTADO	    ; PRENDEMOS EL BIT X PARA CAMBIAR DE ESTADO LA SIGUIENTE VEZ
    BTFSS   PORTB, 2	    ; ANTIREBOTE DEL BOTÓN DE CAMBIO
    GOTO    $-1
    
    CALL    Hz		    ; LLAMAMOS A LA SUBRUTINA PARA EL PRECALER DE Hz
    
    CALL    VARIACION_F	    ; SUBRUTINA PARA VARIAR LOS VALORES DE Hz
    
    BCF	    INTCON, 0	    ; LIMPIAMOS LA BANDERA DE INTERRUPCIÓN
    GOTO    POP
    
    IESTADO1:
    
    MOVLW   0b00000000
    BTFSS   PORTB, 2	    ; VERIFICAMOS SI EL BOTÓN DE CAMBIO DE ESTADO ESTÁ PRESIONADO
    MOVWF   ESTADO	    ; APAGAMOS EL BIT X PARA CAMBIAR DE ESTADO LA SIGUIENTE VEZ
    BTFSS   PORTB, 2	    ; ANTIREBOTE DEL BOTÓN DE CAMBIO
    GOTO    $-1	    
    
    CALL    kHz		    ; LLAMAMOS A LA SUBRUTINA PARA EL PRECALER DE kHz
    
    CALL    VARIACION_F	    ; SUBRUTINA PARA VARIAR LOS VALORES DE KHz
    
    BCF	    INTCON, 0	    ; LIMPIAMOS LA BANDERA DE INTERRUPCIÓN
    GOTO    POP
    
;_______________________________________________________________________________
    
POP:
    SWAPF   STATUS_TEMP, W
    MOVWF   STATUS
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    RETFIE		    ;REGRESA DE LA INTERRUPCIÓN
    
;*******************************************************************************
;   CÓDIGO PRINCIPAL
;*******************************************************************************
    
PSECT CODE, delta = 2, abs
 ORG 100h

;_____________________________TABLA DISPLAYS____________________________________ 
 
TABLA:			    ; Tabla de la traduccion de binario a hex
    CLRF    PCLATH
    BSF	    PCLATH, 0
    ANDLW   0x0F	    ; Se pone como limite 16 , en hex F
    ADDWF   PCL, F
    RETLW   0111111B	    ; 0
    RETLW   0000110B	    ; 1
    RETLW   1011011B	    ; 2
    RETLW   1001111B	    ; 3
    RETLW   1100110B	    ; 4
    RETLW   1101101B	    ; 5
    RETLW   1111101B	    ; 6
    RETLW   0000111B	    ; 7
    RETLW   1111111B	    ; 8
    RETLW   1101111B	    ; 9
    RETLW   1110111B	    ; A
    RETLW   1111100B	    ; B
    RETLW   0111001B	    ; C
    RETLW   1011110B	    ; D
    RETLW   1111001B	    ; E
    RETLW   1110001B	    ; F
    
;________________________________TABLA Hz_______________________________________    

TABLAHz:		    ; TABLA PARA MOSTRAR VALORES EN Hz
    
    CLRF    PCLATH
    BSF	    PCLATH, 0
    ANDLW   0x0F	    ; Se pone como limite 16 , en hex F
    ADDWF   PCL, F
    RETLW   32		    ; 32 Hz
    RETLW   35		    ; 35 Hz
    RETLW   38		    ; 38 Hz
    RETLW   41		    ; 41 Hz
    RETLW   46		    ; 46 Hz
    RETLW   51		    ; 51 Hz
    RETLW   57		    ; 57 Hz
    RETLW   65		    ; 65 Hz
    RETLW   76		    ; 76 Hz
    RETLW   91		    ; 91 Hz
    RETLW   113		    ; 113 Hz
    RETLW   150		    ; 150 Hz
    RETLW   128		    ; 128 Hz
    RETLW   223		    ; 223 Hz
    RETLW   255		    ; 255 Hz
    RETLW   12		    ; 7812 Hz
    
;_________________________________TABLA KHz_____________________________________
    
TABLAKHz:
    
    CLRF    PCLATH
    BSF	    PCLATH, 0
    ANDLW   0x0F	    ; Se pone como limite 16 , en hex F
    ADDWF   PCL, F
    RETLW   48		    ; 0.48 kHz
    RETLW   50		    ; 0.50 kHz
    RETLW   55		    ; 0.55 kHz
    RETLW   59		    ; 0.59 kHz
    RETLW   64		    ; 0.64 kHz
    RETLW   69		    ; 0.69 kHz
    RETLW   75		    ; 0.75 kHz
    RETLW   83		    ; 0.83 kHz
    RETLW   92		    ; 0.92 kHz
    RETLW   103		    ; 1.03 kHz
    RETLW   118		    ; 1.18 kHz
    RETLW   137		    ; 1.37 kHz
    RETLW   164		    ; 1.64 kHz
    RETLW   204		    ; 2.04 kHz
    RETLW   4		    ; 4.00 kHz
    RETLW   8		    ; 8.00 kHz
    
;_______________________________________________________________________________
 
PSECT CODE, delta = 2, abs
 ORG 200h
 
Main:
    
    CALL    C_PUERTOS
    CALL    C_RELOJ
    CALL    C_TMR0
    CALL    C_TMR1
    CALL    C_RBIF
    CALL    C_INT
    
    BANKSEL PORTB
    CLRF    PORTB
    CLRF    PORTA
    CLRF    PORTC
    CLRF    PORTD
    CLRF    MULTIPLEXADO
    CLRF    UNIDADES
    CLRF    DECENAS
    CLRF    CENTENAS
    CLRF    MILESIMAS
    CLRF    ESTADO
    CLRF    VALOR_TMR0
    CLRF    VALOR_HZ
    CLRF    CUADRADA
    CLRF    TABLITAS
    CLRF    BANDERA_T
     
;*******************************************************************************
;   LOOP PRINCIPAL
;*******************************************************************************
    
LOOP: 
    
MODOS:
    
			    ; TABLA DE VERDAD ESTADOS
			    ;		|X| 
			    ;		|0| S0 Hz
			    ;		|1| S1 KHz
    
    BTFSS   ESTADO, 0	    ; X = 1?
    GOTO    ESTADO0	    ; X = 0, ESTADO 0 (Hz)
    GOTO    ESTADO1	    ; X = 1, ESTADO 1 (KHz)
    
    ESTADO0:
   
    BSF	    PORTC, 4	    ; ENCENDEMOS LA LED DEL ESTADO DE Hz
    BCF	    PORTC, 5	    ; APAGAMOS LA LED DEL ESTADO DE KHz
    
    CALL    CAMBIO_VALOR1   ; LLAMAMOS A LA SUBRUTINA PARA HACER EL SWITCH CON LA TABLA DE HZ
    CALL    DIVISIONES1	    ; LLAMAMOS PARA HACER LA DIVISION PARA LOS DISPLAYS
    CALL    SWITCH_VAR	    ; LLAMAMOS A LA SUBRUTINA PARA HACER EL CAMBIO DE VARIABLES
    
    GOTO    LOOP
    
    ESTADO1:
    
    BSF	    PORTA, 7
    
    BCF	    PORTC, 4	    ; APAGAMOS LA LED DEL ESTADO DE Hz
    BSF	    PORTC, 5	    ; ENCENDEMOS LA LED DEL ESTADO DE KHz
    
    CALL    CAMBIO_VALOR2   ; LLAMAMOS A LA SUBRUTINA PARA HACER EL SWITCH CON LA TABLA DE kHZ
    CALL    DIVISIONES2	    ; LLAMAMOS PARA HACER LA DIVISION PARA LOS DISPLAYS
    CALL    SWITCH_VAR	    ; LLAMAMOS A LA SUBRUTINA PARA HACER EL CAMBIO DE VARIABLES
    
    GOTO    LOOP

;*******************************************************************************
;   CONFIGURACIONES
;*******************************************************************************
    
C_PUERTOS:			 ; CONFIGURACIÓN DE PUERTOS
    
    BANKSEL ANSEL
    CLRF    ANSEL
    CLRF    ANSELH
    
    BANKSEL TRISB
    MOVLW   0b00000000
    MOVWF   TRISA		 ; PUERTO PARA LOS DISPLAYS
    MOVWF   TRISD		 ; PUERTO PARA EL DAC
    MOVWF   TRISC		 ; PUERTO PARA LOS TRANSISTORES
    MOVLW   0b00000111
    MOVWF   TRISB		 ; PUERTO PARA LOS BOTONES (3 botones)

RETURN
    
C_RELOJ:			 ; CONFIGURACIÓN DEL RELOJ
    BANKSEL OSCCON
    BSF	    OSCCON, 6
    BSF	    OSCCON, 5		 ; IRCF = 110 4MHz
    BCF	    OSCCON, 4
    BSF	    OSCCON, 0		 ; Oscilador interno
    
RETURN
    
C_INT:				 ; CONFIGURACIÓN DE INTERRUPCIONES
    BANKSEL INTCON
    CLRF    INTCON
    BSF	    INTCON, 6		 ; SE HABILITA LAS INTERRUPCIONES PERIFÉRICAS PEIE
    BSF	    INTCON, 5		 ; SE HABILITA LA INTERRUPCIÓN DEL TIMER 0
    BSF	    INTCON, 3		 ; SE HABILITA LA INTERRUPCIÓN RBIE    
    BSF	    PIE1,   0		 ; SE HABILITA LA INTERRUPCIÓN DEL TMR1
    BSF	    INTCON, 7		 ; SE HABILITA GIE INTERRUPCIONES GLOBALES
    
RETURN
    
C_TMR0:				 ; CONFIGURACIÓN TIMER 0
    BANKSEL OPTION_REG
    BCF	    OPTION_REG, 7	 ; HABILITANDO PULLUPS INTERNOS PUERTO B
    BCF	    OPTION_REG, 6	
    
    BCF	    OPTION_REG, 5	 ; TOCS = 0
    BCF	    OPTION_REG, 3	 ; HABILITANDO EL PRESCALER
    
    BCF	    OPTION_REG, 0
    BSF	    OPTION_REG, 1	 ; PRESCALER 1:128
    BSF	    OPTION_REG, 2
    
    BANKSEL TMR0
    MOVLW   255			; N = VALOR_TMR0
    MOVWF   TMR0		
    
    RETURN
    
RETURN
    
C_TMR1:
    BANKSEL T1CON
    BCF	    T1CON, 6
    BSF	    T1CON, 0		; HABILITAR TMR1 (TMR1ON)
    BCF	    T1CON, 1		; OSCILADOR INTERNO TMR1CS FOSC/4
    
    BSF	    T1CON, 4
    BCF	    T1CON, 5		; T1CKPS PRESCALER PARA TMR1 DE 1:4
    BCF	    T1CON, 3
    
    CALL    REINICIO_TMR1
    
    BANKSEL PIR1
    BCF	    PIR1, 0		; BORRAMOS LA BANDERA DE INTERRUPCIÓN TMR1IF
    
RETURN
    
C_RBIF:
    BANKSEL IOCB
    BSF	    IOCB, 0
    BSF	    IOCB, 1
    BSF	    IOCB, 2		 ; Habilitando RB0, RB1 y RB2 para las ISR de RBIE
	
    BANKSEL WPUB
    BSF	    WPUB, 0
    BSF	    WPUB, 1
    BSF	    WPUB, 2		 ; Habilitando los Pullups en RB0, RB1 y RB2
    
RETURN
    
;******************************************************************************* 
;   SUBRUTINAS DE INTERRUPCIÓN
;*******************************************************************************

REINICIO_TMR0:
    
    BANKSEL TMR0
    MOVF    VALOR_TMR0, W	; N = VALOR_TMR0
    MOVWF   TMR0		; ASIGNAMOS EL VALOR N AL TMR0
    
    RETURN
    
REINICIO_TMR1:
    
    BANKSEL TMR1L
    MOVLW   0x95
    MOVWF   TMR1L		; CARGAR EL VALOR A LOW
    MOVLW   0xF5
    MOVWF   TMR1H		; CARGAR EL VALOR A HIGH
    
    RETURN
    
;_______________________________________________________________________________
;_______________________________________________________________________________
    
Hz:
    
    BANKSEL OPTION_REG
    BCF	    OPTION_REG, 0
    BSF	    OPTION_REG, 1	; PRESCALER 1:128 Para los Hz (VALOR MÁXIMO 7812)
    BSF	    OPTION_REG, 2
    
    CALL    REINICIO_TMR0
    
    RETURN
    
kHz:
    
    BANKSEL OPTION_REG
    BCF	    OPTION_REG, 0
    BSF	    OPTION_REG, 1	; PRESCALER 1:8 Para los kHz (VALOR MÁXIMO 125000)
    BCF	    OPTION_REG, 2
    
    CALL    REINICIO_TMR0
    
    RETURN
    
;_______________________________________________________________________________
;_______________________________________________________________________________
    
VARIACION_F:
    
    CHKB1H:
    
    BANKSEL PORTD
    BTFSS   PORTB, 0		    ; B0 = 0?
    CALL    INC_QUINCE		    ; INCREMENTAMOS 35 A LA VARIABLE
    BTFSS   PORTB, 0		    ; ANTIREBOTE BOTÓN INC.
    GOTO    $-1
    
    CHKB2H:
    
    BTFSS   PORTB, 1		    ; B1 = 0?
    CALL    DEC_QUINCE		    ; DECREMENTAMOS 35 A LA VARIABLE
    BTFSS   PORTB, 1		    ; ANTIREBOTE BOTÓN DEC.
    GOTO    $-1
    
    RETURN
    
INC_QUINCE:
    
    MOVLW   17			    ; MOVEMOS EL VALOR DE INCREMENTO
    ADDWF   VALOR_TMR0		    ; SUMAMOS 35 A LA VARIABLE DEL TMR0
    INCF    TABLITAS

    RETURN
    
DEC_QUINCE:
    
    MOVLW   17			    ; MOVEMOS EL VALOR DE DECREMENTO
    SUBWF   VALOR_TMR0		    ; RESTAMOS 35 A LA VARIABLE DEL TMR0
    DECF    TABLITAS
    
    RETURN	  

SIGNAL_TRIANGULAR:
    
    BTFSC   BANDERA_T, 0	    ; VERIFICAMOS EL PRIMER BIT DE LA BANDERA DE LA SEÑAL TRIANGULAR
    GOTO    REINICIO_TRIANGULAR	    ; Z = 1, LA BANDERA ESTÁ ENCENDIDA Y VAMOS AL REINICIO
    
INICIO_TRIANGULAR:
    
    MOVF    PORTD, W		    
    SUBLW   254			    ; LE RESTAMOS 254 AL PUERTO D PARA SABER SI YA LLEGÓ AL LÍMITE
    BTFSC   STATUS, 2	    	    ; Z = 0?
    BSF	    BANDERA_T, 0	    ; ENCENDEMOS LA BANDERA PARA SABER SI YA LLEGÓ AL TOPE
    INCF    PORTD		    ; INCREMENTAMOS EL PUERTO D
    
    RETURN
    
REINICIO_TRIANGULAR:
    
    DECF    PORTD		    ; DECREMETNAMOS EL PUERTO D
    BTFSC   STATUS, 2		    ; VERIFICAMOS SI YA LLEGÓ A 0 PARA SETEAR EL BIT DE LA BANDERA DE NUEVO A 0
    BCF	    BANDERA_T, 0	    ; SETEAMOS EN 0 EL VALOR DE LA BANDERA
    
    RETURN 
    
    
;******************************************************************************* 
;   SUBRUTINAS DE LOOP
;*******************************************************************************
    
MUX_DISPLAY:
    
    INCF    MULTIPLEXADO	; INCREMENTAMOS LA VARIABLE DEL MULTIPLEXADO		    
    
    DISPLAY_1:
    
    MUX	    MULTIPLEXADO, 1
    GOTO    DISPLAY_2		; VA A REVISAR EL SIGUIENTE DISPLAY
    CLRF    PORTC		; LIMPIAMOS EL PUERTO DE LOS TRANSISTORES
    
    MOVF    DISP_UNI, W		; MOVEMOS LA VARIABLE A W
    CALL    TABLA		; LLAMAMOS A LA TABLA PARA LA TRADUCCIÓN
    MOVWF   PORTA		; MOVEMOS EL VALOR AL PUERTO A
    
    BSF	    PORTC, 0		; ENCENDEMOS EL PRIMER DISPLAY
    
    RETURN
    
    DISPLAY_2:
    
    MUX	    MULTIPLEXADO, 2
    GOTO    DISPLAY_3		; VA A REVISAR EL SIGUIENTE DISPLAY
    CLRF    PORTC		; LIMPIAMOS EL PUERTO DE LOS TRANSISTORES
    
    MOVF    DISP_DEC, W		; MOVEMOS LA VARIABLE A W
    CALL    TABLA		; LLAMAMOS A LA TABLA PARA LA TRADUCCIÓN    
    MOVWF   PORTA		; MOVEMOS EL VALOR AL PUERTO A
    
    BSF	    PORTC, 1		; ENCENDEMOS EL SEGUNDO DISPLAY	
    
    RETURN
    
    DISPLAY_3:
    
    MUX	    MULTIPLEXADO, 3
    GOTO    DISPLAY_4		; VA A REVISAR EL SIGUIENTE DISPLAY
    CLRF    PORTC		; LIMPIAMOS EL PUERTO DE LOS TRANSISTORES
    
    MOVF    DISP_CEN, W		; MOVEMOS LA VARIABLE A W
    CALL    TABLA		; LLAMAMOS A LA TABLA PARA LA TRADUCCIÓN
    MOVWF   PORTA		; MOVEMOS EL VALOR AL PUERTO A
    
    BSF	    PORTC, 2		; ENCENDEMOS EL TERCER DISPLAY
    
    RETURN
    
    DISPLAY_4:
    
    MUX	    MULTIPLEXADO, 4
    RETURN			; REGRESA DE LA SUBRUTINA
    CLRF    PORTC		; LIMPIAMOS EL PUERTO DE LOS TRANSISTORES
    
    MOVF    DISP_MIL, W		; MOVEMOS LA VARIABLE A W
    CALL    TABLA		; LLAMAMOS A LA TABLA PARA LA TRADUCCIÓN
    MOVWF   PORTA		; MOVEMOS EL VALOR AL PUERTO A
    
    BSF	    PORTC, 3		; ENCENDEMOS EL CUARTO DISPLAY
    
    CLRF    MULTIPLEXADO	; REINICIAMOS LA VARIABLE DEL MUX
    
    RETURN

;_______________________________________________________________________________
;_______________________________________________________________________________
    
CAMBIO_VALOR1:
    
    MOVF    TABLITAS, W
    CALL    TABLAHz		; LLAMAMOS A LA TABLA DE HZ
    MOVWF   VALOR_HZ		; MOVEMOS EL VALOR OBTENIDO EN LA TABLA A LA VARIABLE PARA LA DIVISION
    
    RETURN
    
SWITCH_VAR:
    
    MOVF    UNIDADES, W		; MOVEMOS UNIDADES A W
    MOVWF   DISP_UNI		; MOVEMOS EL VALOR CORRESPONDIENTE A UNA VARIABLE PARA MANDAR AL DISPLAY
    MOVF    DECENAS, W		; MOVEMOS DECENAS A W
    MOVWF   DISP_DEC		; MOVEMOS EL VALOR CORRESPONDIENTE A UNA VARIABLE PARA MANDAR AL DISPLAY
    MOVF    CENTENAS, W		; MOVEMOS CENTENAS A W
    MOVWF   DISP_CEN		; MOVEMOS EL VALOR CORRESPONDIENTE A UNA VARIABLE PARA MANDAR AL DISPLAY
    
    RETURN
    
    
DIVISIONES1:  
    
    CLRF UNIDADES				    ; LIMPIAMOS LAS VARIABLES
    CLRF CENTENAS
    CLRF DECENAS
  
    DIVISION  VALOR_HZ, 100, CENTENAS, VALOR_HZ	    ; LLAMAMOS AL MACRO PARA LA FUNCIÓN
    DIVISION  VALOR_HZ, 10,  DECENAS, UNIDADES	    ; LLAMAMOS AL MACRO PARA LA FUNCIÓN
    
    RETURN
    
CAMBIO_VALOR2:
    
    MOVF    TABLITAS, W
    CALL    TABLAKHz		; LLAMAMOS A LA TABLA DE KHZ
    MOVWF   VALOR_KHZ		; MOVEMOS EL VALOR OBTENIDO EN LA TABLA A LA VARIABLE PARA LA DIVISION
    
    RETURN
    
DIVISIONES2:  
    
    CLRF UNIDADES				    ; LIMPIAMOS LAS VARIABLES
    CLRF CENTENAS   
    CLRF DECENAS
  
    DIVISION  VALOR_KHZ, 100, CENTENAS, VALOR_KHZ   ; LLAMAMOS AL MACRO PARA LA FUNCIÓN
    DIVISION  VALOR_KHZ, 10,  DECENAS, UNIDADES	    ; LLAMAMOS AL MACRO PARA LA FUNCIÓN
    
    RETURN
    
END