;*******************************************************************************
;UNIVERSIDAD DEL VALLE DE GUATEMALA
;IE2023 Programación de microcontroladores
;Autor: Shagty Valeria Fuentes García
;Compilador: PIC-AS (v2.36), MPLAB X IDE (v6.00)
;Proyecto: Post-Laboratorio 05
;Hardware: PIC16F887
;Creado: 18/02/2023
;Última modificación: 18/02/2023
;*******************************************************************************
    
PROCESSOR 16F887
#include <xc.inc>
    
;*******************************************************************************
;Palabra de configuración
;*******************************************************************************
;CONFIG1
    
    CONFIG FOSC=INTRC_NOCLKOUT ;OSCILADOR INTERNO SIN SALIDAS
    CONFIG WDTE=OFF            ;WDT DISEABLED (REINICIO REPETITIVO DEL PIC)
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
;VARIABLES
;*******************************************************************************
PSECT udata_shr
 
 W_TEMP:
    DS 1
 STATUS_TEMP:
    DS 1
 VALOR_CONT:		    ; VARIABLE PARA GUARDAR EL VALOR DEL CONTADOR BINARIO
    DS 1
 MULTIPLEXADO:		    ; VARIABLE PARA EL MULTIPLEXADO
    DS 1
 UNIDADES:		    ; VARIABLE PARA LAS UNIDADES
    DS 1
 DECENAS:		    ; VARIBALE PARA LAS DECENAS
    DS 1
 CENTENAS:		    ; VARIBALE PARA LAS CENTENAS
    DS 1
 DISP_UNI:
    DS 1
 DISP_DEC:
    DS 1
 DISP_CEN:
    DS 1
    
;*******************************************************************************
;VECTOR RESET
;*******************************************************************************
PSECT CODE, delta = 2, abs
 ORG 0X000
    GOTO Main
;******************************************************************************* 
; Vector ISR Interrupciones    
;*******************************************************************************
PSECT CODE, delta=2, abs
 ORG 0x0004
 
PUSH:
    MOVWF W_TEMP
    SWAPF STATUS, W
    MOVWF STATUS_TEMP
    
;******************************************************************************* 
; INTERRUPCIÓN DEL TMR0  
;*******************************************************************************
    
ITMR0:
    BTFSS T0IF
    GOTO IRBIF
    
    CALL REINICIO_TMR0
    
    INCF MULTIPLEXADO
    CALL MUX_DISPLAY
    
;******************************************************************************* 
; INTERRUPCIÓN DEL PUERTO B
;*******************************************************************************
    
IRBIF:
    BTFSS INTCON, 0
    GOTO POP
    
    CALL VERIF_BOTONES
    
POP:
    SWAPF STATUS_TEMP, W
    MOVWF STATUS
    SWAPF W_TEMP, F
    SWAPF W_TEMP, W
    RETFIE		    ;REGRESA DE LA INTERRUPCIÓN
    
;*******************************************************************************
;CÓDIGO PRINCIPAL
;*******************************************************************************
PSECT CODE, delta = 2, abs
 ORG 100h

TABLA:			; Tabla de la traduccion de binario a hex
    clrf    PCLATH
    bsf	    PCLATH, 0
    andlw   0x0A	; Se pone como limite 16 , en hex F
    addwf   PCL, F
    retlw   0111111B	; 0
    retlw   0000110B	; 1
    retlw   1011011B	; 2
    retlw   1001111B	; 3
    retlw   1100110B	; 4
    retlw   1101101B	; 5
    retlw   1111101B	; 6
    retlw   0000111B	; 7
    retlw   1111111B	; 8
    retlw   1101111B	; 9
;    retlw   1110111B	; A
;    retlw   1111100B	; B
;    retlw   0111001B	; C
;    retlw   1011110B	; D
;    retlw   1111001B	; E
;    retlw   1110001B	; F
 
PSECT CODE, delta = 2, abs
 ORG 200h
 
Main:
    
    CALL C_PUERTOS
    CALL C_RELOJ
    CALL C_TMR0
    CALL C_RBIF
    CALL C_INT
    
    BANKSEL PORTB
    CLRF PORTB
    CLRF PORTA
    CLRF PORTC
    CLRF PORTD
    CLRF VALOR_CONT
    CLRF MULTIPLEXADO
    CLRF UNIDADES
    CLRF DECENAS
    CLRF CENTENAS
    
