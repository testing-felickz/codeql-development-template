/**
 * @name Debug Undertow sources
 * @description Check if Undertow sources are recognized
 * @kind problem
 * @id java/test/undertow-sources-debug
 */

import java
import semmle.code.java.dataflow.FlowSources

from RemoteFlowSource source
where source.getLocation().getFile().getBaseName() = "UndertowExample.java"
select source, "Remote source found"
