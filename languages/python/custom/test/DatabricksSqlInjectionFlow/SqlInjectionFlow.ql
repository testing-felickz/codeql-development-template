/**
 * @kind path-problem
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import semmle.python.security.dataflow.SqlInjectionCustomizations

module SqlInjectionFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof SqlInjection::Source }
  
  predicate isSink(DataFlow::Node sink) { sink instanceof SqlInjection::Sink }
}

module SqlInjectionFlow = TaintTracking::Global<SqlInjectionFlowConfig>;

import SqlInjectionFlow::PathGraph

from SqlInjectionFlow::PathNode source, SqlInjectionFlow::PathNode sink
where SqlInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "SQL query vulnerable to injection from $@.",
  source.getNode(), "user-provided value"
