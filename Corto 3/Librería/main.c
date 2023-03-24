/******************************************************************************

                            Online C Compiler.
                Code, Compile, Run and Debug C program online.
Write your code in this editor and press "Run" button to compile and execute it.

*******************************************************************************/
#include <stdio.h>
#include "libmath.h"

int main() {
    float a, b;
    printf("Ingrese dos valores: ");
    scanf("%f %f", &a, &b);
    printf("El valor de PI es: %f\n", PI);
    printf("La suma de %f y %f es: %f\n", a, b, suma(a, b));
    printf("La resta de %f y %f es: %f\n", a, b, resta(a, b));
    printf("La multiplicacion de %f y %f es: %f\n", a, b, multiplicacion(a, b));
    printf("La division de %f y %f es: %f\n", a, b, division(a, b));
    return 0;
}
