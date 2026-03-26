---
mode: agent
---

# CodeQL Data Extensions / Models as Data / Model Packs

This prompt provides common guidance for developing CodeQL data extensions across all supported languages, while language-specific prompts reference this common guidance and add language-specific details.

## Product Documentation

- [Extending coverage for a repository](https://docs.github.com/en/code-security/how-tos/scan-code-for-vulnerabilities/manage-your-configuration/editing-your-configuration-of-default-setup#extending-coverage-for-a-repository) - `.github/codeql/extensions directory` for local model pack refrences (does not need a qlpack.yml)
- [Extending coverage for all repositories in an organization](https://docs.github.com/en/code-security/how-tos/scan-code-for-vulnerabilities/manage-your-configuration/editing-your-configuration-of-default-setup#extending-coverage-for-all-repositories-in-an-organization) - publishing model packs and referencing them globally (must be done click button in UI)
- [Creating a CodeQL model pack](https://docs.github.com/en/code-security/tutorials/customize-code-scanning/creating-and-working-with-codeql-packs?versionId=free-pro-team%40latest&productId=code-security&restPage=how-tos%2Cscan-code-for-vulnerabilities%2Cmanage-your-configuration%2Cediting-your-configuration-of-default-setup#creating-a-codeql-model-pack) - publishing a model pack + for dataExtensions via qlpack.yml

## Core Principles
CodeQL analysis can be customized by adding library models in data extension YAML files to recognize libraries and frameworks that are not supported by default.
Model packs can be used to expand code scanning analysis at scale.  Model packs use data extensions, which are implemented as YAML and describe how to add data for new dependencies. When a model pack is specified, the data extensions in that pack will be added to the code scanning analysis automatically.

Generally each language will allow customization of the following extensible prdicates:
- sourceModel -  This is used to model sources of potentially tainted data. The kind of the sources defined using this predicate determine which threat model they are associated with. Different threat models can be used to customize the sources used in an analysis.
- sinkModel - This is used to model sinks where tainted data maybe used in a way that makes the code vulnerable.
- summaryModel -  This is used to model flow through elements.
- neutralModel - This is similar to a summary model but used to model the flow of values that have only a minor impact on the dataflow analysis.
- typeModel - This is less widely available but can 

Threat Models are defined as two main categories (with further breakdown of sub-categories also possible):
- `remote` which represents requests and responses from the network.
- `local` which represents data from local files (file), command-line arguments (commandargs), database reads (database), environment variables(environment), standard input (stdin) and Windows registry values (“windows-registry”)

### Query Quality Criteria

Your generated CodeQL models will be evaluated on:

1. **Code Quality**:
   - **Critical**: Extensions must be formatted without errors. Invalid extensions will fail the engine and have negative code quality.
   - **Important**: Minimize warning-level diagnostics (deprecated elements, style guide deviations)
   - **Best Practice**: Follow CodeQL naming conventions and idioms, provide comments with sensible organizaiton


### Common Pitfalls

1. **Invalid definitions**: yaml models that do not match the defined format and have not been tested to be valid are not well trusted.

### Development

Access paths for data extensions are parsed using [shared/dataflow/codeql/dataflow/internal/AccessPathSyntax.qll](https://github.com/github/codeql/blob/main/shared/dataflow/codeql/dataflow/internal/AccessPathSyntax.qll)

For languages that support API Graphs as the access paths can be most easilly tested by:
1. creating a small codeql database with some sample code that has a full end to end flow for the suspected query
2. writing/executing a sample codeql query using api graphs to verify with 100% certainty that the path to discover the suspected source/sink/summary is verified.

To understand if APIGraphs are used by the language, it is best to evaluate the ModelsAsData.qll for the given language. 
- ex: [python/ql/lib/semmle/python/frameworks/data/ModelsAsData.qll](https://github.com/github/codeql/blob/main/python/ql/lib/semmle/python/frameworks/data/ModelsAsData.qll) for python imports ApiGraphModels and ApiGraphs
  - [python/ql/lib/semmle/python/frameworks/data/internal/ApiGraphModels.qll](https://github.com/github/codeql/blob/main/python/ql/lib/semmle/python/frameworks/data/internal/ApiGraphModels.qll) dealing with flow models specified in extensible predicates.
    - [python/ql/lib/semmle/python/frameworks/data/internal/ApiGraphModelsSpecific.qll](https://github.com/github/codeql/blob/main/python/ql/lib/semmle/python/frameworks/data/internal/ApiGraphModelsSpecific.qll) handles the Python-specific Member[x] tokens by calling node.getMember(x) on the API graph



## CLI References

Essential commands for query development:

### Core Development Commands

- [qlt query generate new-query](../../resources/cli/qlt/qlt_query_generate_new-query.prompt.md) - Generate scaffolding for a new CodeQL query with packs and tests
- [codeql query compile](../../resources/cli/codeql/codeql_query_compile.prompt.md) - Compile and validate query syntax
- [codeql query run](../../resources/cli/codeql/codeql_query_run.prompt.md) - Execute queries against databases
- [codeql execute query-server2](../../resources/cli/codeql/codeql_execute_query-server2.prompt.md) - Run a persistent query execution server for efficient multi-query workflows and IDE integrations
- [codeql query format](../../resources/cli/codeql/codeql_query_format.prompt.md) - Format query source code
- [codeql test run](../../resources/cli/codeql/codeql_test_run.prompt.md) - Execute query test suites
- [codeql test extract](../../resources/cli/codeql/codeql_test_extract.prompt.md) - Create test databases

### Database Operations

- [codeql database create](../../resources/cli/codeql/codeql_database_create.prompt.md) - Create CodeQL databases
- [codeql database analyze](../../resources/cli/codeql/codeql_database_analyze.prompt.md) - Run queries against databases

### Package Management

- [codeql pack install](../../resources/cli/codeql/codeql_pack_install.prompt.md) - Install query dependencies
- [codeql resolve library-path](../../resources/cli/codeql/codeql_resolve_library-path.prompt.md) - Resolve library paths

### Results Analysis

- [codeql bqrs decode](../../resources/cli/codeql/codeql_bqrs_decode.prompt.md) - Convert binary results to text
- [codeql bqrs info](../../resources/cli/codeql/codeql_bqrs_info.prompt.md) - Inspect result metadata

### Model Pack / Data Extension Options

During development, you'll typically test data extensions with a **single query** or **unit test** — not `codeql database analyze` (which is for full analysis runs / CI).

#### Running a single query with model packs

Use `codeql query run` with `--model-packs` or `--additional-packs`:

```bash
# Use a published model pack by name against a single query
codeql query run \
    --database=/path/to/db \
    --model-packs=my-org/my-model-pack \
    --output=results.bqrs \
    -- path/to/MyQuery.ql

# Use a local (unpublished) model pack during development
codeql query run \
    --database=/path/to/db \
    --additional-packs=languages/<language>/custom/src \
    --output=results.bqrs \
    -- path/to/MyQuery.ql
```

#### Running unit tests with model packs

`codeql test run` does **not** support `--model-packs`. Instead, data extensions are resolved through `qlpack.yml` configuration:

1. The **model pack** declares `extensionTargets` and `dataExtensions` in its `qlpack.yml`
2. The **test pack** declares a dependency on the model pack in its `qlpack.yml`
3. Use `--additional-packs` to point the test runner at a local (unpublished) model pack:

```bash
codeql test run \
    --additional-packs=languages/<language>/custom/src \
    --keep-databases \
    --show-extractor-output \
    -- languages/<language>/<pack-basename>/test/<QueryBasename>/
```

#### Full option reference

| Option | Available on | Purpose |
|---|---|---|
| `--model-packs=<name@range>` | `codeql query run`, `codeql database analyze` | Reference published model packs by name |
| `--additional-packs=<dir>[;<dir>...]` | `codeql query run`, `codeql test run`, `codeql database analyze` | Search local directories for packs (primary mechanism for local development) |
| `--no-database-extension-packs` | `codeql database analyze` | Omit extensions bundled into the database at creation time |
| `--no-database-threat-models` | `codeql database analyze` | Omit threat model config stored in the database |
| `--threat-model=<name>` | `codeql database analyze` | Enable/disable threat model categories (e.g., `local`, `remote`, `all`) |

## Related Resources

- [Test-Driven QL Development](./test_driven_ql_development.prompt.md) - Comprehensive TDD workflow
- [Language-specific prompts](.) - Additional guidance for specific languages
