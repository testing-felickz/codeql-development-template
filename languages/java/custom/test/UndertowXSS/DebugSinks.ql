/**
 * @name Debug Undertow sinks
 * @description Check if Undertow sinks are recognized
 * @kind problem
 * @id java/test/undertow-sinks-debug
 */

import java
import semmle.code.java.security.XSS

from XssSink sink
where sink.getLocation().getFile().getBaseName() = "UndertowExample.java"
select sink, "XSS sink found"
