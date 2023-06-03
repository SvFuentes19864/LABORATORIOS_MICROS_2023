/* UNIVERSIDAD DEL VALLE DE GUATEMALA
 * IE2023 PROGRAMACIÓN DE MICROCONTROLADORES
 * File:   PROYECTO_02.c
 * Author: SHAGTY VALERIA FUENTES GARCÍA
 *         MONICA ESTEFANÍA ALFARO SAMAYOA
 * Carnet: 19864
 *         19755
 * Proyecto: PROYECTO 2
 * Hardware: PIC16F887
 * Created on 14 de abril de 2023
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

// Librerias  
#include <xc.h>
#include <stdio.h>
#include <stdlib.h>

#define _XTAL_FREQ 4000000 //frecuencia del cristal en microsegundos
#define BAUD_RATE 9600

/***************************
 * VARIABLES
 **************************/

// Definir el valor de tiempo de desborde del timer para la frecuencia PWM
#define PWM_FREQ 1000

// Definir el valor máximo para el ciclo de trabajo PWM
#define PWM_MAX 255

int POT_ROJO;
int POT_VERDE;
int POT_AZUL;

int colores_mostrar;
int state_eeprom = 0;

unsigned int duty_cycle1 = 0;    // variable para el ciclo de trabajo del PWM
unsigned int duty_cycle2 = 0;    // variable para el ciclo de trabajo del PWM
unsigned int duty_cycle3 = 0;    // variable para el ciclo de trabajo del PWM
unsigned int duty_cycleP = 0;    // variable para el ciclo de trabajo del PWM
unsigned int duty_cycleT = 0;    // variable para el ciclo de trabajo del PWM
unsigned int pwm_period = 255;  // variable para el período del PWM
int valor_adc;

// Reiniciar el valor del timer
    static uint8_t pwm_count1 = 0;  // variable para contar el tiempo de encendido del PWM
    static uint8_t pwm_count2 = 0;
    static uint8_t pwm_count3 = 0;
    static uint8_t pwm_countP = 0;
    static uint8_t pwm_countT = 0;
    
unsigned char Bandera = 0;                  // Bandera para el cambio de canal

// Variables del uart

char valASCII;
char carac;
char menuMostrado = 0;
char opcionSeleccionada = 0;
int potValue;
int adcValue;

/***************************
 * PROTOTIPOS DE FUNCIONES
 **************************/

void setup(void);
void setupADC(void);
void setupTMR0(void);
void setupPWM(void);
void setupTMR2(void);
void setup_UART(void);

void enviar_caracter(char c);
void cadena(unsigned char *txt);
void enter();
void parpadeo();

void setupEEPROM(void);
void saveToEEPROM();

void saveToEEPROM(){
    
    uint8_t address = 0x86;
    uint8_t data = ADRESH;
    
    while(EECON1bits.WR);    // Esperar mientras la escritura anterior este en proceso
    
    EEADR = address;         // Seleccionar la dirección de memoria donde se va a guardar el dato
    EEDATA = data;           // Cargar el dato en el registro de datos
    EECON1bits.EEPGD = 0;    // Seleccionar la memoria EEPROM
    EECON1bits.WREN = 1;     // Habilitar escritura en la EEPROM
    INTCONbits.GIE = 0;      // Deshabilitar interrupciones globales
    EECON2 = 0x55;           // Secuencia para habilitar escritura
    EECON2 = 0xAA;           // Secuencia para habilitar escritura
    EECON1bits.WR = 1;       // Iniciar escritura
    
    EECON1bits.WREN = 0;     // Deshabilitar escritura en la EEPROM
    
    __delay_ms(10);          // Esperar para asegurar la escritura en la EEPROM
    
    EEADR = address;         // Seleccionar la dirección de memoria donde se va a leer el dato
    EECON1bits.EEPGD = 0;    // Seleccionar la memoria EEPROM
    EECON1bits.RD = 1;       // Iniciar lectura
    PORTCbits.RC2 = EEDATA;          // Mostrar el dato leído en el puerto D
    INTCONbits.GIE = 1;      // Habilitar interrupciones globales
}

void readToEEPROM(){

    uint8_t address = 0x07;
    
    EEADR = address;         // Seleccionar la dirección de memoria donde se va a leer el dato
    EECON1bits.EEPGD = 0;    // Seleccionar la memoria EEPROM
    EECON1bits.RD = 1;       // Iniciar lectura
    PORTCbits.RC2 = EEDATA;          // Mostrar el dato leído en el puerto D

}

