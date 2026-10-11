import java.nio.channels.Pipe;
import java.nio.channels.Selector;

/** Reproduces the Windows JDK pipe failure independently of Flutter/Gradle. */
public class JavaLoopbackProbe {
    public static void main(String[] args) throws Exception {
        try (var selector = Selector.open()) {
            System.out.println("Selector PASS: " + selector.getClass().getName());
        }
        var pipe = Pipe.open();
        try (var source = pipe.source(); var sink = pipe.sink()) {
            System.out.println("Pipe PASS");
        }
    }
}
