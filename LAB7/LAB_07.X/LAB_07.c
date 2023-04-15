/* UNIVERSIDAD DEL VALLE DE GUATEMALA
 * IE2023 PROGRAMACIÓN DE MICROCONTROLADORES
 * File:   LAB5.c
 * Author: SHAGTY VALERIA FUENTES GARCÍA
 * Carnet: 19864
 * Proyecto: LAB 7
 * Hardware: PIC16F887
 * Created on 07 de abril de 2023
 */

// CONFIG1
#pragma config FOSC = INTRC_NOCLKOUT// Oscillator Selection bits    
#pragma config WDTE = OFF       // Watchdog Timer Enable bit  
#pragma config PWRTE = OFF      // Power-up Timer Enable bit  
#pragma config MCLRE = OFF      // RE3/MCLR pin function select bit    
#pragma config CP = OFF         // Code Protection bit  
#pragma config CPD = OFF        // Data Code Protection bit  
#pragma config BOREN = OFF      // Brown Out Reset Selection bits  
#pragma config IESO = OFF       // Internal External Switchover bit  
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enabled bit 
#pragma config LVP = OFF         // Low Voltage Programming Enable bit 

// CONFIG2
#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit 
#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits 

//Librerias  
#include <xc.h>
#include <stdint.h>

#define _XTAL_FREQ 4000000 //frecuencia del cristal en microsegundos

/*******************************************************************************
 * VARIABLES
 ******************************************************************************/

unsigned char Bandera;                  // Bandera para el cambio de canal

/*******************************************************************************
 * PROTOTIPOS DE FUNCIONES
 ******************************************************************************/

void setup(void);
void setupADC(void);
void setupPWM(void);
void setupTMR2(void);

/*******************************************************************************
 * INTERRUPCIONES
 ******************************************************************************/


/*******************************************************************************
 * CÓDIGO PRINCIPAL
 ******************************************************************************/
int map(int input, int in_min, int in_max, int out_min, int out_max) {
  int output = (input - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
  return output;
}

void main(void) {
    
    setup();
    setupADC();
    setupTMR2();
    setupPWM();

    while (1) {
        
        if (Bandera == 0){
            
            CCPR1L = (char) map (ADRESH, 0, 255, 10, 135);
            ADCON0bits.CHS3 = 0;
            ADCON0bits.CHS2 = 0;
            ADCON0bits.CHS1 = 0;
            ADCON0bits.CHS0 = 0;        // Seleccionamos el canal 0
            
            Bandera = 1;
            __delay_ms(50);
            
        }
        
        else if (Bandera == 1){
            
            CCPR2L = (char) map (ADRESH, 0, 255, 10, 135);
            ADCON0bits.CHS3 = 0;
            ADCON0bits.CHS2 = 0;
            ADCON0bits.CHS1 = 0;
            ADCON0bits.CHS0 = 1;        // Seleccionamos el canal 1
            
            Bandera = 0;
            __delay_ms(50);
            
        }
        
        ADCON0bits.GO = 1;
        while(ADCON0bits.GO == 1);
        ADIF = 0;
        //__delay_ms(50);

        }
    }

/*******************************************************************************
 * FUNCIÓN DE CONFIGURACIÓN
 ******************************************************************************/
void setup(void){
    
    ANSEL = 0b00000011;                 // Habilitamos las entradas analógicas
    ANSELH = 0;

    TRISA = 0b00000011;                 // Bits de entrada para los pots
    TRISC = 0;                          // Bits de salida para los motores
    
    PORTA = 0;
    PORTC = 0;


//_______________________CONFIGURACIÓN DEL OSCILADOR____________________________
    
    OSCCONbits.IRCF = 0b0110 ;  
    OSCCONbits.SCS = 1;     
    
}
    
/*******************************************************************************
 * FUNCIÓN DE CONFIGURACIÓN DEL ADC
 ******************************************************************************/

void setupADC(void){ 
    
    // SELECCIONAR RELOJ PARA CONVERSIÓN ADC
    
    ADCON0bits.ADCS1 = 0;
    ADCON0bits.ADCS0 = 1;       // Fosc/ 8
    
    // SELECCIONAR VOLTAJES DE REFERENCIA
    
    ADCON1bits.VCFG0 = 0;       // Vref+ en VDD
    ADCON1bits.VCFG1 = 0;       // Vref- en VSS
    
    ADCON1bits.ADFM = 0;        // Resultado de la conversión en los bits de mayor peso de ADRESH   
    
    // SELECCIONAR CANAL DE ENTRADA ADC 
    
    ADCON0bits.CHS = 0b0000;    // Seleccionar el canal AN0
    
    // HABILITAR ADC 
    ADCON0bits.ADON = 1;        // Habilitamos el ADC
    __delay_us(100);  
    
}               
      
/*******************************************************************************
 * FUNCIÓN DE CONFIGURACIÓN DEL PWM
 ******************************************************************************/
    
    void setupPWM(void){

    // PASO 1, HABILITAR PIN OUTPUT COMO INPUT
        
    TRISCbits.TRISC2 = 1;
    TRISCbits.TRISC1 = 1;  

    // PASO 2, VALOR DE PR2
    
    PR2 = 249;                      // Valor del período (4 MHz / (64 * 250) = 50 Hz)
    
    // PASO 3, CONFIGURAR EL MÓDULO CCP
 
    CCP1CONbits.P1M = 0;             
    CCP1CONbits.CCP1M = 0b1100;     // Modo PWM para el motor 1
    CCP2CONbits.CCP2M = 0b1100;     // Modo PWM para el motor 2
    
    // PASO 4, CICLOS DEL PWM
    
    CCPR1L = 0b00011110;            // Ciclo de trabajo del PWM1 (1.5 ms)          
    CCPR2L = 0b00011110;            // Ciclo de trabajo del PWM2 (1.5 ms) 
    CCP1CONbits.DC1B = 0;           // Bits menos significativos del ciclo de trabajo en 0
    CCP2CONbits.DC2B0 = 0;
    CCP2CONbits.DC2B1 = 0;

    // PASO 6, HABILITAR LA SALIDA DEL PWM
    
    TRISCbits.TRISC2 = 0;
    TRISCbits.TRISC1 = 0; 
    
    }    

/*******************************************************************************
 * FUNCIÓN DE CONFIGURACIÓN DEL TIMER 2
 ******************************************************************************/
    
    void setupTMR2(void){
        
    PIR1bits.TMR2IF = 0;     
    T2CONbits.T2CKPS = 0b11;        // Valor del prescaler (64)
    T2CONbits.TMR2ON = 1;           // Habilitar el Timer2 
    while(PIR1bits.TMR2IF == 0);    // MIENTRAS LA BANDERA ESTÁ APAGADA 
    PIR1bits.TMR2IF = 0;            // APAGAMOS LA BANDERA DEL TIMER 2
        
    } 