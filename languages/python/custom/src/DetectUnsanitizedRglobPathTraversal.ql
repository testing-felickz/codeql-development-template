/**
 * @name Uncontrolled data used in path expression (with pathlib sanitizer support)
 * @description Accessing paths influenced by users can allow an attacker to access
 *              unexpected resources. This query extends the standard py/path-injection
 *              analysis to recognize `pathlib.Path.resolve()` as path normalization
 *              and `pathlib.Path.is_relative_to()` as a safe access check.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @id python/detect-unsanitized-rglob-path-traversal
 * @tags security
 *       external/cwe/cwe-022
 */

import python
// Import custom sanitizer extensions; these extend Path::PathNormalization::Range
// and Path::SafeAccessCheck::Range so the standard PathInjectionConfig picks them up.
import PathInjectionSanitizers
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(),
  "user-provided value"
