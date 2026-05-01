import org.owasp.encoder.Encode;
import org.apache.logging.log4j.Logger;

public class LogInjectionExternalBarrierTest {

    public Object source() {
        return null;
    }

    public static boolean isSafeLogInput(String input) {
        return input != null && !input.contains("\n") && !input.contains("\r");
    }

    // Test: barrierModel - direct sanitizer via return value
    public void testOwaspEncoderBarrier(Logger logger) {
        String tainted = (String) source(); // $ Source

        // Unsafe: tainted input flows directly to log
        logger.info("Order: {}", tainted); // $ Alert

        // Safe: Encode.forJava sanitizes control characters (barrier via barrierModel)
        logger.info("Order: {}", Encode.forJava(tainted)); // Safe
    }

    // Test: barrierGuardModel - conditional guard that blocks flow
    public void testBarrierGuard(Logger logger) {
        String tainted = (String) source(); // $ Source

        // Safe: isSafeLogInput acts as a barrier guard (via barrierGuardModel)
        if (isSafeLogInput(tainted)) {
            logger.info("Guarded: {}", tainted); // Safe - guarded by barrierGuardModel
        }

        // Unsafe: no guard on this path
        logger.info("Unguarded: {}", tainted); // $ Alert
    }
}
