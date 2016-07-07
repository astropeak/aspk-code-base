import java.net.Socket; 
import java.net.UnknownHostException; 
import java.io.IOException;

class Test {
    public static void main(String[] args) {
        // public Socket(String host, int port) throw UnknownHostException, IOExecption;
        try {
            Socket sk = new Socket("aaalocalhost", 9999);
        } catch (UnknownHostException e){
            System.out.println("UnknownHostException");
            e.printStackTrace();
        } catch (IOException e) {
            System.out.println("IOException");
            e.printStackTrace();
        }
    }
}