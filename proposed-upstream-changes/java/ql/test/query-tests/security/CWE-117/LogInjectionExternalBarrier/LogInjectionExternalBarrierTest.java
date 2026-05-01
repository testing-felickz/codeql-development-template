import org.owasp.encoder.Encode;
import org.apache.logging.log4j.Logger;

public class LogInjectionExternalBarrierTest {

    public Object source() {
        return null;
    }

    public void testOwaspEncoderBarrier(Logger logger) {
        String tainted = (String) source(); // $ Source

        // Unsafe: tainted input flows directly to log
        logger.info("Order: {}", tainted); // $ Alert

        // Safe: Encode.forJava sanitizes control characters (barrier via data extension)
        logger.info("Order: {}", Encode.forJava(tainted)); // Safe
    }

    public void testOwaspEncoderForJavaSecondFlow(Logger logger) {
        String tainted = (String) source(); // $ Source

        // Unsafe: direct use of tainted data
        logger.info("Unsafe: {}", tainted); // $ Alert

        // Safe: Encode.forJava sanitizes control characters
        logger.info("Safe forJava: {}", Encode.forJava(tainted)); // Safe
    }
}
