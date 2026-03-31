# Undertow XSS Data Extension Tests

This directory contains tests for the Undertow HTTP library data extension models.

## Overview

The Undertow data extension models enable CodeQL to detect security vulnerabilities in applications using the [Undertow](https://undertow.io/) HTTP server library. The models define sources and sinks for taint tracking analysis.

## Models Defined

### Sources
- **`io.undertow.server.HttpServerExchange.getQueryParameters()`**
  - Returns: `Map<String, Deque<String>>`
  - Description: Query parameters from HTTP request (user-controlled data)
  - Kind: `remote` (remote flow source)

### Sinks
- **`io.undertow.io.Sender.send(String)`**
- **`io.undertow.io.Sender.send(String, IoCallback)`**
- **`io.undertow.io.Sender.send(String, Charset)`**
- **`io.undertow.io.Sender.send(String, Charset, IoCallback)`**
- **`io.undertow.io.Sender.send(ByteBuffer)`**
- **`io.undertow.io.Sender.send(ByteBuffer, IoCallback)`**
- **`io.undertow.io.Sender.send(ByteBuffer[])`**
- **`io.undertow.io.Sender.send(ByteBuffer[], IoCallback)`**
  - Description: Sends HTTP response content
  - Kind: `html-injection` (XSS sink)

## Test Files

### UndertowExample.java
Example vulnerable code that demonstrates an XSS vulnerability:
- **Line 17**: User input from query parameter `namex` via `getQueryParameters()`
- **Line 22**: Unsanitized data sent in HTTP response via `send()`

### UndertowXSS.ql
Main test query that detects XSS vulnerabilities using the data extension models.

### UndertowXSS.expected
Expected test output showing the detected vulnerability.

### DebugSources.ql
Debug query to verify that sources are properly recognized.

### DebugSinks.ql
Debug query to verify that sinks are properly recognized.

## Running the Tests

### Using existing database:
```bash
# Run the main XSS detection query
codeql query run UndertowXSS.ql -d db/ --output=results.bqrs
codeql bqrs decode results.bqrs --format=text

# Run debug queries
codeql query run DebugSources.ql -d db/ --output=sources.bqrs
codeql bqrs decode sources.bqrs --format=text

codeql query run DebugSinks.ql -d db/ --output=sinks.bqrs
codeql bqrs decode sinks.bqrs --format=text
```

### Creating a new test database:
```bash
# Create database (this will also build the code)
codeql database create db-new --language=java --command="./gradlew clean build"

# Run queries against new database
codeql query run UndertowXSS.ql -d db-new/
```

## Expected Results

The main query should detect **1 XSS vulnerability**:
- **Source**: `getQueryParameters()` call on line 17
- **Sink**: String concatenation expression on line 22
- **Path**: Query parameter → local variable → string concatenation → HTTP response

## Key Implementation Details

### Model Format Fixes Applied

1. **Signature Format**: Use CodeQL format `(String)` not JVM format `(Ljava/lang/String;)V`
2. **Boolean Values**: Use `False` (YAML/Python style) not `false` (Java style)
3. **Sink Kind**: Use `html-injection` (CodeQL XSS library expects this) not `xss`
4. **Source Access Path**: Use `ReturnValue` (CodeQL handles Map/Collection elements automatically) not `ReturnValue.MapValue.Element`

### Query Implementation

The test query uses:
- `RemoteFlowSource` class to match sources defined in the model
- `XssSink` class to match sinks defined in the model
- Modern CodeQL module-based taint tracking configuration
- `TaintTracking::Global<ConfigSig>` for global taint analysis

## References

- [Undertow Documentation](https://undertow.io/)
- [CodeQL Data Extensions Documentation](https://codeql.github.com/docs/codeql-language-guides/data-extensions/)
- [CodeQL Java Security Queries](https://github.com/github/codeql/tree/main/java/ql/src/Security)
