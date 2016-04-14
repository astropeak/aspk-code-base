/*
c语言实现queue(队列)模板化

用c语言模拟c++中的queue类，使用时注意：

1.获得队列元素后，需判断该元素是否为NULL，若为NULL，则说明队列空，不能进行输出、运算；

2.为了模版化，参数都是void*类型的，所以在传入参数时，需要进行强制类型转换；

3.存储元素的内存都是动态申请的，所以删除节点或删除队列时，应该先释放此内存；

4.普通类型和字符串类型是有区别的，因为字符串类型存储的是char*，但字符串长度是不同的，所以实际上，字符串队列只是存储此字串的地址。所以对于动态申请内存的字串类型，需要释放3个东西：1.动态分配的字符串；2.元素本身，也即指向此字串的指针；3.节点本身。这就需要自定义释放函数
*/


#include<stdio.h>

#include<stdlib.h>

#include<string.h>


typedef struct mynode{

       struct mynode* next;

       void *elem;

}Node;


typedef struct{

   Node* item;

   size_t elem_size;   //元素大小

   size_t length;  //队列长度

   void (*freefn)(void *); //自定义内存释放函数，释放外部动态申请的内存
   int (*cmpfn)(void *, void *); //自定义判断函数，输入为两个元素

}Queue;


//初始化队列

void initQueue(Queue *s,size_t size, void (*freefn)(void*), int (*cmpfn)(void*, void*))   

{

   s->item = NULL;

   s->elem_size = size;

   s->length = 0;

   s->freefn = freefn;

   s->cmpfn = cmpfn;
}


//判断队列为空

int emptyQueue(Queue *q)

{

   return q->length==0;

}


//求队列长度

int sizeQueue(Queue *q)

{

   return q->length;

}


//获得队列头部元素

void* frontQueue(Queue *q)

{

   Node *n = q->item;

   return (n!=NULL ? n->elem : NULL);

}


//获得队列尾部元素

void* backQueue(Queue *q)

{

   Node *n = q->item;

   while(n->next!=NULL)

   {

       n = n->next;

   }

   return (n!=NULL ? n->elem : NULL);

}


//弹出（删除）队列头部元素

void popQueue(Queue *q)

{

   Node *n = q->item;

   Node *temp;

   if(n==NULL)

   {

       return;

   }

   temp = n->next;


   if(q->freefn!=NULL)

   {

       q->freefn(n->elem);     //释放函数外面动态分配的内存

   }

   free(n->elem);  //释放元素空间

   free(n);        //释放节点空间

   q->length--;    //队列长度减1

   q->item = temp;

}


//元素入队列尾部

void pushQueue(Queue *q,void *value)

{

   Node *n,*nn;

   n = q->item;

   while(n!=NULL && n->next!=NULL)

   {

       n = n->next;

   }


   nn = (Node*)malloc(sizeof(Node));

   nn->next = NULL;

   nn->elem = malloc(q->elem_size);    //为元素申请空间

   memcpy(nn->elem, value, q->elem_size);

   if(q->item==NULL)

   {

       q->item = nn;

   }

   else

   {

       n->next = nn;

   }

   q->length++;

}


//删除队列

void destoryQueue(Queue *q)
{
   Node *n=q->item;
   Node *temp;
   while(n!=NULL)//释放节点n
   {
       temp = n->next;
       if(q->freefn!=NULL)
       {
           q->freefn(n->elem);     //释放函数外面动态分配的内存
       }
       free(n->elem);
       free(n);
       n = temp;
   }
   q = NULL;
}

int existQueue(Queue *q,void *value)

{
   Node *n=q->item;
   while(n)
   {
       if (q->cmpfn(n->elem, value)) {
           return 1;
       }
       n = n->next;
   }
   return 0;
}

