/*IE2023 PROGRAMACIÓN DE MICROCONTROLADORES
 * Author: SHAGTY VALERIA FUENTES GARCÍA
 * Carnet: 19864
 * Proyecto: PRELAB 9
 * Hardware: PIC16F887
 * Created on 24 de abril de 2023 */

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

unsigned char Bandera = 1;

/*******************************************************************************
 * PROTOTIPOS DE FUNCIONES
 ******************************************************************************/

void setup(void);
void setupADC(void);
void setupint(void);

/*******************************************************************************
 * INTERRUPCIONES
 ******************************************************************************/

void __interrupt() isr(void)
{
    if(INTCONbits.RBIF)             // Si la interrupción proviene del pin RB0
    {
        INTCONbits.RBIF = 0;        // Limpia la bandera de interrupción
        if(!PORTBbits.RB0){         // Verificamos si el botón de sleep está presionado
        
            Bandera = 0;            // Encendemos la bandera del while
        
        }
        
        if(!PORTBbits.RB1){         // Verificamos si el botón de wake up está presionado
                
            Bandera = 1;            // Apagamos la bandera del while

         } 
    }
}

/*******************************************************************************
 * CÓDIGO PRINCIPAL
 ******************************************************************************/

void main(void) {
    setup();
    setupADC();
    setupint();

/*******************************************************************************
 * LOOP PRINCIPAL
 ******************************************************************************/
    
    while(1){  
        
        // Iniciamos conversión del ADC
        ADCON0bits.GO = 1;
        while(ADCON0bits.GO == 1);
        __delay_ms(10);
        PORTC = ADRESH;             // Mandamos el valor del ADC al puerto C
     
        PORTE = 0;              // Apagamos un led para saber que ya salio del modo sleep
        
        while(!Bandera){            // Mientras la bandera = 0
            
            PORTE = 0b001;          // Encendemos un led para saber que ya entró en modo sleep
            SLEEP();                // Pone al microcontrolador en modo de suspensión
        
        }
        
    }
}

/*******************************************************************************
 * FUNCIÓN DE CONFIGURACIÓN
 ******************************************************************************/

void setup(void){
    
//________________________CONFIGURACIÓN DE PUERTOS______________________________
    ANSELH = 0;
    
    TRISC = 0;                          // Configuramos el puerto C como salida
    TRISB = 0b00000111;                 // Puerto B como entradas para los botones
    TRISE = 0;                          // Puerto E para asegurar el sleep
    PORTC = 0;                          // Limpiamos el puerto C
    PORTE = 0;                          // Limpiamos el puerto E
    PORTB = 0;
    
//______________________CONFIGURACIÓN DEL OSCILADOR_____________________________
    
    OSCCONbits.IRCF = 0b0110;           // OSCILADOR INTERNO A 4Mhz
    OSCCONbits.SCS = 1;                 // HABILITANDO RELOJ INTERNO
    
//_______________________CONFIGURACIÓN DE PULLUPS_______________________________    
    
    OPTION_REGbits.nRBPU = 0;           // Habilita las resistencias pull-up internas
    
    IOCBbits.IOCB0 = 1;                 // Habilitamos puerto B para las ISR
    IOCBbits.IOCB1 = 1;                 // Habilitamos puerto B para las ISR
    WPUBbits.WPUB0 = 1;                 // Habilita la resistencia pull-up en puerto B
    WPUBbits.WPUB1 = 1;                 // Habilita la resistencia pull-up en puerto B
}

void setupint(void){

    INTCONbits.GIE = 1;                 // Habilitamos las interrupciones globales
    INTCONbits.RBIE = 1;                // Habilitamos las interrupciones del purto B

}

void setupADC(void){
    
    // Paso 1 Seleccionar puerto de entrada

    TRISAbits.TRISA0 = 1;
    ANSELbits.ANS0 = 1;
    
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