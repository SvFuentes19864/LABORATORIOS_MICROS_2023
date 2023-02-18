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
    CLRF PORTA
    CLRF PORTD
    
LOOP:
CHKB1:
    BTFSS PORTC, 0      ; VERIFICAMOS SI EL PRIMER BOTÓN ESTÁ PRESIONADO
    GOTO CHKB2          ; SI NO ESTÁ PRESIONADO SE SALTA A CHKB2
    CALL BRC1           ; SI ESTÁ PRESIONADO LLAMA A LA SUBRUTINA DEL A_R1
    
CHKB2:
    BTFSS PORTC, 1
    GOTO CHKB3		; IR A VERIFICAR BOTÓN 3
    CALL BRC2		; SUBRUTINA ANTIREBOTE B2
    
CHKB3:
    BTFSS PORTC, 2
    GOTO CHKB4		; IR A VERIFICAR BOTÓN 4
    CALL BRC3		; SUBRUTINA ANTIREBOTE B3
    
CHKB4:
    BTFSS PORTC, 3
    GOTO CHKBR		; IR A VERIFICAR BOTÓN 5	
    CALL BRC4		; SUBRUTINA ANTIREBOTE B4
    
CHKBR:
    BTFSS PORTC, 4
    GOTO LOOP		; IR A LOOP
    CALL BRCR		; SUBRUTINA DEL RESULTADO
    GOTO LOOP		; REGRESAR AL LOOP Y EMPIEZA DE NUEVO
    
;*******************************************************************************
;Subrutinas para los antirebotes
;*******************************************************************************

BRC1:
    INCF PORTB, F	; INCREMENTAR EL PUERTO B
    BTFSC PORTC, 0	; VERIFICA SI EL BOTÓN SIGUE PRECIONADO
    GOTO $-1		; REGRESA AL ANTERIOR HASTA QUE SE SUELTA EL BOTÓN
    RETURN
BRC2:
    DECF PORTB, F	; DECREMENTA EL PUERTO B
    BTFSC PORTC, 1	; VERIFICA SI EL BOTÓN SIGUE PRECIONADO
    GOTO $-1		; REGRESA AL ANTERIOR HASTA QUE SE SUELTA EL BOTÓN
    RETURN
BRC3:
    INCF PORTA, F	; INCREMENTAR EL PUERTO A
    BTFSC PORTC, 2	; VERIFICA SI EL BOTÓN SIGUE PRECIONADO
    GOTO $-1		; REGRESA AL ANTERIOR HASTA QUE SE SUELTA EL BOTÓN
    RETURN
BRC4:
    DECF PORTA, F	; DECREMENTA EL PUERTO A
    BTFSC PORTC, 3	; VERIFICA SI EL BOTÓN SIGUE PRECIONADO
    GOTO $-1		; REGRESA AL ANTERIOR HASTA QUE SE SUELTA EL BOTÓN
    RETURN
    
BRCR:
    MOVF PORTB, W	; MOVEMOS EL NÚMERO QUE ESTÁ EN PUERTO B A W
    ADDWF PORTA, W	; SUMAMOS W (PORTB) CON PORTA Y GUARDAMOS EN W
    MOVWF PORTD	    	; MOVEMOS EL RESULTADO AL PUERTO D
    BTFSC PORTC, 4	; VERIFICA SI EL BOTÓN SIGUE PRECIONADO
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
    MOVLW 0b11110000	; 4 BITS DE SALIDA PARA CONTADOR 1 y 2
    MOVWF TRISB
    MOVWF TRISA
    MOVLW 0b11100000	; 5 BITS DE SALIDA PARA EL RESULTADO Y EL CARRY
    MOVWF TRISD
    MOVLW 0b00001111	; 2 BITS DE ENTRADA PARA LOS BOTONES
    MOVWF TRISC
    
    RETURN
    
C_RELOJ:
    
    BANKSEL OSCCON
    BSF OSCCON, 6
    BCF OSCCON, 5       ; A 1MHz --> (100)
    BCF OSCCON, 4
    BSF OSCCON, 0       ; SELECCIONAMOS OSCILADOR INTERNO
    
    RETURN
    
;*******************************************************************************
;FIN DEL CÓDIGO
;*******************************************************************************
    
END


