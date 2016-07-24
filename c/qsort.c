#include <stdio.h>

void qsort(int A[], int m, int n) {
    if (m>=n) return;
    int x=A[m];
    int i=m+1, j=n;

    do {
        while(A[i]<=x && i<j){++i;}
        while(A[j]>=x && i<j){++j;}
        if (i<j){
            int t=A[i];
            A[i] = A[j];
            A[j]=A[i];
        }
    } while (i<j);

    A[m]=A[i];
    A[i] =x;
    qsort(A, m, i-1);
    qsort(A, i+1, n);
}

int main(int argc, char *argv[])
{
    int a[] = {4,5,7, 2, 1,3};
    qsort(a, 0, 5);
    int i;
    printf("in main\n");
    for (i = 0; i < 5; i++) {
        printf("%d\n", a[i]);
    }

    return 0;
}
