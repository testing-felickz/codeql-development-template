/** Provides additional sanitizers for log injection via data extension barrier models. */

import java
private import semmle.code.java.dataflow.ExternalFlow
private import semmle.code.java.security.LogInjection

/**
 * A sanitizer for log injection that is defined via a barrier model
 * in a data extension.
 */
private class ExternalLogInjectionSanitizer extends LogInjectionSanitizer {
  ExternalLogInjectionSanitizer() { barrierNode(this, "log-injection") }
}
