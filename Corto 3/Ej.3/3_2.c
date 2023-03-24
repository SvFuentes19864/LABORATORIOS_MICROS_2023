/******************************************************************************

                            Online C Compiler.
                Code, Compile, Run and Debug C program online.
Write your code in this editor and press "Run" button to compile and execute it.

*******************************************************************************/
#include <stdio.h>

int main() {
    int i, n, t1 = 0, t2 = 1, nextTerm;
    printf("Ingrese el número de términos a imprimir: ");
    scanf("%d", &n);
    printf("Serie de Fibonacci hasta el término %d:\n", n);
    for (i = 1; i <= n; i++) {
        printf("%d ", t1);
        nextTerm = t1 + t2;
        t1 = t2;
        t2 = nextTerm;
    }
    return 0;
}