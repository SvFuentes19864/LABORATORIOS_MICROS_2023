/******************************************************************************

                            Online C Compiler.
                Code, Compile, Run and Debug C program online.
Write your code in this editor and press "Run" button to compile and execute it.

*******************************************************************************/

#include <stdio.h>

int main() {
    int i, N;
    printf("Ingrese el número de términos a imprimir: ");
    scanf("%d", &N);
    for (i = 1; i <= N; i++){
        printf("%d ", i);
    }
    printf("\n");
    return 0;
}
