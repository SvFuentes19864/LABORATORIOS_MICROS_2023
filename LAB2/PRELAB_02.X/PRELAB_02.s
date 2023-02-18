;*******************************************************************************
;UNIVERSIDAD DEL VALLE DE GUATEMALA
;IE2023 Programación de microcontroladores
;Autor: Shagty Valeria Fuentes García
;Compilador: PIC-AS (v2.36), MPLAB X IDE (v6.00)
;Proyecto: Pre-laboratorio 02
;Hardware: PIC16F887
;Creado: 29/07/2023
;Última modificación: 29/07/2023
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
 
;*******************************************************************************
;VECTOR RESET
;*******************************************************************************
PSECT CODE, delta = 2, abs
 ORG 0X000
    GOTO Main
    
;*******************************************************************************
;CÓDIGO PRINCIPAL
;*******************************************************************************
PSECT CODE, delta = 2, abs
 ORG 0x100
 
Main:
    
    CALL C_PUERTOS
    CALL C_RELOJ
    
    BANKSEL PORTB
    CLRF PORTB		; LIMPIAMOS LOS PUERTOS PARA QUE EMPIECEN EN 0
    CLRF PORTC
    
LOOP:
CHKB1:
    BTFSS PORTC, 0      ; VERIFICAMOS SI EL PRIMER BOTÓN ESTÁ PRESIONADO
    GOTO CHKB2          ; SI NO ESTÁ PRESIONADO SE SALTA A CHKB2
    CALL BRC1           ; SI ESTÁ PRESIONADO LLAMA A LA SUBRUTINA DEL A_R1
CHKB2:
    BTFSS PORTC, 1	; VERIFICAMOS SI EL SEGUNDO BOTÓN ESTÁ PRESIONADO
    GOTO LOOP		; SI NO ESTÁ PRESIONADO VUELVE A LOOP
    CALL BRC2		; SI ESTÁ PRESIONADO LLAMA A LA SUBRUTINA DEL A_R2
    GOTO LOOP		; VUELVE AL LOOP
    
;*******************************************************************************
;Subrutinas para los antirebotes
;*******************************************************************************

BRC1:
    INCF PORTB, F	; INCREMENTAR EL PUERTO B
    BTFSC PORTC, 0	; VERIFICA SI EL BOTÓN SIGUE PRECIONADO
    GOTO $-1		; REGRESA AL ANTERIOR HASTA QUE SE SUELTA EL BOTÓN
    RETURN
BRC2:
    DECF PORTB, F	; DECREMENTA
    BTFSC PORTC, 1	; VERIFICA SI EL BOTÓN SIGUE PRECIONADO
    GOTO $-1		; REGRESA AL ANTERIOR HASTA QUE SE SUELTA EL BOTÓN
    RETURN
;*******************************************************************************
;CONFIGURACIONES
;*******************************************************************************
    
C_PUERTOS:
    
    BANKSEL ANSEL	; SOLO USAREMOS ENTRADAS Y SALIDAS DIGITALES
    CLRF ANSEL		; LIMPIAMOS
    CLRF ANSELH		; LIMPIAMOS
    
    BANKSEL TRISB
    MOVLW 0b00000000	; 8 BITS DE SALIDA
    MOVWF TRISB
    MOVLW 0b00000011	; 2 BITS DE ENTRADA PARA LOS BORONES
    MOVWF TRISC
    
    RETURN
    
C_RELOJ:
    
    BANKSEL OSCCON
    BSF OSCCON, 6
    BSF OSCCON, 5       ; A 4MHz --> (110)
    BCF OSCCON, 4
    BSF OSCCON, 0       ; SELECCIONAMOS OSCILADOR INTERNO
    
    RETURN
    
;*******************************************************************************
;FIN DEL CÓDIGO
;*******************************************************************************
    
END