// Generar la señal PWM
void pwm_set1(int value1) {
    if (value1 > 0) {
        PORTDbits.RD0 = 1; // Poner en alto la salida PWM
    } else {
        PORTDbits.RD0 = 0; // Poner en bajo la salida PWM
    }
}

// Generar la señal PWM
void pwm_set2(int value2) {
    if (value2 > 0) {
        PORTDbits.RD1 = 1; // Poner en alto la salida PWM
    } else {
        PORTDbits.RD1 = 0; // Poner en bajo la salida PWM
    }
}

// Generar la señal PWM
void pwm_set3(int value3) {
    if (value3 > 0) {
        PORTDbits.RD2 = 1; // Poner en alto la salida PWM
    } else {
        PORTDbits.RD2 = 0; // Poner en bajo la salida PWM
    }
}

// Generar la señal PWM
void pwm_setP(int valueP) {
    if (valueP > 0) {
        PORTDbits.RD3 = 1; // Poner en alto la salida PWM
    } else {
        PORTDbits.RD3 = 0; // Poner en bajo la salida PWM
    }
}

// Generar la señal PWM
void pwm_setT(int valueT) {
    if (valueT > 0) {
        PORTDbits.RD4 = 1; // Poner en alto la salida PWM
    } else {
        PORTDbits.RD4 = 0; // Poner en bajo la salida PWM
    }
}

void led_set(int value1, int value2, int value3, int valueP, int valueT) {
    pwm_set1(value1); // Configurar la señal PWM
    pwm_set2(value2); // Configurar la señal PWM
    pwm_set3(value3); // Configurar la señal PWM
    pwm_setP(valueP); // Configurar la señal PWM
    pwm_setP(valueT); // Configurar la señal PWM
}

/***************************
 * INTERRUPCIONES
 **************************/

void __interrupt()isr(void) {
    
    // Verificar si la interrupción es del Timer 0
    if (T0IF) {
        
       // Reiniciar el valor del timer
        TMR0 = 256 - (_XTAL_FREQ / 4 / PWM_FREQ / 256);
        // Incrementar el contador PWM
        pwm_count1++;
        pwm_count2++;
        pwm_count3++;
        pwm_countP++;
        pwm_countT++;
        
        // Verificar si el contador ha alcanzado el valor de ciclo de trabajo 1
        if (pwm_count1 > duty_cycle1) {
            // Apagar el LED
            PORTDbits.RD0 = 0; } 
        else {
            // Encender el LED
            PORTDbits.RD0 = 1;
        }
        
        // Verificar si el contador ha alcanzado el valor de ciclo de trabajo 2
        if (pwm_count2 > duty_cycle2) {
            // Apagar el LED
            PORTDbits.RD1 = 0; } 
        else {
            // Encender el LED
            PORTDbits.RD1 = 1;
        }
        
        // Verificar si el contador ha alcanzado el valor de ciclo de trabajo 3
        if (pwm_count3 > duty_cycle3) {
            // Apagar el LED
            PORTDbits.RD2 = 0; } 
        else {
            // Encender el LED
            PORTDbits.RD2 = 1;
        }
        
        // Verificar si el contador ha alcanzado el valor de ciclo de trabajo Párpados
        if (pwm_countP > duty_cycleP) {
            // Apagar el LED
            PORTDbits.RD3 = 0; } 
        else {
            // Encender el LED
            PORTDbits.RD3 = 1;
        }
        
        // Verificar si el contador ha alcanzado el valor de ciclo de trabajo Párpados
        if (pwm_countT > duty_cycleT) {
            // Apagar el LED
            PORTDbits.RD4 = 0; } 
        else {
            // Encender el LED
            PORTDbits.RD4 = 1;
        }
        
        // Verificar si el contador ha alcanzado el valor máximo
        if (pwm_count1 >= PWM_MAX) {
            // Reiniciar el contador
            pwm_count1 = 0; }
        
        // Verificar si el contador ha alcanzado el valor máximo
        if (pwm_count2 >= PWM_MAX) {
            // Reiniciar el contador
            pwm_count2 = 0; }
        
        // Verificar si el contador ha alcanzado el valor máximo
        if (pwm_count3 >= PWM_MAX) {
            // Reiniciar el contador
            pwm_count3 = 0; }
        
        // Verificar si el contador ha alcanzado el valor máximo
        if (pwm_countP >= PWM_MAX) {
            // Reiniciar el contador
            pwm_countP = 0; }
        
        // Verificar si el contador ha alcanzado el valor máximo
        if (pwm_countT >= PWM_MAX) {
            // Reiniciar el contador
            pwm_countT = 0; }
        
        // Limpiar la bandera de interrupción del Timer 0
        T0IF = 0;
        
        }

    if (PIR1bits.RCIF) {
        
        // Lee el carácter recibido
        carac = RCREG;
        PIR1bits.RCIF = 0;
        
        }
    
    if (RBIF){
    
        RBIF = 0;
        
        if (PORTBbits.RB0 == 0){
        
        }
        
        if (PORTBbits.RB3 == 0) {
            
            state_eeprom = 0;
            
            while (state_eeprom == 0) {
                
                PORTCbits.RC4 = 0;
                PORTCbits.RC3 = 1;
                
                __delay_ms(500);                     // Retardo en milisegundos
                
                if (RB1 == 0){
                
                    saveToEEPROM();
                
                }
                
                if (RB2 == 0){
                
                    readToEEPROM();
                
                }

            if (PORTBbits.RB3 == 0) {
                
                PORTCbits.RC3 = 0;
                PORTCbits.RC4 = 1;
                state_eeprom = 1;
                
                __delay_ms(500);                     // Retardo en milisegundos
                } 
            }
        }
        
        if (PORTBbits.RB0 == 0){
        
            parpadeo();
            __delay_ms(500);                     // Retardo en milisegundos
        
        }
    
    }
    
}

