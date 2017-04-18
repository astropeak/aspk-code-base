#include <iostream>
using namespace std;

class A1;
class A2;
class V {
public:
    virtual void visit(A1& a1){
        cout<<"V: a1"<<endl;
    }
    virtual void visit(A2& a2){
        cout<<"V: a2"<<endl;
    }
};
class V1:public V {
public:
    void visit(A1& a1){
        cout<<"V1: a1"<<endl;
    }
    void visit(A2& a2){
        cout<<"V1: a2"<<endl;
    }
};
class V2:public V {
public:
    void visit(A1& a1){
        cout<<"V2: a1"<<endl;
    }
    void visit(A2& a2){
        cout<<"V2: a2"<<endl;
    }
};
class A {
public:
    virtual void accept(V& v) {
        v.visit(*this);
    }
};
class A1:public A{
public:
    // void accept(V& v){
    //     v.visit(*this);
    // }
};
class A2:public A{
public:
    // void accept(V& v){
    //     v.visit(*this);
    // }
};

int main(){
    A1 a1;
    A2 a2;
    A* a = &a1;
    V1 v1;
    V2 v2;
    V* v=&v1;
    a->accept(*v);
    v=&v2;
    a->accept(*v);
    a = &a2;
    v=&v1;
    a->accept(*v);
    v=&v2;
    a->accept(*v);

    return 0;
}
