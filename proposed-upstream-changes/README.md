# Proposed Upstream Changes to `github/codeql`

## Summary

This directory contains **proposed modifications** to the `github/codeql` repository's built-in Java QLL libraries to make `LogInjection.qll` natively extensible via both the `barrierModel` and `barrierGuardModel` data extension mechanisms.

## Problem

The upstream `LogInjection.qll` in `codeql/java-all` lacks integration with the `barrierModel` and `barrierGuardModel` extensible predicates. This means third-party sanitizer libraries (like OWASP Java Encoder's `Encode.forJava()`) and custom validation guards cannot be declared as log injection barriers via data extension YAML files — unlike other queries such as:

- **XSS** (`XSS.qll`) → has `ExternalXssSanitizer` using `barrierNode(this, ["html-injection", "js-injection"])`
- **Command Injection** (`CommandLineQuery.qll`) → has external sanitizer support
- **Path Injection** (`PathSanitizer.qll`) → has external sanitizer support

## Proposed Fix

Add a single private class `ExternalLogInjectionSanitizer` to `LogInjection.qll` that extends `LogInjectionSanitizer` and uses `barrierNode(this, "log-injection")`. The `barrierNode` predicate in `ExternalFlow.qll` already resolves **both**:

- **`barrierModel`** — direct barriers (e.g., sanitizer method return values that neutralize taint)
- **`barrierGuardModel`** — conditional barrier guards (e.g., validation methods that block flow when they return true/false)

This is a single class addition that follows the exact same pattern used in `XSS.qll`.

## Impact

Once this change is merged upstream, users can declare log injection sanitizers via data extension YAML without needing:
1. A custom `.qll` file to bridge the gap
2. A custom `.ql` query that re-implements the standard query with the sanitizer imported

## Files

| File | Purpose |
|------|---------|
| `java/ql/lib/semmle/code/java/security/LogInjection.qll.patch` | Unified diff showing the change |
| `java/ql/lib/semmle/code/java/security/LogInjection.qll` | Complete modified file |
| `java/ql/test/query-tests/security/CWE-117/LogInjectionExternalBarrier/` | Test cases for both barrierModel and barrierGuardModel |

## Usage After Upstream Merge

### Using `barrierModel` (direct sanitizers)

Register a method whose return value is sanitized:

```yaml
extensions:
  - addsTo:
      pack: codeql/java-all
      extensible: barrierModel
    data:
      # Schema: (package, type, subtypes, name, signature, ext, output, kind, provenance)
      - ["org.owasp.encoder", "Encode", False, "forJava", "(String)", "", "ReturnValue", "log-injection", "manual"]
```

### Using `barrierGuardModel` (conditional guards)

Register a method that acts as a validation guard — when it returns the specified value, the input is considered safe:

```yaml
extensions:
  - addsTo:
      pack: codeql/java-all
      extensible: barrierGuardModel
    data:
      # Schema: (package, type, subtypes, name, signature, ext, input, acceptingValue, kind, provenance)
      - ["com.example", "Validator", False, "isSafeForLog", "(String)", "", "Argument[0]", "true", "log-injection", "manual"]
```

No custom `.qll` or `.ql` files needed — the standard `java/log-injection` query will natively respect both barrier types.

## Related

- Issue: https://github.com/testing-felickz/codeql-development-template/issues/31
- PR #33 (workaround approach): https://github.com/testing-felickz/codeql-development-template/pull/33
- [Customizing library models for Java and Kotlin](https://codeql.github.com/docs/codeql-language-guides/customizing-library-models-for-java-and-kotlin/)

