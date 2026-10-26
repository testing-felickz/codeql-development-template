/**
 * @name Brotli decoding API use
 * @description Identifies JavaScript API uses that can enable Brotli decoding and may be relevant to CVE-2026-111497. This is a source-level API inventory; it does not verify affected runtime versions or prove that untrusted compressed data reaches a vulnerable decoder.
 *
 * Matching is syntactic: decoder APIs are matched by call name, browser transports by
 * their global names, Express/body-parser middleware by conventional module-variable
 * names, and TLS options only when present as inline object arguments to common TLS
 * methods. Arbitrary aliases, options-object flows, and indirect calls are not resolved.
 * @kind problem
 * @problem.severity warning
 * @security-severity 5.0
 * @precision medium
 * @id javascript/cve-2026-111497-brotli-api
 * @tags security
 *       external/cve/cve-2026-111497
 */

import javascript

private predicate isBrotliOrUnknownFormat(Expr format) {
  format.getStringValue() = "brotli" or
  not exists(string value | value = format.getStringValue())
}

private predicate isBrotliDecoderApi(InvokeExpr call) {
  call.getCalleeName() in [
      "brotliDecompress",
      "brotliDecompressSync",
      "createBrotliDecompress",
      "BrotliDecompress",
      "iterdecompressBrotli",
      "decompressBrotliSync"
    ]
}

private predicate isGlobalTransportApi(InvokeExpr call) {
  call.getCallee().accessesGlobal("fetch") and call.getCalleeName() = "fetch"
  or
  call.getCallee().accessesGlobal("EventSource") and call.getCalleeName() = "EventSource"
  or
  call.getCallee().accessesGlobal("WebSocket") and call.getCalleeName() = "WebSocket"
}

private predicate isDecompressionStreamApi(NewExpr call) {
  call.getCallee().accessesGlobal("DecompressionStream") and
  call.getCalleeName() = "DecompressionStream" and
  exists(Expr format |
    format = call.getArgument(0) and
    isBrotliOrUnknownFormat(format)
  )
}

private predicate isTlsCertificateCompression(Property option) {
  option.getName() = "certificateCompression" and
  isBrotliOrUnknownFormat(option.getInit()) and
  exists(InvokeExpr call, DotExpr callee |
    callee = call.getCallee() and
    callee.getBase().(VarRef).getName() in ["tls", "https"] and
    call.getCalleeName() in ["connect", "createServer", "createSecureContext"] and
    call.getAnArgument() = option.getObjectExpr()
  )
}

private predicate isExpressBrotliParser(InvokeExpr call) {
  call.getCalleeName() in ["json", "raw", "text", "urlencoded"] and
  exists(DotExpr callee |
    callee = call.getCallee() and
    callee.getBase().(VarRef).getName() in ["express", "bodyParser"]
  )
}

from AstNode api
where
  exists(InvokeExpr call |
    api = call and
    (
      isBrotliDecoderApi(call) or
      isGlobalTransportApi(call) or
      isDecompressionStreamApi(call.(NewExpr)) or
      isExpressBrotliParser(call)
    )
  )
  or
  exists(Property option | api = option and isTlsCertificateCompression(option))
select api,
  "This API use can enable or negotiate Brotli decoding and may be relevant to CVE-2026-111497."
