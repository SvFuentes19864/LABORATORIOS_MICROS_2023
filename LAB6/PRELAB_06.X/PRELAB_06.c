/*IE2023 PROGRAMACIÓN DE MICROCONTROLADORES
 * File:   PRELAB4.c
 * Author: SHAGTY VALERIA FUENTES GARCÍA
 * Carnet: 19864
 * Proyecto: PRE-LABORATORIO 6
 * Hardware: PIC16F887
 * Created on 25 de marzo de 2023 */

// CONFIG1
#pragma config FOSC = INTRC_NOCLKOUT// Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
#pragma config PWRTE = OFF      // Power-up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = OFF      // RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
#pragma config CP = OFF         // Code Protection bit (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)
#pragma config BOREN = OFF      // Brown Out Reset Selection bits (BOR disabled)
#pragma config IESO = OFF       // Internal External Switchover bit (Internal/External Switchover mode is disabled)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
#pragma config LVP = OFF        // Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

// CONFIG2
#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits (Write protection off)

#include <xc.h>
#include <pic16f887.h>
#include <stdint.h>
#include <stdio.h>
#define _XTAL_FREQ 4000000

/*******************************************************************************
 * VARIABLES
 ******************************************************************************/

uint8_t bandera;

/*******************************************************************************
 * PROTOTIPOS DE FUNCIONES
 ******************************************************************************/

void setup(void);

/*******************************************************************************
 * INTERRUPCIONES
 ******************************************************************************/

void __interrupt() isr(void) {
    
    if (T0IF) {             // Si se ha producido una interrupción del Timer0
        T0IF = 0;           // Limpiamos la bandera de interrupción
        TMR0 = 15;          // Le cargamos el valor al tmr0 de nuevo
        
        if (bandera == 0) {
            PORTC = 0b00000001;
            bandera = 1;
        }
        else {
            PORTC = 0;
            bandera = 0;
        }
    }
}

/*******************************************************************************
 * CÓDIGO PRINCIPAL
 ******************************************************************************/

void main(void) {
    setup();

/*******************************************************************************
 * LOOP PRINCIPAL
 ******************************************************************************/
    
    while(1){
    }
}

/*******************************************************************************
 * FUNCIÓN DE CONFIGURACIÓN
 ******************************************************************************/

void setup(void){
    
//________________________CONFIGURACIÓN DE PUERTOS______________________________
    
    ANSEL = 0;
    ANSELH = 0;
    
    TRISC0 = 0;                 // Configuramos el puerto RC0 como salida
    PORTC = 0;                  // Limpiamos el puerto C
    
//______________________CONFIGURACIÓN DEL OSCILADOR_____________________________
    
    OSCCONbits.IRCF = 0b0110;   // OSCILADOR INTERNO A 4Mhz
    OSCCONbits.SCS = 1;         // HABILITANDO RELOJ INTERNO
    
//_________________________CONFIGURACIÓN DEL TMR0_______________________________
    
    OPTION_REGbits.T0CS = 0;    // Configuramos el Timer0 en modo temporizador
    OPTION_REGbits.PSA = 0;     // Asignamos el preescaler al Timer0
    OPTION_REGbits.PS0 = 1;     // Establecemos el preescaler en 1:256
    OPTION_REGbits.PS1 = 1;
    OPTION_REGbits.PS2 = 1;
    TMR0 = 15;                   // Inicializamos el contador del Timer0
    
//_________________________HABILITAR INTERRUPCIONES_____________________________
    
    INTCONbits.T0IE = 1;          // Habilitamos la interrupción del Timer0
    INTCONbits.GIE = 1;           // Habilitamos las interrupciones globales
}

/*PSEUDOCÓDIGO DE LA CONFIGURACIÓN DEL ADC
 
1. Seleccionar el canal del ADC que se va a utilizar
2. Configurar la referencia de voltaje del ADC
3. Configurar la precisión del ADC
4. Configurar el tiempo de muestreo del ADC
5. Habilitar la interrupción del ADC (opcional)
6. Habilitar el ADC
  
 */