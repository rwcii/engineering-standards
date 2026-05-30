# Architecture Decision Records (ADRs)

ADRs document **how a system is built** — structure, patterns, boundaries,
infrastructure. For process rules, the template, naming, and lifecycle, see
[ADR_PROCESS.md](ADR_PROCESS.md).

This is the **universal baseline** intended to be vendored into a project. Universal
records (001.x) are written at principle level; templates (002.x, 004) and stubs
(005, 006) are filled in per project. Project-specific ADRs begin at **007**.

## Baseline ADRs

| Number | Title                                                              | Kind     | Status   |
| ------ | ------------------------------------------------------------------ | -------- | -------- |
| 001    | [Code Architecture Standards](001-code-architecture-standards.md)  | Universal | Accepted |
| 001.1  | [DRY — Don't Repeat Yourself](001.1-dry.md)                        | Universal | Accepted |
| 001.2  | [Modular Architecture](001.2-modular.md)                           | Universal | Accepted |
| 001.3  | [Extensible by Construction](001.3-extensible-by-construction.md)  | Universal | Accepted |
| 001.4  | [Interface Boundaries](001.4-interface-boundaries.md)             | Universal | Accepted |
| 001.5  | [Centralized Configuration](001.5-centralized-configuration.md)    | Universal | Accepted |
| 002    | [Tech Stack](002-tech-stack.md)                                    | Template | Draft    |
| 002.1  | [Frontend](002.1-frontend.md)                                      | Template | Draft    |
| 002.2  | [API](002.2-api.md)                                                | Template | Draft    |
| 002.3  | [Backend & Persistence](002.3-backend-persistence.md)             | Template | Draft    |
| 003    | *reserved — Configuration & Deployment*                            | —        | —        |
| 004    | [Database & Data Handling](004-database-and-data-handling.md)      | Template | Draft    |
| 005    | [Security](005-security.md)                                        | Stub     | Draft    |
| 006    | [Authentication](006-authentication.md)                            | Stub     | Draft    |

## Numbering map

- **001.x** — universal code-architecture standards. Keep as-is when adopting.
- **002.x** — your stack, by layer (frontend / api / backend-persistence). Fill in.
- **003** — reserved for a future universal Configuration & Deployment record.
- **004.x** — database & data-handling specifics. Fill in.
- **005 / 006** — security and authentication. Stubs to flesh out when decided.
- **007+** — your project's own architecture decisions.
