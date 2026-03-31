import python
import semmle.python.security.dataflow.SqlInjectionCustomizations

from SqlInjection::Sink sink
select sink, "SQL injection sink"

