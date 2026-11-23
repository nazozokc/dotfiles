---
name: rust
description: Guidelines when generating new Rust code, modules, crates, or tests
---

# Rust Code Generation Guidelines

## When to Use

- When creating a new Rust crate, module, or binary
- When writing new functions, types, or tests in Rust
- When extending or refactoring existing Rust code

## Basic Rules

- **Read before writing**: inspect 2–3 existing modules and `Cargo.toml` first — follow local naming, module layout, and error types
- **No placeholder logic**: never leave `todo!()`, `unimplemented!()`, or `// TODO: implement` — implement it or ask
- **See ../code-gen/SKILL.md** for language-agnostic rules (ask when the spec is ambiguous, do not duplicate existing utilities)

## Project Layout

- Prefer a workspace with `crates/<name>/` for multi-binary projects; keep logic in `lib.rs`, CLI/IO wiring in `main.rs`
- Keep core logic independent of config/CLI crates — pass plain values in, apply config at the boundary (never core → config)
- Re-export the public API from `lib.rs`; do not expose internal modules unnecessarily

## Ownership and Types

- Prefer `&[T]` / `&str` over `&Vec<T>` / `&String`; return owned values only at API boundaries
- Use enums for closed sets of states instead of string comparisons — parse once at the boundary (`Status::parse(...)`) and branch with `matches!`
- Keep a helper's string form consistent with any underlying identifier it doubles as (e.g. SQL column names)
- Never widen an accepted input set beyond the source of truth — unknown values fall back to the documented legacy default, not to a broken value
- Carry invariants in the type (`Option`, `Result`, newtypes) instead of booleans plus assumptions

## Error Handling

- `Result<T, E>` for fallible logic: `thiserror` for library/domain errors, `anyhow` for binary entry points only
- No `unwrap()` / `expect()` in library code or on user input — tests and documented impossible invariants only
- Handle every match arm explicitly; never silently swallow an unknown value with `Ok(())`
- Fail closed on unknown config or marker values — return an error instead of guessing
- Validate at the boundary (CLI args, config files, env vars); internal functions may assume validated inputs

## Idiomatic Rust

- Prefer iterators (`iter().filter(...)`, `.map()`, `.fold()`) over loops with `continue` guards when it reads clearly
- Use `HashSet` for membership checks instead of `Vec::contains`
- Pass owned `Vec<T>` by value to consuming functions instead of cloning each element
- Use `?` for propagation; avoid nested `match` when `map_err` / `ok_or` says it better
- Add `#[must_use]` to pure functions whose result is easy to ignore
- Doc comments (`///`) on public items; inline comments only for non-obvious logic

## Testing

- Unit tests in `#[cfg(test)] mod tests` beside the code; integration and CLI tests in `tests/`
- Every bug fix gets a named regression test describing the behavior
- For CLI output parity, use golden fixtures and compare bytes
- Keep test-only helpers out of the `pub` API — `clippy --all-targets` flags `dead_code` on `#[cfg(test)] pub fn`
- Env-var-driven probes must no-op when unset so plain `cargo test` stays safe

## Verification

All must pass before declaring the work done:

```bash
cargo fmt --all --check
cargo test --workspace
cargo clippy --workspace --all-targets -- -D warnings
```

- Fix every warning — no blanket `#[allow(...)]` unless the reason is documented in a comment
- Read `clippy.toml` / `rustfmt.toml` before writing if the project has them

## Dependencies and Release

- Keep the dependency tree small — prefer `regex-lite` over `regex` when advanced features are unused
- For distributed CLI binaries, consider `profile.release`: `lto = "fat"`, `codegen-units = 1`, `strip = "symbols"`; `panic = "abort"` only when there is no `catch_unwind` or panic hook
- Avoid dependencies that force dynamic linking (e.g. `flate2` with `zlib`) when shipping static Linux binaries

## Related Skills

- Language-agnostic generation rules: ../code-gen/SKILL.md
- CLI tool conventions: ../cli/SKILL.md
