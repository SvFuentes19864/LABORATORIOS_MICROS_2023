;*******************************************************************************
;UNIVERSIDAD DEL VALLE DE GUATEMALA
;IE2023 Programación de microcontroladores
;Autor: Shagty Valeria Fuentes García
;Compilador: PIC-AS (v2.36), MPLAB X IDE (v6.00)
;Proyecto: Laboratorio 01
;Hardware: PIC16F887
;Creado: 19/01/2022
;Última modificación: 19/01/2022
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
    
PSECT udata_bank0		; MEMORIA COMÚN
	
    CONT_SMALL:			; VARIABLE PARA CONTADOR PEQUEÑO
	DS 1
    CONT_BIG:			; VARIABLE PARA CONTADOR GRANDE
	DS 1
	    
;*******************************************************************************
;VECTOR RESET
;*******************************************************************************
	    
PSECT CODE, delta = 2, abs
 ORG 0X000			; POSICIÓN 0000h PARA EL RESET
    GOTO Main
    
;*******************************************************************************
;CÓDIGO PRINCIPAL
;*******************************************************************************
PSECT CODE, delta = 2, abs
 ORG 0x100			; POSICIÓN DEL CÓDIGO
 
Main:
    BSF STATUS, 5		; BANCO 11
    BSF STATUS, 6		
    CLRF ANSEL			; PINES DIGITALES APAGADOS
    CLRF ANSELH
    
    BSF STATUS, 5
    BCF STATUS, 6		; BANCO 01
    CLRF TRISA			; PUERTO A COMO SALIDA
    CLRF PORTA
    
    BCF STATUS, 5
    BCF STATUS, 6		; BANCO 00
    
    CLRF PORTA
    
    
;*******************************************************************************
;LOOP PRINCIPAL
;*******************************************************************************
    
LOOP:
    INCF PORTA, 1		; INCREMENTA EL BIT 1 DEL PUERTO A
    CALL DELAY_BIG		; LLAMA A LA SUBRUTINA DELAY GRANDE
    GOTO LOOP			; LOOP INFINITO
    
;*******************************************************************************
;SUBRUTINAS
;*******************************************************************************
    
DELAY_BIG:
    MOVLW 192			; VALOR INICIAL DEL CONTADOR 1
    MOVWF CONT_BIG		; SE MUEVE EL VALOR DE W A LA VARIABLE 1
    CALL DELAY_SMALL		; MANDAMOS A LLAMAR AL DELAY PEQUEÑO 
    DECFSZ CONT_BIG, 1		; DECREMENTA EL CONTADOR Y SI EL RESULTADO ES 0 SE SALTA LA SIGUIENTE LÍNEA
    GOTO $-2			; EJECUTA DOS LÍNEAS ATRÁS
    RETURN			; REGRESA DE LA SUBRUTINA
    
DELAY_SMALL:
    MOVLW 165			; VALOR INICIAL DEL CONTADOR
    MOVWF CONT_SMALL		; SE MUEVE EL VALOR DE W A LA VARIABLE
    DECFSZ CONT_SMALL, 1	; DECREMENTA EL CONTADOR Y SI EL RESULTADO ES 0 SE SALTA LA SIGUIENTE LÍNEA
    GOTO $-1			; EJECUTA LA LÍNEA ANTERIOR
    RETURN			; REGRESA DE LA SUBRUTINA
    
END