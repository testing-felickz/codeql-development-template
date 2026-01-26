/**
 * @name Test Undertow XSS detection
 * @description Test query to validate Undertow source and sink models
 * @kind path-problem
 * @problem.severity warning
 * @id java/test/undertow-xss-test
 * @tags security
 */

import java
import semmle.code.java.dataflow.TaintTracking
import DataFlow::PathGraph

class UndertowXSSConfig extends TaintTracking::Configuration {
  UndertowXSSConfig() { this = "UndertowXSSConfig" }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr().(MethodAccess).getMethod().hasName("getQueryParameters")
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(MethodAccess ma |
      ma.getMethod().hasName("send") and
      sink.asExpr() = ma.getAnArgument()
    )
  }
}

from UndertowXSSConfig config, DataFlow::PathNode source, DataFlow::PathNode sink
where config.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "XSS vulnerability: user input from $@ flows to HTTP response.",
  source.getNode(), "query parameter"