;*******************************************************************************
;LOOP PRINCIPAL
;*******************************************************************************
    
LOOP: 
    
    CALL DIVISIONES
    CALL CAMBIO_VALORES
    
    GOTO LOOP

;*******************************************************************************
;CONFIGURACIONES
;*******************************************************************************
    
C_PUERTOS:		    ; CONFIGURACIÓN DE PUERTOS
    BANKSEL ANSEL
    CLRF ANSEL
    CLRF ANSELH
    
    BANKSEL TRISB
    MOVLW 0b00000000
    MOVWF TRISA		    ; PUERTO PARA LOS DISPLAYS
    MOVWF TRISC		    ; PUERTO PARA EL CONTADOR BINARIO 8 BITS
    MOVWF TRISD		    ; PUERTO PARA LOS TRANSISTORES
    MOVLW 0b00000011
    MOVWF TRISB		    ; PUERTO PARA LOS BOTONES

RETURN
    
C_RELOJ:		    ; CONFIGURACIÓN DEL RELOJ
    BANKSEL OSCCON
    BSF OSCCON, 6
    BSF OSCCON, 5           ; IRCF = 110 4MHz
    BCF OSCCON, 4
    BSF OSCCON, 0           ; Oscilador interno
    
RETURN
    
C_INT:			    ; CONFIGURACIÓN DE INTERRUPCIONES
    BANKSEL INTCON
    CLRF INTCON
    BSF INTCON, 6	    ; SE HABILITA interrupN LAS INTERRUPCIONES PERIFÉRICAS PEIE
    BSF INTCON, 5	    ; SE HABILITA LA INTERRUPCIÓN DEL TIMER 0
    BSF INTCON, 3	    ; SE HABILITA LA INTERRUPCIÓN RBIE  
    BCF	INTCON, 2
    BSF INTCON, 7	    ; Se habilitan todas las interrupciones por el GIE
    
RETURN
    
C_TMR0:			    ; CONFIGURACIÓN TIMER 0
    BANKSEL OPTION_REG
    BCF OPTION_REG, 7	    ; HABILITANDO PULLUPS INTERNOS PUERTO B
    BCF OPTION_REG, 6	
    
    BCF OPTION_REG, 5	    ; TOCS = 0
    BCF OPTION_REG, 3	    ; HABILITANDO EL PRESCALER
    
    BCF OPTION_REG, 0
    BSF OPTION_REG, 1	    ; PRESCALER 1:128
    BSF OPTION_REG, 2
    
    BANKSEL TMR0
    CALL REINICIO_TMR0
    
RETURN
    
C_RBIF:
    BANKSEL IOCB
    BSF IOCB, 0
    BSF IOCB, 1		    ; Habilitando RB0 y RB1 para las ISR de RBIE
	
    BANKSEL WPUB
    BSF WPUB, 0
    BSF WPUB, 1		    ; Habilitando los Pullups en RB0 y RB1
    
RETURN
    
;******************************************************************************* 
; SUBRUTINAS DE LOOP
;*******************************************************************************    
    
MUX_DISPLAY:
    
    DISPLAY_1:
    
    MOVF MULTIPLEXADO, W    ; MOVEMOS MUX A W
    SUBLW 1		    ; LE RESTAMOS 1 PARA VER SI SE ENCUENTRA EN ESTE DISPLAY
    BTFSS STATUS, 2	    ; Z = 1?
    GOTO DISPLAY_2	    ; VA A REVISAR EL SIGUIENTE DISPLAY
    
    BSF PORTD, 0	    ; PRIMER TRANSISTOR ENCENDIDO
    BCF PORTD, 1
    BCF PORTD, 2
    
    MOVF DISP_UNI, W
    CALL TABLA
    MOVWF PORTA
    
    RETURN
    
    DISPLAY_2:
    
    MOVF MULTIPLEXADO, W    ; MOVEMOS MUX A W
    SUBLW 2		    ; LE RESTAMOS 1 PARA VER SI SE ENCUENTRA EN ESTE DISPLAY
    BTFSS STATUS, 2	    ; Z = 1?
    GOTO DISPLAY_3	    ; VA A REVISAR EL SIGUIENTE DIPLAY
    
    BCF PORTD, 0	    
    BSF PORTD, 1	    ; SEGUNDO TRANSISTOR ENCENDIDO
    BCF PORTD, 2
    
    MOVF DISP_DEC, W
    CALL TABLA
    MOVWF PORTA
    
    RETURN
    
    DISPLAY_3:
    
    MOVF MULTIPLEXADO, W    ; MOVEMOS MUX A W
    SUBLW 3		    ; LE RESTAMOS 1 PARA VER SI SE ENCUENTRA EN ESTE DISPLAY
    BTFSS STATUS, 2	    ; Z = 1?
    RETURN		    ; VA A REVISAR EL SIGUIENTE DIPLAY
    
    BCF PORTD, 0	    
    BCF PORTD, 1	    
    BSF PORTD, 2	    ; TERCER TRANSISTOR ENCENDIDO
    
    MOVF DISP_CEN, W
    CALL TABLA
    MOVWF PORTA
    CLRF MULTIPLEXADO

    RETURN
			
