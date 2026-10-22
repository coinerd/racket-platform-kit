# ADR 0004 — Explicit extension composition before a plugin framework
**Status:** Accepted (planning)

## Alternatives
A. Dynamic hot-loaded extension registry with macro/DSL manifests, capability discovery and dependency injection.
B. Hard-code Football into Core.
C. **Explicit composition of trusted module functions with a small documented Core contract.**

## Decision
Choose C. The starter demonstrates a single Core route-registration operation and a separate Football installer. As real extensions and operations emerge, promote proven common registration functions to a versioned manifest. Avoid creating an abstraction stack before its consumers exist.

## Tradeoffs
Early extension activation may require a startup code change. This is preferable to speculative framework code. Installed extensions run as trusted server modules and cannot be safely sandboxed through a manifest alone.

## Validation
Core-only smoke test, composition test, path-collision rejection, Core import boundary scan, public API compatibility tests. Add manifest version checks before real third-party extension distribution.
