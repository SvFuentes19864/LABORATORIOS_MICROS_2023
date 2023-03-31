/*IE2023 PROGRAMACIÓN DE MICROCONTROLADORES
 * File:   PRELAB4.c
 * Author: SHAGTY VALERIA FUENTES GARCÍA
 * Carnet: 19864
 * Proyecto: LABORATORIO 6
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

unsigned char Bandera;

/*******************************************************************************
 * PROTOTIPOS DE FUNCIONES
 ******************************************************************************/

void setup(void);
void setupADC(void);

/*******************************************************************************
 * INTERRUPCIONES
 ******************************************************************************/

/*******************************************************************************
 * CÓDIGO PRINCIPAL
 ******************************************************************************/

void main(void) {
    setup();
    setupADC();

/*******************************************************************************
 * LOOP PRINCIPAL
 ******************************************************************************/
    
    while(1){
        
        if (Bandera == 0){
            
            ADCON0bits.CHS3 = 0;
            ADCON0bits.CHS2 = 0;
            ADCON0bits.CHS1 = 0;
            ADCON0bits.CHS0 = 0;        // Seleccionamos el canal 0
            
            Bandera = 1;
            __delay_ms(10);
            PORTD = ADRESH;
            
        }
        
        else if (Bandera == 1){
            
            ADCON0bits.CHS3 = 0;
            ADCON0bits.CHS2 = 0;
            ADCON0bits.CHS1 = 0;
            ADCON0bits.CHS0 = 1;        // Seleccionamos el canal 1
            
            Bandera = 0;
            __delay_ms(10);
            PORTC = ADRESH;
            
        }
        
        ADCON0bits.GO = 1;
        while(ADCON0bits.GO == 1);
        ADIF = 0;
        __delay_ms(10);
        
    }
}

/*******************************************************************************
 * FUNCIÓN DE CONFIGURACIÓN
 ******************************************************************************/

void setup(void){
    
//________________________CONFIGURACIÓN DE PUERTOS______________________________
    ANSELH = 0;
    
    TRISC = 0;                  // Configuramos el puerto C como salida
    TRISD = 0;                  // Configuramos el puerto D como salida
    PORTC = 0;                  // Limpiamos el puerto C
    PORTD = 0;                  // Limpiamos el puerto D
    
//______________________CONFIGURACIÓN DEL OSCILADOR_____________________________
    
    OSCCONbits.IRCF = 0b0110;   // OSCILADOR INTERNO A 4Mhz
    OSCCONbits.SCS = 1;         // HABILITANDO RELOJ INTERNO
    
}


void setupADC(void){
    
    // Paso 1 Seleccionar puerto de entrada
    //TRISAbits.TRISA0 = 1;
    //TRISAbits.TRISA1 = 1;
    
    TRISA = TRISA | 0x01;
    ANSEL = ANSEL | 0x01;
    
    // Paso 2 Configurar módulo ADC canal 0
    
    ADCON0bits.ADCS1 = 0;
    ADCON0bits.ADCS0 = 1;       // Fosc/ 8
    
    ADCON1bits.VCFG1 = 0;       // Ref VSS
    ADCON1bits.VCFG0 = 0;       // Ref VDD
    
    ADCON1bits.ADFM = 0;        // Justificado hacia izquierda
    
    ADCON0bits.CHS3 = 0;
    ADCON0bits.CHS2 = 0;
    ADCON0bits.CHS1 = 0;
    ADCON0bits.CHS0 = 0;        // Canal AN0
    
    ADCON0bits.ADON = 1;        // Habilitamos el ADC
    __delay_us(100);
    
}