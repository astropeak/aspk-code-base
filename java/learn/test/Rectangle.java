package test;
import test.*;

public class Rectangle implements Shape{
    double width;
    double height;
    Rectangle(double w, double h) {
        width=w;
        height=h;
    }
    public void info(){
        System.out.println("Rectangle info:");
        System.out.println("  width:"+width);
        System.out.println("  height:"+height);
        System.out.println("  area:"+area());
    }
    public double area(){
        return width*height;
    }
}