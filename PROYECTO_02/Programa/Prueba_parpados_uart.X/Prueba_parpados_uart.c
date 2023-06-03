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

#include <xc.h>
#include <stdio.h>
#include <stdlib.h>

#define _XTAL_FREQ 4000000
#define BAUD_RATE 9600

/*******************************************************************************
 * VARIABLES
 ******************************************************************************/

// Definir el valor de tiempo de desborde del timer para la frecuencia PWM
#define PWM_FREQ 1000

// Definir el valor máximo para el ciclo de trabajo PWM
#define PWM_MAX 255

unsigned int duty_cycle1 = 0;    // variable para el ciclo de trabajo del PWM
unsigned int duty_cycle2 = 0;    // variable para el ciclo de trabajo del PWM
unsigned int pwm_period = 255;  // variable para el período del PWM

// Reiniciar el valor del timer
    static uint8_t pwm_count1 = 0;  // variable para contar el tiempo de encendido del PWM
    static uint8_t pwm_count2 = 0;

char valASCII;
char c;
char menuMostrado = 0;
int potValue;
int adcValue;

/*******************************************************************************
 * PROTOTIPOS DE FUNCIONES
 ******************************************************************************/

void setup(void);
void setup_UART(void);
void setupTMR0(void);
void enviar_caracter(char c);
void cadena(unsigned char *txt);

// Generar la señal PWM
void pwm_set1(int value1) {
    if (value1 > 0) {
        PORTDbits.RD3 = 1; // Poner en alto la salida PWM
    } else {
        PORTDbits.RD3 = 0; // Poner en bajo la salida PWM
    }
}

void pwm_manual_set(int value1) {
    pwm_set1(value1); // Configurar la señal PWM
}

/*******************************************************************************
 * INTERRUPCIONES
 ******************************************************************************/

void __interrupt() isr (void){
    
    // Verificar si la interrupción es del Timer 0
    if (T0IF) {
        
       // Reiniciar el valor del timer
        TMR0 = 256 - (_XTAL_FREQ / 4 / PWM_FREQ / 256);
        // Incrementar el contador PWM
        pwm_count1++;
        
        // Verificar si el contador ha alcanzado el valor de ciclo de trabajo 1
        if (pwm_count1 > duty_cycle1) {
            // Apagar el LED
            PORTDbits.RD3 = 0; } 
        else {
            // Encender el LED
            PORTDbits.RD3 = 1;
        }
        
        // Verificar si el contador ha alcanzado el valor máximo
        if (pwm_count1 >= PWM_MAX) {
            // Reiniciar el contador
            pwm_count1 = 0; }
        
        // Limpiar la bandera de interrupción del Timer 0
        T0IF = 0;
        
        }
    
    else if (PIR1bits.RCIF) {
        // Lee el carácter recibido
        c = RCREG;
        PIR1bits.RCIF = 0;
    }
    
    }

/*******************************************************************************
 * CÓDIGO PRINCIPAL
 ******************************************************************************/
int map(int input, int in_min, int in_max, int out_min, int out_max) {
  int output = (input - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
  return output;
}

void main() {
    
    setup();
    setupTMR0();
    setup_UART();
    
    while(1) {
        
        if (!menuMostrado) {
            // Muestra el menú si no se ha mostrado antes
            cadena("1. Parpadear una vez\r\n2. Parpadear dos veces\r\n");
            menuMostrado = 1;
        }
        
        if (c == 49) {
            
            duty_cycle1 = 0;
            
            // Girar el servo motor de 0 a 45 grados
            for (int i = 0; i <= 20; i++) {
                // Calcula el valor del ciclo de trabajo dentro del rango deseado
            duty_cycle1 = (char) ((i * (0 - 20) / 20) + 20);
            __delay_ms(20);                     // Retardo en milisegundos
    }
            
            cadena("He parpadeado una vez");        // Se llama a la función
            enviar_caracter('\r');
            enviar_caracter('\n');
        
            // Reiniciar variables
            menuMostrado = 0;
            c = 0;
            }
        } 
    }

/*******************************************************************************
 * FUNCIÓN DE CONFIGURACIÓN
 ******************************************************************************/

void setup(void){
    
    ANSEL = 0b00000000;                 // Habilitamos las entradas analógicas
    ANSELH = 0;
    
    TRISA = 0b00000000;
    TRISD = 0;
    TRISB = 0;
    PORTB = 0;
    PORTA = 0;
    PORTD = 0;

//_______________________CONFIGURACIÓN DEL OSCILADOR____________________________
    
    OSCCONbits.IRCF = 0b110;   // Configuración del oscilador interno a 4 MHz 
    OSCCONbits.SCS = 0b00;   
    
//_____________________CONFIGURACIÓN DE INTERRUPCIONES__________________________
    
    INTCONbits.GIE = 1;                 // Habilitar las interrupciones globales
    INTCONbits.T0IE = 1;                // Habilitar las interrupción del TMR0
    
}

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
    PIR1bits.RCIF = 1;
    
    INTCONbits.GIE = 1;         // Int. globales
    INTCONbits.PEIE = 1;        // Int. periféricos
}

/*******************************************************************************
 * FUNCIONES EXTRA
 ******************************************************************************/

void enviar_caracter(char c) {
    // Espera hasta que el registro de transmisión esté vacío
    while(!TXIF);
    // Envía el carácter a través del puerto serial
    TXREG = c;
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

/*******************************************************************************
 * FUNCIÓN DE CONFIGURACIÓN DEL TIMER 0
 ******************************************************************************/
    
    void setupTMR0(void){
        
    OPTION_REGbits.T0CS = 0;                        // Fuente de reloj interna
    OPTION_REGbits.PSA = 0;                         // Habilitar el preescaler
    OPTION_REGbits.PS = 0b100;                      // Preescalador = 4
    TMR0 = 256 - (_XTAL_FREQ / 4 / PWM_FREQ / 256);                                       // Reiniciar el temporizador
}