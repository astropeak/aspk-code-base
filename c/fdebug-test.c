/* Last modified Time-stamp: <2014-07-27 12:09:36 Sunday by astropeak>
 * @(#)test.c
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fdebug.h"


int main(void)
{
    int a = 5;
    int b = 6, c = 7, d = 8;
    dd1(a);
    dd4(a,b,c,d);

    dd("ENTER, %d\n", d);
    dd("ENTER");

    return 0;
}
