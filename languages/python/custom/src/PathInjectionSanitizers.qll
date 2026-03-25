/**
 * Provides custom sanitizer extensions for the standard `py/path-injection` query.
 *
 * This module extends the CodeQL standard library's path injection analysis
 * to recognize additional sanitization patterns:
 *
 * 1. `pathlib.Path.resolve()` as a path normalization step
 * 2. `pathlib.Path.is_relative_to()` as a safe access check
 *
 * These extensions enable the standard query to understand that a pattern like:
 * ```python
 * resolved = job_dir.resolve()
 * if not resolved.is_relative_to(JOBS_ROOT):
 *     raise ValueError("path escapes root")
 * matches = list(resolved.rglob("summary.csv"))
 * ```
 * properly sanitizes the path before use.
 *
 * NOTE: If contributing to the CodeQL standard library (re-bundling), these
 * extensions should be added directly to `semmle/python/frameworks/Stdlib.qll`:
 * - `PathlibResolveCall` alongside `OsPathRealpathCall` (around line 1065)
 * - `IsRelativeToCall` alongside `StartswithCall` (around line 5090)
 */

private import python
private import semmle.python.dataflow.new.DataFlow
private import semmle.python.Concepts

/**
 * A call to `pathlib.Path.resolve()`, modeled as a path normalization step.
 *
 * `resolve()` makes the path absolute and resolves all symlinks, producing
 * a canonical path. This is semantically equivalent to `os.path.realpath()`,
 * which is already modeled as `Path::PathNormalization::Range` in the
 * standard library.
 *
 * See https://docs.python.org/3/library/pathlib.html#pathlib.Path.resolve
 */
private class PathlibResolveCall extends Path::PathNormalization::Range, DataFlow::CallCfgNode {
  DataFlow::AttrRead resolveAttr;

  PathlibResolveCall() {
    resolveAttr.getAttributeName() = "resolve" and
    resolveAttr.(DataFlow::LocalSourceNode).flowsTo(this.getFunction())
  }

  override DataFlow::Node getPathArg() { result = resolveAttr.getObject() }
}

/**
 * A call to `pathlib.PurePath.is_relative_to()`, modeled as a safe access check.
 *
 * `is_relative_to(other)` returns `True` if the path is relative to `other`,
 * which is commonly used as a path confinement check to verify that a resolved
 * path remains within an expected directory. This is semantically similar to
 * `str.startswith()`, which is already modeled as `Path::SafeAccessCheck::Range`
 * in the standard library.
 *
 * See https://docs.python.org/3/library/pathlib.html#pathlib.PurePath.is_relative_to
 */
private class IsRelativeToCall extends Path::SafeAccessCheck::Range {
  IsRelativeToCall() {
    this.(CallNode).getFunction().(AttrNode).getName() = "is_relative_to"
  }

  override predicate checks(ControlFlowNode node, boolean branch) {
    node = this.(CallNode).getFunction().(AttrNode).getObject() and
    branch = true
  }
}
