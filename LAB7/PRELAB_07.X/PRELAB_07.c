/* UNIVERSIDAD DEL VALLE DE GUATEMALA
 * IE2023 PROGRAMACIÓN DE MICROCONTROLADORES
 * File:   PRELAB5.c
 * Author: SHAGTY VALERIA FUENTES GARCÍA
 * Carnet: 19864
 * Proyecto: PRELAB 7
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
#pragma config LVP = ON         // Low Voltage Programming Enable bit 

// CONFIG2
#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit 
#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits 

//Librerias  
#include <xc.h>
#include <stdint.h>

#define _XTAL_FREQ 4000000 //frecuencia del cristal en microsegundos



/*******************************************************************************
 * PROTOTIPOS DE FUNCIONES
 ******************************************************************************/

void setup(void);
void setupPWM(void);
void setup_TMR2(void);

/*******************************************************************************
 * INTERRUPCIONES
 ******************************************************************************/

/*******************************************************************************
 * CÓDIGO PRINCIPAL
 ******************************************************************************/

void main(void) {
    
    setup();
    setupPWM();
    setup_TMR2();

    while (1) {

        }
    }

/*******************************************************************************
 * FUNCIÓN DE CONFIGURACIÓN
 ******************************************************************************/
void setup(void){
    
    ANSEL = 0; 
    ANSELH = 0;

    TRISC = 0;
    PORTC = 0;

//_______________________CONFIGURACIÓN DEL OSCILADOR____________________________
    
    OSCCONbits.IRCF = 0b0111 ;  
    OSCCONbits.SCS = 1;     
    
}             
      
/*******************************************************************************
 * FUNCIÓN DE CONFIGURACIÓN DEL PWM
 ******************************************************************************/
    
    void setupPWM(void){

    // PASO 1, HABILITAR PIN OUTPUT COMO INPUT
        
    TRISCbits.TRISC2 = 1;   

    // PASO 2, VALOR DE PR2
    
    PR2 = 199;                      // VALOR INICIAL DE LA OSCILACIÓN
    
    // PASO 3, CONFIGURAR EL MÓDULO CCP
 
    CCP1CONbits.P1M = 0;             
    CCP1CONbits.CCP1M = 0b1100;     // P1A COMO PWM
    
    // PASO 4, CICLOS DEL PWM
    
    CCPR1L = 75;                  // Valor del ciclo de trabajo para 90° (1.5 ms)                  
    CCP1CONbits.DC1B = 0;           // VALOR DE CCP_CON <3;2>

    // PASO 6, HABILITAR LA SALIDA DEL PWM
    
    TRISCbits.TRISC2 = 0;
    
    }  
    
/*******************************************************************************
 * FUNCIÓN DE CONFIGURACIÓN DEL TIMER 2
 ******************************************************************************/
    
    void setup_TMR2(void){
        
    PIR1bits.TMR2IF = 0;     
    T2CONbits.T2CKPS = 0b11;        // PRESCALER 1:16
    PR2 = 199;                      // Período de 5000 para una frecuencia de 50 Hz
    T2CONbits.TMR2ON = 1;           // SE HABILITA EL TIMER 2 
    while(PIR1bits.TMR2IF == 0);    // MIENTRAS LA BANDERA ESTÁ APAGADA 
    PIR1bits.TMR2IF = 0;            // APAGAMOS LA BANDERA DEL TIMER 2
        
    }