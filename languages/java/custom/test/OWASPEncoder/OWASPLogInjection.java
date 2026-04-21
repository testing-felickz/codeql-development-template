import javax.servlet.http.HttpServletRequest;
import org.owasp.encoder.Encode;
import java.util.logging.Logger;

public class OWASPLogInjection {
    private static final Logger logger = Logger.getLogger("test");

    public void testSanitizedLogging(HttpServletRequest request) {
        String tainted = request.getParameter("input");
        // Safe: sanitized with OWASP Encoder before logging
        String sanitized = Encode.forJava(tainted);
        logger.info(sanitized);
    }

    public void testUnsanitizedLogging(HttpServletRequest request) {
        String tainted = request.getParameter("input");
        // Unsafe: tainted data logged directly
        logger.info(tainted);
    }
}
