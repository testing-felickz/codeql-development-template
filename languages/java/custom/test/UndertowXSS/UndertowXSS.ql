/**
 * @name Test Undertow XSS detection
 * @description Test query to validate Undertow source and sink models
 * @kind path-problem
 * @problem.severity warning
 * @id java/test/undertow-xss-test
 * @tags security
 */

import java
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.security.XSS

/**
 * A taint-tracking configuration for testing Undertow XSS.
 */
module UndertowXSSConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof RemoteFlowSource }

  predicate isSink(DataFlow::Node sink) { sink instanceof XssSink }
}

/** Tracks flow from remote sources to XSS sinks. */
module UndertowXSSFlow = TaintTracking::Global<UndertowXSSConfig>;

import UndertowXSSFlow::PathGraph

from UndertowXSSFlow::PathNode source, UndertowXSSFlow::PathNode sink
where UndertowXSSFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "XSS vulnerability: user input from $@ flows to HTTP response.",
  source.getNode(), "remote source"
