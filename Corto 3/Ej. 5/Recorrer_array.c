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

    int* ptr = &array[0];

    printf("El primer elemento del arreglo es: %d\n", *ptr);

    int i = 0;
    while(i < N) {
        printf("%d\n", *ptr * 2);
        ptr++;
        i++;
    }

    return 0;
}