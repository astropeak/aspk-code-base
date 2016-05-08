#include <iostream>
#include <typeinfo>

using std::cout;
using std::endl;

class SpaceShip;
class SpaceStation;
class Asteroid;


class GameObject {
public:
    // GameObject(char* name){
        // this->name=name;
    // }

    virtual void collide (GameObject& obj) = 0;

    // virtual void collide (SpaceShip& ssh);
    // virtual void collide (SpaceStation& ssh);
    char* name;
};

class SpaceShip:public GameObject{
public:
    void collide (GameObject& obj){
        cout<<"I am here"<<endl;
        cout<<"run time id of this: "<<typeid(*this).name()<<"."<<endl;
        cout<<"run time id of obj: "<<typeid(obj).name()<<"."<<endl;
        obj.collide(*this);
    }
    void collide (Asteroid& ast){
        cout<<"Space ship collide with ast"<<endl;
    }
    void collide (SpaceStation& sta){
        cout<<"Space ship collide with sta"<<endl;
    }
};

class SpaceStation:public GameObject{
public:
    void collide (GameObject& obj){
        cout<<"I am in SpaceStation"<<endl;
        obj.collide(*this);
    }

    void collide (Asteroid& ast){
        cout<<"Space station collide with ast"<<endl;
    }
    void collide (SpaceShip& ssh){
        cout<<"Space station collide with ship"<<endl;
    }
};

int main(){
    // char* name = "aaa";
    SpaceShip ssh;
    SpaceStation sst;
    GameObject& g1= ssh;
    GameObject& g2= sst;
    g1.collide(sst);

    return 0;
}