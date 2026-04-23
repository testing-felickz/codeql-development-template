import org.owasp.encoder.Encode;
import org.slf4j.Logger;

public class LogInjectionOwaspEncoder {

    public Object source() {
        return null;
    }

    public void testOwaspEncoderForJavaSanitizer(Logger logger) {
        String tainted = (String) source(); // $ Source
        logger.info("Unsafe: {}", tainted); // $ Alert
        logger.info("Safe: {}", Encode.forJava(tainted)); // Safe - sanitized by Encode.forJava
    }
}
