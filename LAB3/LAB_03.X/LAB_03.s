;*******************************************************************************
;UNIVERSIDAD DEL VALLE DE GUATEMALA
;IE2023 Programación de microcontroladores
;Autor: Shagty Valeria Fuentes García
;Compilador: PIC-AS (v2.36), MPLAB X IDE (v6.00)
;Proyecto: Laboratorio 03
;Hardware: PIC16F887
;Creado: 06/02/2023
;Última modificación: 06/02/2023
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
 DISPLAY:
    DS 1

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
    retlw   1111100B	; B
    retlw   0111001B	; C
    retlw   1011110B	; D
    retlw   1111001B	; E
    retlw   1110001B	; F
    
PSECT CODE, delta = 2, abs
 ORG 200h
 
Main:
    CALL C_PUERTOS
    CALL C_RELOJ
    
    BANKSEL PORTB
    CLRF PORTB
    CLRF PORTC
    CLRF DISPLAY
    
LOOP:
    
CHKB1:
    BTFSS PORTC, 0      ; VERIFICAMOS SI EL PRIMER BOTÓN ESTÁ PRESIONADO
    GOTO CHKB2          ; B1 = 0, VA A VCERIFICAR EL BOTÓN 2
    CALL BRC1           ; LLAMA A LA SUBRUTINA DEL BOTÓN 1
CHKB2:
    BTFSS PORTC, 1	; VERIFICAMOS SI EL SEGUNDO BOTÓN ESTÁ PRESIONADO
    GOTO LOOP		; B2 = 0, REGRESA A LOOP
    CALL BRC2		; LLAMA A LA SUBRUTINA DEL BOTÓN 2
    GOTO LOOP		; VUELVE AL LOOP
    
;*******************************************************************************
;SUBRUTINAS
;*******************************************************************************
    
BRC1:
    INCF DISPLAY, F	; Incrementa
    MOVF DISPLAY, W	; Se mueve el valor del contador a W
    CALL TABLA		; Se llama a la tabla para la traducción
    MOVWF PORTB		; Se envía el número al puerto B
    BTFSC PORTC, 0	; Verifica si el botón sigue presionado
    GOTO $-1		; Hace un loop a si mismo hasta que se suelta el botón
    RETURN
BRC2:
    DECF DISPLAY, F	; Decrementa
    MOVF DISPLAY, W	; Se mueve el valor del contador a W
    CALL TABLA		; Se llama a la tabla para la traducción
    MOVWF PORTB		; Se envía el número al puerto B
    BTFSC PORTC, 1
    GOTO $-1
    RETURN
 
;*******************************************************************************
;CONFIGURACIONES
;*******************************************************************************
    
C_PUERTOS:
    
    BANKSEL ANSEL	; SOLO USAREMOS ENTRADAS Y SALIDAS DIGITALES
    CLRF ANSEL		; LIMPIAMOS
    CLRF ANSELH		; LIMPIAMOS
    
    BANKSEL TRISB
    MOVLW 0b10000000	;SALIDAS
    MOVWF TRISB
    MOVLW 0b00000011	;ENTRADAS
    MOVWF TRISC
    
    RETURN
    
C_RELOJ:
    
    BANKSEL OSCCON
    BSF OSCCON, 6
    BCF OSCCON, 5       ; A 2MHz --> (101)
    BSF OSCCON, 4
    BSF OSCCON, 0       ; SELECCIONAMOS OSCILADOR INTERNO
    
    RETURN
    
;*******************************************************************************
;FIN DEL CÓDIGO
;*******************************************************************************
    
END

