/******************************************************************************

                            Online C Compiler.
                Code, Compile, Run and Debug C program online.
Write your code in this editor and press "Run" button to compile and execute it.

*******************************************************************************/

#include <stdio.h>

int main() {
    float fahrenheit, celsius;
    
    printf("Ingrese la temperatura en grados Fahrenheit: ");
    scanf("%f", &fahrenheit);
    
    celsius = (fahrenheit - 32.0) * 5.0 / 9.0;
    
    printf("%.2f grados Fahrenheit son %.2f grados Celsius\n", fahrenheit, celsius);
    
    return 0;
}
