;*******************************************************************************
;UNIVERSIDAD DEL VALLE DE GUATEMALA
;IE2023 Programación de microcontroladores
;Autor: Shagty Valeria Fuentes García
;Compilador: PIC-AS (v2.36), MPLAB X IDE (v6.00)
;Proyecto: Pre-Laboratorio 05
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
PSECT udata
 W_TEMP:
    DS 1
 STATUS_TEMP:
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
 ORG 0x100
 
Main:
    CALL C_RELOJ
    CALL C_PUERTOS
    CALL C_TMR0
    CALL C_RBIF
    CALL C_INT
    
    BANKSEL PORTB
    CLRF PORTB
    CLRF PORTC
    
;*******************************************************************************
;LOOP PRINCIPAL
;*******************************************************************************
    
LOOP:    
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
    MOVWF TRISC
    MOVLW 0b00000011
    MOVWF TRISB

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
    BSF INTCON, 3	    ; SE HABILITA LA INTERRUPCIÓN RBIE
    BSF INTCON, 7	    ; Se habilitan todas las interrupciones por el GIE
    
RETURN
    
C_TMR0:			    ; CONFIGURACIÓN TIMER 0
    BANKSEL OPTION_REG
    BCF OPTION_REG, 7	    ; HABILITANDO PULLUPS INTERNOS PUERTO B
    BCF OPTION_REG, 6	    
    
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
; SUBRUTINAS DE INTERRUPCIÓN
;*******************************************************************************
    
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