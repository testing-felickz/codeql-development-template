# Proposed Upstream Changes to `github/codeql`

## Summary

This directory contains **proposed modifications** to the `github/codeql` repository's built-in Java QLL libraries to make `LogInjection.qll` natively extensible via the `barrierModel` data extension mechanism.

## Problem

The upstream `LogInjection.qll` in `codeql/java-all` lacks integration with the `barrierModel` extensible predicate. This means third-party sanitizer libraries (like OWASP Java Encoder's `Encode.forJava()`) cannot be declared as log injection barriers via data extension YAML files — unlike other queries such as:

- **XSS** (`XSS.qll`) → has `ExternalXssSanitizer` using `barrierNode(this, ["html-injection", "js-injection"])`
- **Command Injection** (`CommandLineQuery.qll`) → has external sanitizer support
- **Path Injection** (`PathSanitizer.qll`) → has external sanitizer support

## Proposed Fix

Add a single private class `ExternalLogInjectionSanitizer` to `LogInjection.qll` that extends `LogInjectionSanitizer` and uses `barrierNode(this, "log-injection")`. This is a **4-line addition** that follows the exact same pattern used in `XSS.qll`.

## Impact

Once this change is merged upstream, users can declare log injection sanitizers via data extension YAML without needing:
1. A custom `.qll` file to bridge the gap
2. A custom `.ql` query that re-implements the standard query with the sanitizer imported

## Files

| File | Purpose |
|------|---------|
| `java/ql/lib/semmle/code/java/security/LogInjection.qll.patch` | Unified diff showing the change |
| `java/ql/lib/semmle/code/java/security/LogInjection.qll` | Complete modified file |
| `java/ql/test/query-tests/security/CWE-117/LogInjectionExternalBarrier/` | Test case for external barrier |

## Usage After Upstream Merge

Once merged, users only need a data extension YAML to register sanitizers:

```yaml
extensions:
  - addsTo:
      pack: codeql/java-all
      extensible: barrierModel
    data:
      - ["org.owasp.encoder", "Encode", False, "forJava", "(String)", "", "ReturnValue", "log-injection", "manual"]
```

No custom `.qll` or `.ql` files needed — the standard `java/log-injection` query will natively respect the barrier.

## Related

- Issue: https://github.com/testing-felickz/codeql-development-template/issues/31
- PR #33 (workaround approach): https://github.com/testing-felickz/codeql-development-template/pull/33
