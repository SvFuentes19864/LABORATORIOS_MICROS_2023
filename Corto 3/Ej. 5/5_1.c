/******************************************************************************

                            Online C Compiler.
                Code, Compile, Run and Debug C program online.
Write your code in this editor and press "Run" button to compile and execute it.

*******************************************************************************/

#include <stdio.h>

int main() {
    int N;
    printf("Ingrese el tamano del arreglo: ");
    scanf("%d", &N);

    int array[N];

    for(int i = 0; i < N; i++) {
        printf("Ingrese el valor del elemento %d: ", i);
        scanf("%d", &array[i]);
    }

    printf("El arreglo es: ");
    for(int i = 0; i < N; i++) {
        printf("%d ", array[i]);
    }
    printf("\n");

    return 0;
}
