template <class TYPE>
class Singleton {
public:
    static TYPE* instance() {
        static TYPE* _instance;
        if (!_instance){
            _instance = new TYPE;
        }
        return _instance;
    }

protected:
    Singleton(){
        cout<<"Singleton Constructer"<<endl;
    };
};