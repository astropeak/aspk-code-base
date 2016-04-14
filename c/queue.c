/*
c语言实现queue(队列)模板化

用c语言模拟c++中的queue类，使用时注意：

1.获得队列元素后，需判断该元素是否为NULL，若为NULL，则说明队列空，不能进行输出、运算；

2.为了模版化，参数都是void*类型的，所以在传入参数时，需要进行强制类型转换；

3.存储元素的内存都是动态申请的，所以删除节点或删除队列时，应该先释放此内存；

4.普通类型和字符串类型是有区别的，因为字符串类型存储的是char*，但字符串长度是不同的，所以实际上，字符串队列只是存储此字串的地址。所以对于动态申请内存的字串类型，需要释放3个东西：1.动态分配的字符串；2.元素本身，也即指向此字串的指针；3.节点本身。这就需要自定义释放函数
*/


#include "queue.h"
#include<stdio.h>
#include<stdlib.h>
#include<string.h>


void charfree(void *v)

{

   free(*(char**)v);

}

int cmpfn(void *a, void *b) {
    return *(double *)a == *(double *)b;
}
int main()

{

   Queue dq;   //double类型队列

   double f;

   initQueue(&dq,sizeof(double), NULL, cmpfn);


   f = 21.3;

   pushQueue(&dq, &f);
   f=21.3;
   printf("%f exist? %d\n", f, existQueue(&dq, &f));


   f = 32.5;

   pushQueue(&dq, &f);

   f = 49.8;

   pushQueue(&dq, &f);

   printf("size:%d\n",sizeQueue(&dq));
   f=32.5;
   printf("%f exist? %d\n", f, existQueue(&dq, &f));
   f=40;
   printf("%f exist? %d\n", f, existQueue(&dq, &f));
   f=49.8;
   printf("%f exist? %d\n", f, existQueue(&dq, &f));

   printf("front:%f\tback:%f\n", *(double*)frontQueue(&dq) ,*(double*)backQueue(&dq));


   popQueue(&dq);

   printf("front:%f\tback:%f\n", *(double*)frontQueue(&dq) ,*(double*)backQueue(&dq));

   printf("size:%d\n",sizeQueue(&dq));


   popQueue(&dq);

   printf("size:%d\n\n",sizeQueue(&dq));

   destoryQueue(&dq);


   Queue cq1;  //字符串类型的队列，字符串不动态分配

   char *s[] = {"John","Smith","Green"};

   initQueue(&cq1, sizeof(char*), NULL, NULL);

   pushQueue(&cq1, &s[0]);

   pushQueue(&cq1, &s[1]);

   pushQueue(&cq1, &s[2]);

   printf("front:%s\tback:%s\n", *(char**)frontQueue(&cq1) ,*(char**)backQueue(&cq1));

   popQueue(&cq1);

   printf("front:%s\tback:%s\n\n", *(char**)frontQueue(&cq1) ,*(char**)backQueue(&cq1));

   destoryQueue(&cq1);


   Queue cq2;  //字符串类型队列，动态分配字串内存，这个需要自定义释放函数

   char *ds;

   initQueue(&cq2, sizeof(char*), charfree, NULL);

   ds = strdup("Lucy");

   pushQueue(&cq2, &ds);

   ds = strdup("Tim");

   pushQueue(&cq2, &ds);

   ds = strdup("Ball");

   pushQueue(&cq2, &ds);

   printf("front:%s\tback:%s\n", *(char**)frontQueue(&cq2) ,*(char**)backQueue(&cq2));

   popQueue(&cq2);

   printf("front:%s\tback:%s\n\n", *(char**)frontQueue(&cq2) ,*(char**)backQueue(&cq2));

   destoryQueue(&cq2);


   return 0;

}
