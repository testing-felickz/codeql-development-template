# Undertow CodeQL Data Extension - Implementation Summary

## Overview

Successfully developed and tested a CodeQL data extension for the Undertow HTTP library in Java. The extension enables detection of Cross-Site Scripting (XSS) vulnerabilities in applications using the Undertow web server.

## Implementation Location

- **Model File**: `/languages/java/custom/src/undertow.model.yml`
- **Test Directory**: `/languages/java/custom/test/UndertowXSS/`

## Models Implemented

### 1. Remote Flow Source
- **Method**: `io.undertow.server.HttpServerExchange.getQueryParameters()`
- **Return Type**: `Map<String, Deque<String>>`
- **Description**: Captures query parameters from HTTP requests
- **Classification**: Remote user input (untrusted data source)

### 2. XSS Sinks (8 overloads)
All `io.undertow.io.Sender.send()` method overloads that write HTTP response content:
- `send(String)`
- `send(String, IoCallback)`
- `send(String, Charset)`
- `send(String, Charset, IoCallback)`
- `send(ByteBuffer)`
- `send(ByteBuffer, IoCallback)`
- `send(ByteBuffer[])`
- `send(ByteBuffer[], IoCallback)`

## Key Fixes Applied

### 1. Signature Format
**Problem**: Used JVM bytecode format `(Ljava/lang/String;)V`  
**Solution**: Use CodeQL string signature format `(String)`

### 2. Boolean Capitalization
**Problem**: Used Java-style `false`  
**Solution**: Use YAML/Python-style `False`

### 3. Sink Kind
**Problem**: Used generic `"xss"`  
**Solution**: Use CodeQL-specific `"html-injection"` (required by `XssSink` class)

### 4. Source Access Path
**Problem**: Used overly specific `"ReturnValue.MapValue.Element"`  
**Solution**: Use simplified `"ReturnValue"` (CodeQL automatically handles Map values and Collection elements)

## Test Results

✅ **All tests passing**

### Debug Sources Query
```
| source                  | col1                |
+-------------------------+---------------------+
| getQueryParameters(...) | Remote source found |
```

### Debug Sinks Query
```
| sink      | col1           |
+-----------+----------------+
| ... + ... | XSS sink found |
```

### Main XSS Detection Query
```
Detected 1 XSS vulnerability:
- Source: Line 17 - getQueryParameters()
- Sink: Line 22 - String concatenation in send()
- Path: Query parameter → local variable → string concatenation → HTTP response
```

## Vulnerability Detected in Test Code

The test successfully identifies this XSS vulnerability:

```java
// Line 17: Source - User input from query parameter
Deque<String> res = exchange.getQueryParameters().get("namex");
if (res != null) {
    name = res.getFirst();
}

// Line 22: Sink - Unsanitized data in HTTP response
exchange.getResponseSender().send("<html><body>Hello " + name + "</body></html>");
```

**Attack Vector**: An attacker can inject malicious JavaScript via the `namex` parameter:
```
http://localhost:8080/?namex=<script>alert('XSS')</script>
```

## Files Modified

1. **languages/java/custom/src/undertow.model.yml**
   - Fixed source model (1 entry)
   - Fixed sink models (8 entries)

2. **languages/java/custom/test/UndertowXSS/UndertowXSS.ql**
   - Updated to use modern CodeQL module-based syntax
   - Uses `RemoteFlowSource` and `XssSink` from data extensions

3. **languages/java/custom/test/UndertowXSS/UndertowXSS.expected**
   - Updated to match actual CodeQL output format

## Files Created

1. **languages/java/custom/test/UndertowXSS/README.md**
   - Comprehensive documentation of the models and tests

2. **languages/java/custom/test/UndertowXSS/DebugSources.ql**
   - Debug query to verify source detection

3. **languages/java/custom/test/UndertowXSS/DebugSinks.ql**
   - Debug query to verify sink detection

## Verification Commands

```bash
# Navigate to test directory
cd languages/java/custom/test/UndertowXSS

# Run main XSS detection query
codeql query run UndertowXSS.ql -d db/ --output=results.bqrs
codeql bqrs decode results.bqrs --format=text

# Run debug queries
codeql query run DebugSources.ql -d db/ --output=sources.bqrs
codeql bqrs decode sources.bqrs --format=text

codeql query run DebugSinks.ql -d db/ --output=sinks.bqrs
codeql bqrs decode sinks.bqrs --format=text
```

## Development Approach

Followed Test-Driven Development (TDD) principles:

1. **Red Phase**: Identified that existing models weren't working (no sources/sinks detected)
2. **Debug Phase**: Created debug queries to understand the problem
3. **Analysis Phase**: Examined method signatures and CodeQL internals
4. **Fix Phase**: Applied corrections to model format and parameters
5. **Green Phase**: Verified all queries return expected results
6. **Refactor Phase**: Cleaned up temporary debug files and added documentation

## CodeQL Version

- **CodeQL CLI**: 2.23.5
- **Java Library**: codeql/java-all@7.7.3

## Security Impact

This data extension enables CodeQL to automatically detect XSS vulnerabilities in Undertow-based applications, helping developers:
- Identify unsafe handling of user input
- Detect missing output encoding/sanitization
- Prevent injection attacks in HTTP responses
- Secure web applications at development time

## Next Steps (Optional Enhancements)

1. Add summary models for common sanitization methods
2. Add models for additional sources (cookies, headers, path parameters)
3. Add models for other security-sensitive sinks (redirects, SQL injection, etc.)
4. Create additional test cases covering edge cases
5. Submit models to CodeQL community repository

## References

- [Undertow Documentation](https://undertow.io/)
- [CodeQL Data Extensions](https://codeql.github.com/docs/codeql-language-guides/data-extensions/)
- [CodeQL XSS Query](https://github.com/github/codeql/blob/main/java/ql/src/Security/CWE/CWE-079/XSS.ql)
- [Model Format Specification](https://codeql.github.com/docs/codeql-cli/creating-codeql-databases/#model-format)
