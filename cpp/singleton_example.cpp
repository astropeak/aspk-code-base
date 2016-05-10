#include <iostream>
using namespace std;
#include "singleton.hpp"


class User:public Singleton<User>{
public:
    char* getName(){
        return _name;
    }

protected:
    friend class Singleton<User>;
    User(){
        cout<<"User constructer"<<endl;
        _name="HHHH";
    }

private:
    char* _name;
};

int main(int argc, char *argv[])
{
    char* n="Name";
    // User u1;
    // cout<<"U1: "<<u1.getName()<<endl;

    User* u=User::instance();

    cout<<u->getName()<<endl;

    return 0;
}

