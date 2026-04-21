/**
 * @name OWASP Encoder Log Injection
 * @description Building log entries from user-controlled data may allow
 *              insertion of forged log entries by malicious users.
 *              This query extends the standard log-injection analysis with
 *              an additional barrier for OWASP Java Encoder sanitization.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision medium
 * @id java/owasp-log-injection
 * @tags security
 *       external/cwe/cwe-117
 */

import java
import semmle.code.java.security.LogInjectionQuery
import LogInjectionFlow::PathGraph

/**
 * A sanitizer that recognizes OWASP Java Encoder `Encode.forJava()` calls
 * as barriers against log injection. The `forJava` method encodes special
 * characters (including newlines) using Java string escape sequences,
 * preventing log forging attacks.
 */
class OWASPEncoderLogInjectionSanitizer extends LogInjectionSanitizer {
  OWASPEncoderLogInjectionSanitizer() {
    exists(MethodCall ma |
      ma.getMethod().getDeclaringType().hasQualifiedName("org.owasp.encoder", "Encode") and
      ma.getMethod().hasName("forJava") and
      this.asExpr() = ma
    )
  }
}

from LogInjectionFlow::PathNode source, LogInjectionFlow::PathNode sink
where LogInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This log entry depends on a $@.", source.getNode(),
  "user-provided value"