/***************************
 * CÓDIGO PRINCIPAL
 **************************/
int map(int input, int in_min, int in_max, int out_min, int out_max) {
  int output = (input - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
  return output;
}

void main(void) {
    
    setup();
    setupADC();
    setupTMR0();
    setupTMR2();
    setupPWM();
    setup_UART();

    while (1) {
        
        PORTCbits.RC4 = 1;
        
        if (!menuMostrado) {
            // Muestra el menú si no se ha mostrado antes
            cadena("1. Leer potenciometros rgb \r\n2. Parpadear una vez\r\n3. Parpadear dos veces\r\n");
            menuMostrado = 1;
        }
        
        if (carac == 49) {
            
            enter();
            char valorrojoStr[4];                    // Se crea una cadena de 4 caracteres
            sprintf(valorrojoStr, "%d", POT_ROJO);   // función que convierte el valor entero a una cadena de caracteres
            cadena("Valor del potenciometro rojo: ");    // Se llama a la función
            cadena(valorrojoStr);
            enter();
            
            char valorverdeStr[4];                    // Se crea una cadena de 4 caracteres
            sprintf(valorverdeStr, "%d", POT_VERDE);   // función que convierte el valor entero a una cadena de caracteres
            cadena("Valor del potenciometro verde: ");    // Se llama a la función
            cadena(valorverdeStr);
            enter();
            
            char valorazulStr[4];                    // Se crea una cadena de 4 caracteres
            sprintf(valorazulStr, "%d", POT_AZUL);   // función que convierte el valor entero a una cadena de caracteres
            cadena("Valor del potenciometro azul: ");    // Se llama a la función
            cadena(valorazulStr);
            enter();
            enter();
            
            // Reiniciar variables
            menuMostrado = 0;
            carac = 0;   
        }
        
        if (carac == 50){
            
            parpadeo();
            
            enter();
            cadena("He parpadeado una vez");
            enter();
            enter();
            
            // Reiniciar variables
            menuMostrado = 0;
            carac = 0; 
        
        }
        
        if (carac == 51){
            
            parpadeo();
            parpadeo();
        
            enter();
            cadena("He parpadeado dos veces");
            enter();
            enter();
            
            // Reiniciar variables
            menuMostrado = 0;
            carac = 0; 
        
        }


        if (Bandera == 0){
          
            ADCON0bits.CHS3 = 0;
            ADCON0bits.CHS2 = 0;
            ADCON0bits.CHS1 = 0;
            ADCON0bits.CHS0 = 0;        // Seleccionamos el canal 0
            
            ADCON1bits.ADFM = 1;       // Resultado de la conversión en los bits de mayor peso de ADRESH   

            // Leer el valor ADC
            valor_adc = ADRESH << 8 | ADRESL;
            // Convertir el valor ADC a un ciclo de trabajo PWM
            duty_cycle1 = valor_adc >> 2;
            // Limpiar la bandera de interrupción del ADC
            ADIF = 0;
            
            ADCON1bits.ADFM = 0;       // Resultado de la conversión en los bits de mayor peso de ADRESH
            
            POT_ROJO = ADRESH;
            
            Bandera = 1;
            __delay_ms(50);
            
        }
        
        else if (Bandera == 1){
            
            ADCON0bits.CHS3 = 0;
            ADCON0bits.CHS2 = 0;
            ADCON0bits.CHS1 = 0;
            ADCON0bits.CHS0 = 1;        // Seleccionamos el canal 1
            
            ADCON1bits.ADFM = 1;       // Resultado de la conversión en los bits de mayor peso de ADRESH 
            
            // Leer el valor ADC
            valor_adc = ADRESH << 8 | ADRESL;
            // Convertir el valor ADC a un ciclo de trabajo PWM
            duty_cycle2 = valor_adc >> 2;
            // Limpiar la bandera de interrupción del ADC
            ADIF = 0;
            
            ADCON1bits.ADFM = 0;       // Resultado de la conversión en los bits de mayor peso de ADRESH
            
            POT_VERDE = ADRESH;
            
            Bandera = 2;
            __delay_ms(50);
            
        }
        
        else if (Bandera == 2){
            
            ADCON0bits.CHS3 = 0;
            ADCON0bits.CHS2 = 0;
            ADCON0bits.CHS1 = 1;
            ADCON0bits.CHS0 = 0;        // Seleccionamos el canal 2
            
            ADCON1bits.ADFM = 1;       // Resultado de la conversión en los bits de mayor peso de ADRESH 
            
            // Leer el valor ADC
            valor_adc = ADRESH << 8 | ADRESL;
            // Convertir el valor ADC a un ciclo de trabajo PWM
            duty_cycle3 = valor_adc >> 2;
            // Limpiar la bandera de interrupción del ADC
            ADIF = 0;
            
            ADCON1bits.ADFM = 0;       // Resultado de la conversión en los bits de mayor peso de ADRESH
            
            POT_AZUL = ADRESH;
            
            Bandera = 3;
            __delay_ms(50);
            
        }
        
        else if (Bandera == 3){
            
            CCPR1L = (char) map (ADRESH, 0, 255, 90, 120);
            ADCON0bits.CHS3 = 0;
            ADCON0bits.CHS2 = 1;
            ADCON0bits.CHS1 = 0;
            ADCON0bits.CHS0 = 0;        // Seleccionamos el canal 4
            
            ADCON1bits.ADFM = 0;       // Resultado de la conversión en los bits de mayor peso de ADRESH 
            
            Bandera = 4;
            __delay_ms(50);
            
        }
        
        else if (Bandera == 4){
            
            CCPR2L = (char) map (ADRESH, 0, 255, 90, 120);
            ADCON0bits.CHS3 = 0;
            ADCON0bits.CHS2 = 0;
            ADCON0bits.CHS1 = 1;
            ADCON0bits.CHS0 = 1;        // Seleccionamos el canal 3
            
            ADCON1bits.ADFM = 0;       // Resultado de la conversión en los bits de mayor peso de ADRESH 
            
            Bandera = 0;
            __delay_ms(50);
            
        }
        
        ADCON0bits.GO = 1;
        while(ADCON0bits.GO == 1);
        ADIF = 0;

        }
    }

/***************************
 * FUNCIÓN DE CONFIGURACIÓN
 **************************/
void setup(void){
    
    ANSEL = 0b00011111;                 // Habilitamos las entradas analógicas
    ANSELH = 0;

    TRISA = 0b00011111;                 // Bits de entrada para los pots
    TRISC = 0b10000000;                 // Bits de salida para los motores
    TRISD = 0;                          // rgb  
    TRISB = 0b00001111;                          // Botones
    
    PORTA = 0;
    PORTC = 0;
    PORTD = 0;                          // Limpiamos puertos
    PORTB = 0;


//________CONFIGURACIÓN DEL OSCILADOR_________
    
    OSCCONbits.IRCF = 0b0110 ;  
    OSCCONbits.SCS = 1;     
    
//________CONFIGURACIÓN DE PULLUPS__________    
    
    OPTION_REGbits.nRBPU = 0;           // Habilita las resistencias pull-up internas
    
    IOCBbits.IOCB0 = 1;                 // Habilitamos puerto B para las ISR
    IOCBbits.IOCB1 = 1;                 // Habilitamos puerto B para las ISR
    IOCBbits.IOCB2 = 1;                 // Habilitamos puerto B para las ISR
    IOCBbits.IOCB3 = 1;                 // Habilitamos puerto B para las ISR
    WPUBbits.WPUB0 = 1;                 // Habilita la resistencia pull-up en puerto B
    WPUBbits.WPUB1 = 1;                 // Habilita la resistencia pull-up en puerto B
    WPUBbits.WPUB2 = 1;                 // Habilita la resistencia pull-up en puerto B
    WPUBbits.WPUB3 = 1;                 // Habilita la resistencia pull-up en puerto B
    
//________CONFIGURACIÓN DE INTERRUPCIONES_________
    
    INTCONbits.GIE = 1;                 // Habilitar las interrupciones globales
    INTCONbits.T0IE = 1;                // Habilitar las interrupción del TMR0
    INTCONbits.RBIE = 1;
    RBIF = 0;
}
    
/***************************
 * FUNCIÓN DE CONFIGURACIÓN DEL ADC
 **************************/

void setupADC(void){ 
    
    // SELECCIONAR RELOJ PARA CONVERSIÓN ADC
    
    ADCON0bits.ADCS1 = 0;
    ADCON0bits.ADCS0 = 1;       // Fosc/ 8
    
    // SELECCIONAR VOLTAJES DE REFERENCIA
    
    ADCON1bits.VCFG0 = 0;       // Vref+ en VDD
    ADCON1bits.VCFG1 = 0;       // Vref- en VSS
    
    ADCON1bits.ADFM = 0;       // Resultado de la conversión en los bits de mayor peso de ADRESH   
    
    // SELECCIONAR CANAL DE ENTRADA ADC 
    
    ADCON0bits.CHS = 0b0000;    // Seleccionar el canal AN0
    
    // HABILITAR ADC 
    ADCON0bits.ADON = 1;        // Habilitamos el ADC
    __delay_us(100);  
    
}               
      
/***************************
 * FUNCIÓN DE CONFIGURACIÓN DEL PWM
 **************************/
    
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

/***************************
 * FUNCIÓN DE CONFIGURACIÓN DEL TIMER 2
 **************************/
    
    void setupTMR2(void){
        
    PIR1bits.TMR2IF = 0;     
    T2CONbits.T2CKPS = 0b11;        // Valor del prescaler (64)
    T2CONbits.TMR2ON = 1;           // Habilitar el Timer2 
    while(PIR1bits.TMR2IF == 0);    // MIENTRAS LA BANDERA ESTÁ APAGADA 
    PIR1bits.TMR2IF = 0;            // APAGAMOS LA BANDERA DEL TIMER 2
        
    } 
    
/***************************
 * FUNCIÓN DE CONFIGURACIÓN DEL TIMER 0
 **************************/
    
    void setupTMR0(void){
        
    OPTION_REGbits.T0CS = 0;                        // Fuente de reloj interna
    OPTION_REGbits.PSA = 0;                         // Habilitar el preescaler
    OPTION_REGbits.PS = 0b100;                      // Preescalador = 4
    TMR0 = 256 - (_XTAL_FREQ / 4 / PWM_FREQ / 256);                                       // Reiniciar el temporizador
}
    
/***************************
 * FUNCIÓN DE CONFIGURACIÓN DEL UART
 **************************/
    
void setup_UART(void) {
    TXSTAbits.SYNC = 0;         // ASÍNCRONO
    TXSTAbits.BRGH = 1;         // BAUD ALTA VELOCIDAD
    BAUDCTLbits.BRG16 = 0;      // 8 BITS REGISTRO
    
    SPBRG = 25;                 // BAUDAJE 9600
    SPBRGH = 0;                 
    
    RCSTAbits.SPEN = 1;         // HABILITAMOS LA COMUNICACIÓN SERIAL
    TXSTAbits.TX9 = 0;          // 8 BITS
    TXSTAbits.TXEN = 1;         // HABILITAMOS LA TRANSMISIÓN DE DATOS
    RCSTAbits.CREN = 1;         // HABILITAMOS LA RECEPCIÓN DE DATOS
     
    PIE1bits.RCIE = 1;          // Int. UART
    PIR1bits.RCIF = 0;
    
    INTCONbits.PEIE = 1;        // Int. periféricos
}

/***************************
 * FUNCIONES EXTRA
 **************************/

void enviar_caracter(char tecla) {
    // Espera hasta que el registro de transmisión esté vacío
    while(!TXIF);
    // Envía el carácter a través del puerto serial
    TXREG = tecla;
}

void cadena(unsigned char *txt) {
        // Recorre la cadena de caracteres
    while (*txt != '\0') {
        // Envía cada carácter de la cadena a través del puerto serial
        enviar_caracter(*txt);
        // Incrementa el puntero para apuntar al siguiente carácter de la cadena
        txt++;
    }
}

void enter() {

    enviar_caracter('\r');
    enviar_caracter('\n');

}

void parpadeo(){

    duty_cycleP = 0;
            
            // Girar el servo motor de 0 a 45 grados
            for (int i = 0; i <= 20; i++) {
                // Calcula el valor del ciclo de trabajo dentro del rango deseado
            duty_cycleP = (char) ((i * (0 - 20) / 20) + 20);
            __delay_ms(20);                     // Retardo en milisegundos
            }

}