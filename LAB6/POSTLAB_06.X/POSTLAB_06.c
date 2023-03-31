/*IE2023 PROGRAMACIÓN DE MICROCONTROLADORES
 * File:   PRELAB4.c
 * Author: SHAGTY VALERIA FUENTES GARCÍA
 * Carnet: 19864
 * Proyecto: POST-LABORATORIO 6
 * Hardware: PIC16F887
 * Created on 28 de marzo de 2023 */

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

unsigned char   Bandera;
uint16_t        valor_displays;
uint8_t         UNI;                            // UNIDADES DE LOS DISPLAYS
uint8_t         DEC;                            // DECENAS DE LOS DISPLAYS
uint8_t         CEN;                            // CENTENAS DE LOS DISPLAYS

/*******************************************************************************
 * ARREGLOS
 ******************************************************************************/

char const tabla[16] = {0b10111111,     // TABLA DE CONVERSIÓN DISPLAYS
                        0b10000110, 
                        0b11011011, 
                        0b11001111, 
                        0b11100110, 
                        0b11101101, 
                        0b11111101, 
                        0b10000111, 
                        0b11111111, 
                        0b11101111, 
                        0b11110111, 
                        0b11111100, 
                        0b10111001, 
                        0b11011110, 
                        0b11111001, 
                        0b11110001};   // 0 - 15

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
        
        UNI = valor_displays % 10;          // Función para obtener las unidades
        DEC = (valor_displays / 10) % 10;   // Función para obtener las decenas
        CEN = (valor_displays / 100) % 10;  // Función para obtener las centenas
        
        if (Bandera == 0){
            
            ADCON0bits.CHS3 = 0;
            ADCON0bits.CHS2 = 0;
            ADCON0bits.CHS1 = 0;
            ADCON0bits.CHS0 = 0;            // Seleccionamos el canal 0
            
            Bandera = 1;
            __delay_ms(10);                             // Delay de 10 ms
            valor_displays = ADRESH;                    // Le ponemos al valor que irá a la función de los displays el valor de adresh
            valor_displays = valor_displays * 1.963;    // Multiplicamos el valor que irá a los displays por 1.963 para que muestre 5.00 V
            
        }
        
        else if (Bandera == 1){
            
            ADCON0bits.CHS3 = 0;
            ADCON0bits.CHS2 = 0;
            ADCON0bits.CHS1 = 0;
            ADCON0bits.CHS0 = 1;            // Seleccionamos el canal 1
            
            Bandera = 0;
            __delay_ms(10);                 // Delay de 10 ms
            PORTC = ADRESH;                 // Movemos el valor de Adresh del canal 1 al puerto C
            
        }
        
// CONVERSIÓN ADC
        
        ADCON0bits.GO = 1;
        while(ADCON0bits.GO == 1);
        __delay_ms(10);
        
// MULTIPLEXADO DE LOS DISPLAYS
            
        PORTB = 0b00000001;                 // SE ENCIENDE EL TRANSISTOR 1
        PORTD = tabla[UNI];                 // UNIDADES
        __delay_ms(10);                     // 4ms PARA CAMBIAR DE DISPLAY
                
        PORTB = 0b00000010;                 // SE ENCIENDE EL TRANSISTOR 1
        PORTD = tabla[DEC];                 // DECENAS
        __delay_ms(10);                     // 4ms PARA CAMBIAR DE DISPLAY
        
        PORTB = 0b00000100;                 // SE ENCIENDE EL TRANSISTOR 1
        PORTD = tabla[CEN];                 // CENTENAS
        __delay_ms(10);                     // 4ms PARA CAMBIAR DE DISPLAY
        
    }
}

/*******************************************************************************
 * FUNCIÓN DE CONFIGURACIÓN
 ******************************************************************************/

void setup(void){
    
//________________________CONFIGURACIÓN DE PUERTOS______________________________
    ANSELH = 0;
    
    TRISC = 0;                  // Configuramos el puerto C como salida para contador
    TRISD = 0;                  // Configuramos el puerto D como salida para displays
    TRISB = 0;                  // Configuramos el puerto B como salida para transistores
    PORTC = 0;                  // Limpiamos el puerto C
    PORTD = 0;                  // Limpiamos el puerto D
    PORTB = 0;                  // Limpiamos el puerto B
    
//______________________CONFIGURACIÓN DEL OSCILADOR_____________________________
    
    OSCCONbits.IRCF = 0b0110;   // OSCILADOR INTERNO A 4Mhz
    OSCCONbits.SCS = 1;         // HABILITANDO RELOJ INTERNO
    
}


void setupADC(void){
    
    // Paso 1 Seleccionar puerto de entrada
    
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