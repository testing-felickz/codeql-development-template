import python
import TestUtilities.InlineExpectationsTest
import experimental.semmle.python.Concepts

module DatabricksSqlInjectionTest implements TestSig {
  string getARelevantTag() { result = "sinkModel" }

  predicate hasActualResult(Location location, string element, string tag, string value) {
    tag = "sinkModel" and
    exists(SqlExecution exec, DataFlow::Node sink |
      sink = exec.getSql() and
      location = sink.getLocation() and
      element = sink.toString() and
      value = "sql-injection"
    )
  }
}

import MakeTest<DatabricksSqlInjectionTest>
