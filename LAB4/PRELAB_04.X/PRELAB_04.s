;*******************************************************************************
;UNIVERSIDAD DEL VALLE DE GUATEMALA
;IE2023 Programación de microcontroladores
;Autor: Shagty Valeria Fuentes García
;Compilador: PIC-AS (v2.36), MPLAB X IDE (v6.00)
;Proyecto: Pre-Laboratorio 04
;Hardware: PIC16F887
;Creado: 13/02/2023
;Última modificación: 13/02/2023
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
    
IRBIF:
    BTFSS INTCON, 0	    ; VERIFICA SI LA BANDERA ESTÁ ACTIVA
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

    CALL C_PUERTOS
    CALL C_RELOJ
    CALL C_RBIE
    CALL C_INTERRUPCIONES
   

    BANKSEL PORTC
    CLRF PORTC
    CLRF PORTB    
    
;*******************************************************************************
;LOOP INFINITO
;*******************************************************************************
    
LOOP: 
    GOTO LOOP
    
;*******************************************************************************
;CONFIGURACIONES
;*******************************************************************************
    
C_PUERTOS:
    
    BANKSEL ANSEL	    ; SOLO USAREMOS ENTRADAS Y SALIDAS DIGITALES
    CLRF ANSEL		    ; LIMPIAMOS
    CLRF ANSELH		    ; LIMPIAMOS
    
    BANKSEL TRISC
    CLRF TRISC
    CLRF TRISB
    
    BANKSEL TRISB
    MOVLW 0b11110000	    ; 4 BITS DE SALIDA PARA CONTADOR
    MOVWF TRISC
    MOVLW 0b00000011	    ; 4 BITS DE SALIDA PARA CONTADOR
    MOVWF TRISB
    
    RETURN
    
C_RELOJ:
    
    BANKSEL OSCCON
    BSF OSCCON, 6
    BSF OSCCON, 5            ; A 4MHz --> (110)
    BCF OSCCON, 4
    BSF OSCCON, 0            ; SELECCIONAMOS OSCILADOR INTERNO
    
    RETURN
    
C_INTERRUPCIONES:
    
    BANKSEL INTCON
    CLRF INTCON
    BSF INTCON, 6	    ; SE HABILITAN LAS INTERRUPCIONES PERIFÉRICAS PEIE
    BSF INTCON, 3	    ; SE HABILITA LA INTERRUPCIÓN RBIE
    BSF INTCON, 0	    ; SE HABILITA LA BANDERA DE RBIF
    BSF INTCON, 7	    ; SE HABILITAN LAS INTERRRUPCIONES GLOBALES GIE
    
    RETURN
    
C_RBIE:
    
    BANKSEL IOCB
    BSF IOCB, 0
    BSF IOCB, 1		    ; HABILITANDO RB0 Y RB1 PARA LAS ISR DE RBIE
    
    BANKSEL OPTION_REG
    BCF OPTION_REG, 7	    ; HABILITANDO PULLUPS PUERTO B
    
    BSF WPUB, 0
    BSF WPUB, 1		    ; HABILITANDO LOS PULLUPS EN RB0 Y RB1
    
    RETURN
    
;*******************************************************************************
;SUBRUTINAS DE INTERRUPCIÓN
;*******************************************************************************    
    
VERIF_BOTONES:
    
    CHKB1:
    BTFSC PORTB, 0	    ; VERIFICA SI SE PRESIONA EL BOTÓN 1
    GOTO CHKB2
    INCF PORTC, F	    ; INCREMENTA EL CONTADOR
    BTFSS PORTB, 1	    ; ANTIREBOTE DEL BOTÓN DE CAMBIO
    GOTO $-1
    BCF INTCON, 0	    ; LIMPIA LA BANDERA
    GOTO POP
    
    CHKB2:
    BTFSC PORTB, 1	    ; VERIFICA SI SE PRESIONA EL BOTÓN 1
    GOTO POP
    DECF PORTC, F	    ; DECREMENTA EL CONTADOR
    BTFSS PORTB, 0	    ; ANTIREBOTE DEL BOTÓN DE CAMBIO
    GOTO $-1
    BCF INTCON, 0	    ; LIMPIA LA BANDERA    
    
    RETURN
    
;*******************************************************************************
;FIN DEL CÓDIGO
;*******************************************************************************
    
END