class A {
}
class A1 extends A {}
class A2 extends A {}

class Test {
    static void foo(A a) {
    }
    public static void main(String[] args) {
        foo(new A1());
    }
}