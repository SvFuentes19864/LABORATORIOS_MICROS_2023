;*******************************************************************************
;UNIVERSIDAD DEL VALLE DE GUATEMALA
;IE2023 Programación de microcontroladores
;Autor: Shagty Valeria Fuentes García
;Compilador: PIC-AS (v2.36), MPLAB X IDE (v6.00)
;Proyecto: Post-Laboratorio 04
;Hardware: PIC16F887
;Creado: 16/02/2023
;Última modificación: 16/02/2023
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
 BANDERA_C2:
    DS 1
 UNI_SEG:
    DS 1
 DEC_SEG:
    DS 1
 VERIFZUS:
    DS 1
 VERIFZDS:
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
    BTFSS INTCON, 2
    GOTO IRBIF
    
    CALL REINICIO_TMR0
    
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
    andlw   0x0F	; Se pone como limite 16 , en hex F
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
    retlw   1110111B	; A
;    retlw   1111100B	; B
;    retlw   0111001B	; C
;    retlw   1011110B	; D
;    retlw   1111001B	; E
;    retlw   1110001B	; F
 
PSECT CODE, delta = 2, abs
 ORG 200h
 
Main:
    CALL C_RELOJ
    CALL C_PUERTOS
    CALL C_TMR0
    CALL C_RBIF
    CALL C_INT
    
    BANKSEL PORTB
    CLRF PORTB
    CLRF PORTC
    CLRF PORTA
    CLRF BANDERA_C2
    CLRF VERIFZUS
    CLRF UNI_SEG
    CLRF DEC_SEG
    CLRF VERIFZDS
    
;*******************************************************************************
;LOOP PRINCIPAL
;*******************************************************************************
    
LOOP:
CONTADOR2:
    MOVF UNI_SEG, W
    PAGESEL TABLA
    CALL TABLA
    PAGESEL CONTADOR2
    MOVWF PORTA
    
    MOVF DEC_SEG, W
    PAGESEL TABLA
    CALL TABLA
    PAGESEL CONTADOR2
    MOVWF PORTD
    
    MOVF BANDERA_C2, W	    ; MOVEMOS LA VARIABLE DEL CONTADOR 2 A W
    SUBLW 50		    ; VERIFICAMOS SI YA PASARON 1000 ms
    BTFSS STATUS, 2	    ; VERIFICAMOS SI LA BANDERA Z = 1?
    GOTO LOOP		    ; Z = 0, VAMOS A LOOP
    CLRF BANDERA_C2
    BCF STATUS, 2
    
    INCF VERIFZUS, F
    MOVF VERIFZUS, W
    SUBLW 10
    BTFSC STATUS, 2
    GOTO REINICIO_US
    INCF UNI_SEG, F
    GOTO LOOP
    
REINICIO_US:
    CLRF UNI_SEG
    BCF STATUS, 2
    CLRF VERIFZUS
    INCF DEC_SEG, F
    INCF VERIFZDS
    
    MOVF VERIFZDS, W
    SUBLW 6
    BTFSC STATUS, 2
    GOTO REINICIO_DS
    GOTO LOOP
    
REINICIO_DS:
    CLRF DEC_SEG
    BCF STATUS, 2
    CLRF VERIFZDS
    
    GOTO LOOP

;*******************************************************************************
;CONFIGURACIONES
;*******************************************************************************
C_PUERTOS:		    ; CONFIGURACIÓN DE PUERTOS
    BANKSEL ANSEL
    CLRF ANSEL
    CLRF ANSELH
    
    BANKSEL TRISB
    MOVLW 0b11110000
    MOVWF TRISC
    CLRF TRISA
    CLRF TRISD
    BSF TRISB, 0	    ; BOTÓN 1
    BSF TRISB, 1	    ; BOTÓN 2

RETURN
    
C_RELOJ:		    ; CONFIGURACIÓN DEL RELOJ
    BANKSEL OSCCON
    BSF OSCCON, 6
    BSF OSCCON, 5           ;IRCF = 110 4MHz
    BCF OSCCON, 4
    BSF OSCCON, 0           ;Oscilador interno
    
RETURN
    
C_INT:			    ; CONFIGURACIÓN DE INTERRUPCIONES
    BANKSEL INTCON
    CLRF INTCON
    BSF INTCON, 6	    ; SE HABILITA interrupN LAS INTERRUPCIONES PERIFÉRICAS PEIE
    BSF INTCON, 5	    ; SE HABILITA LA INTERRUPCIÓN T0IE
    BSF INTCON, 2	    ; SE HABILITA LA BANDERA T0IF
    BSF INTCON, 3	    ; SE HABILITA LA INTERRUPCIÓN RBIE
    BSF INTCON, 7	    ; Se habilitan todas las interrupciones por el GIE
    
RETURN
    
C_TMR0:			    ; CONFIGURACIÓN TIMER 0
    BANKSEL OPTION_REG
    BCF OPTION_REG, 7	    ; HABILITANDO PULLUPS INTERNOS PUERTO B
    BCF OPTION_REG, 5	    
    BCF OPTION_REG, 3	    ; HABILITANDO EL PRESCALER
    
    BCF OPTION_REG, 0
    BSF OPTION_REG, 1	    ; PRESCALER 1:128
    BSF OPTION_REG, 2
    
    BANKSEL TMR0
    MOVLW 100		    ; N = 256 - (4MHz*20ms)/(4*128)
    MOVWF TMR0		    ; ASIGNAMOS EL VALOR N AL TMR0 DESBORDE 20mS
    BCF INTCON, 2	    ; BORRAMOS LA BANDERA T0IF
    
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

REINICIO_TMR0:
    
    BANKSEL TMR0
    MOVLW 100		    ; N = 256 - (4MHz*20ms)/(4*128)
    MOVWF TMR0		    ; ASIGNAMOS EL VALOR N AL TMR0 DESBORDE 20mS
    BCF INTCON, 2	    ; BORRAMOS LA BANDERA T0IF
    
    INCF BANDERA_C2, F	    ; INCREMENTA LA VARIABLE DEL CONTADOR 2
    
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
    GOTO POP		    ; SE VA A POP
    DECF PORTC, F	    ; DECREMENTA EL PUERTO C
    BTFSS PORTB, 0	    ; ANTIREBOTE DEL BOTÓN DE CAMBIO
    GOTO $-1
    BCF INTCON, 0	    ; LIMPIA LA BANDERA RBIF
    
    RETURN
    
;*******************************************************************************
;CONFIGURACIONES
;*******************************************************************************
    
END