;_______________________________________________________________________________
;_______________________________________________________________________________
    
CAMBIO_VALORES:
    
    MOVF UNIDADES, W
    MOVWF DISP_UNI
    MOVF DECENAS, W
    MOVWF DISP_DEC
    MOVF CENTENAS, W
    MOVWF DISP_CEN
    RETURN
    
    
DIVISIONES:  
    
    CLRF UNIDADES
    CLRF CENTENAS
    CLRF DECENAS
    
    MOVF PORTC, W
    MOVWF VALOR_CONT
    
DIVISION_CENTENAS:
    
    MOVLW 100		    ; MOVEMOS EL VALOR 100 A W PARA RESTAR
    SUBWF VALOR_CONT, F	    ; RESTAMOS EL VALOR A LA VARIABLE DEL CONTADOR
    INCF CENTENAS	    ; INCREMENTAMOS CENTENAS
    BTFSC STATUS, 1	    ; C = 1?
    GOTO $-4		    ; C = 0, NO HAY CARRY AÚN
    DECF CENTENAS	    ; CONTRARRESTAMOS UNO EN CENTENAS
    ADDWF VALOR_CONT, F	    ; LE SUMAMOS 100 AL VALOR DEL CONTADOR PARA QUITAR EL NEGATIVO
    CALL DIVISION_DECENAS
    
    RETURN
 
DIVISION_DECENAS:
    
    MOVLW 10
    SUBWF VALOR_CONT, F
    INCF DECENAS
    BTFSC STATUS, 1
    GOTO $-4
    DECF DECENAS
    ADDWF VALOR_CONT, F
    CALL DIVISION_UNIDADES
    
    RETURN

DIVISION_UNIDADES:
    
    MOVLW 1
    SUBWF VALOR_CONT, F
    INCF UNIDADES
    BTFSC STATUS, 2	    ; Z = 1?
    GOTO $-4
    DECF UNIDADES	    ; Z = 1
    
    RETURN
    
;******************************************************************************* 
; SUBRUTINAS DE INTERRUPCIÓN
;*******************************************************************************

REINICIO_TMR0:
    
    BANKSEL TMR0
    MOVLW 178		    ; N = 256 - (4MHz*10ms)/(4*128)
    MOVWF TMR0		    ; ASIGNAMOS EL VALOR N AL TMR0 DESBORDE 4mS
    BCF T0IF	    	    ; BORRAMOS LA BANDERA T0IF
    
    RETURN
    
VERIF_BOTONES:
    
    CHKB1:
    BTFSS PORTB, 1	    ; BOTÓN 1 ESTÁ PRESIONADO?
    GOTO CHKB2		    ; REVISA EL BOTÓN 2
    INCF PORTC, F	    ; INCREMENTA EL PUERTO C
    BTFSS PORTB, 1	    ; ANTIREBOTE DEL BOTÓN DE CAMBIO
    GOTO $-1
    BCF INTCON, 0	    ; LIMPIA LA BANDERA RBIF
    
    CHKB2:
    BTFSS PORTB, 0	    ; BOTÓN 2 ESTÁ PRESIONADO?
    GOTO $+5		    ; SE VA A POP
    DECF PORTC, F	    ; DECREMENTA EL PUERTO C
    BTFSS PORTB, 0	    ; ANTIREBOTE DEL BOTÓN DE CAMBIO
    GOTO $-1
    BCF INTCON, 0	    ; LIMPIA LA BANDERA RBIF
    
    RETURN
    
;*******************************************************************************
;CONFIGURACIONES
;*******************************************************************************
    
END