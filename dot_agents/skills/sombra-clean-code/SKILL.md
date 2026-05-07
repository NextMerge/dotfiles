---
name: sombra-clean-code
description: Use this skill when writing, reviewing, or refactoring code in the Sombra backend. Enforces senior-engineer quality through SOLID principles, mandatory TDD for domain operations, strict clean code practices, and Sombra-specific architectural rules. Applies to all new code; existing code is grandfathered but must be improved when touched.
---

# Sombra Clean Code Skill

You are operating as a senior software engineer for the Sombra backend. Every line of code you write, every design decision you make, and every refactoring you perform must embody professional craftsmanship and adhere to the standards documented in this skill.

## When This Skill Applies

**ALWAYS use this skill when:**
- Writing ANY code in `services/sombra/`
- Creating new features, resolvers, domain operations, or utilities
- Refactoring existing code
- Reviewing code quality
- Debugging issues
- Creating or modifying tests
- Making design decisions about feature structure

## Core Philosophy

> "Code is to create products for users & customers. Testable, flexible, and maintainable code that serves the needs of the users is GOOD because it can be cost-effectively maintained by developers."

The goal of software: Enable developers to **discover, understand, add, change, remove, test, debug, deploy**, and **monitor** features efficiently.

## The Non-Negotiable Process

### 1. ALWAYS Start with Tests for Domain Operations (TDD)

**Red-Green-Refactor is mandatory for all new domain operations:**

```
1. RED    - Write a failing test that describes the behavior
2. GREEN  - Write the SIMPLEST code to make it pass
3. REFACTOR - Clean up, remove duplication (Rule of Three)
```

**The Three Laws of TDD:**
1. You cannot write production code in `domain/` unless it makes a failing test pass
2. You cannot write more test code than is sufficient to fail
3. You cannot write more production code than is sufficient to pass

**Design happens during REFACTORING, not during coding.**

Thin resolvers (GraphQL layer) are exempt from strict TDD but MUST have integration tests if they contain conditional logic.

See: [references/tdd.md](references/tdd.md)

### 2. Apply SOLID Principles Rigorously

Every class, every module, every function:

| Principle | Question to Ask |
|-----------|-----------------|
| **S**RP - Single Responsibility | "Does this have ONE reason to change?" |
| **O**CP - Open/Closed | "Can I extend without modifying?" |
| **L**SP - Liskov Substitution | "Can subtypes replace base types safely?" |
| **I**SP - Interface Segregation | "Are clients forced to depend on unused methods?" |
| **D**IP - Dependency Inversion | "Do high-level modules depend on abstractions?" |

See: [references/solid-principles.md](references/solid-principles.md)

### 3. Write Clean, Human-Readable Code

**Naming (in order of priority):**
1. **Consistency** - Same concept = same name everywhere
2. **Understandability** - Domain language, not technical jargon
3. **Specificity** - Precise, not vague (banned: `data`, `info`, `manager`, `handler`, `processor`, `utils`)
4. **Brevity** - Short but not cryptic
5. **Searchability** - Unique, greppable names

**Functions:**
- **Resolvers:** Maximum 15 lines. All business logic delegated to `domain/`.
- **Domain operations:** Maximum 30 lines. Extract helper functions when exceeded.
- Minimize parameters (0 best, 1 good, 2 okay, 3+ use parameter objects)
- Keep functions small and focused on one thing
- All operations at the same level of abstraction, one level below the function name
- Don't mix abstraction levels in a single function
- Split reasonably - avoid redundant extractions
- Avoid unexpected side effects (function name must imply all effects)

**Control Structures:**
- Prefer positive checks (`isEmpty(x)` over `!hasContent(x)`)
- Avoid deep nesting - use guards and fail fast
- Extract nested control structures into separate functions
- Use polymorphism and factory functions to eliminate repeated conditionals
- Embrace real errors (throw/catch) instead of synthetic error codes
- **NO `else` keyword when early return works**

**Structure:**
- One level of indentation per method
- When validating untrusted strings against an object/map, use `Object.hasOwn(...)` — do not use the `in` operator
- First-class collections (wrap arrays in classes where appropriate)
- One dot per line (Law of Demeter)
- Distinguish between **objects** (hide data, expose behavior) and **data containers** (expose data) - don't mix types

See: [references/clean-code.md](references/clean-code.md)

### 4. Follow Sombra Architecture Rules

**Vertical slicing by feature:**
```
src/feature-{name}/
├── index.ts                    # Exports resolvers ONLY
├── resolvers/                  # GraphQL resolvers + type definitions
│   ├── {operation}.ts
│   ├── {operation}.typeDefs.ts
│   └── ...
├── domain/                     # Business logic ONLY
│   ├── {entity}Ops.ts
│   └── ...
└── utils/                      # Feature-specific utilities
```

**Critical rules:**
- Resolvers are THIN. They validate input, call domain ops, and return results.
- Domain operations contain ALL business logic.
- NEVER export type definitions from `index.ts`.
- ALWAYS import type definitions directly from `resolvers/` files in `schemaTypeDefs.ts`.
- Use `eslint-disable custom/restrict-feature-imports` only for typedef imports in `schemaTypeDefs.ts`.
- NEVER import from another feature's `index.ts`.

See: [references/architecture.md](references/architecture.md)
See: [references/sombra-specific.md](references/sombra-specific.md)

### 5. Enforce Security and Domain Rules

**Tenant isolation is NON-NEGOTIABLE:**
- EVERY database query MUST check `ctx.tenantId` against `companyId`.
- NO exceptions. NO shortcuts. This is a security requirement.

**Date/Time handling:**
- ALWAYS use **Luxon** (`luxon`) for all date/time operations.
- Parse database strings with `DateTime.fromSQL()`, NEVER `DateTime.fromISO()`.
- Use explicit UTC offsets in tests.

**Phone numbers:**
- Store and transmit in **E.164 format** (e.g., `+15141234567`).

See: [references/sombra-specific.md](references/sombra-specific.md)

### 6. Design with Responsibility in Mind

**Ask these questions for every class:**
1. "What pattern is this?" (Entity, Service, Repository, Factory, etc.)
2. "Is it doing too much?" (Check object calisthenics)

**Object Stereotypes:**
- **Information Holder** - Holds data, minimal behavior
- **Structurer** - Manages relationships between objects
- **Service Provider** - Performs work, stateless operations
- **Coordinator** - Orchestrates multiple services
- **Controller** - Makes decisions, delegates work
- **Interfacer** - Transforms data between systems (resolvers are Interfacers)

### 7. Manage Complexity Ruthlessly

**Essential complexity** = inherent to the problem domain
**Accidental complexity** = introduced by our solutions

**Fight complexity with:**
- YAGNI - Don't build what you don't need NOW
- KISS - Simplest solution that works
- DRY - But only after Rule of Three (wait for 3 duplications)

## The Four Elements of Simple Design (XP)

In priority order:
1. **Runs all the tests** - Must work correctly
2. **Expresses intent** - Readable, reveals purpose
3. **No duplication** - DRY (but Rule of Three)
4. **Minimal** - Fewest classes, methods possible

## Code Smell Detection

**Stop and refactor when you see:**

| Smell | Solution |
|-------|----------|
| Long Method | Extract methods, compose method pattern |
| Large Class | Extract class, single responsibility |
| Long Parameter List | Introduce parameter object |
| Divergent Change | Split into focused classes |
| Shotgun Surgery | Move related code together |
| Feature Envy | Move method to the envied class |
| Data Clumps | Extract class for grouped data |
| Primitive Obsession | Wrap in value objects |
| Switch Statements | Replace with polymorphism |
| Parallel Inheritance | Merge hierarchies |
| Speculative Generality | YAGNI - remove unused abstractions |

## Existing Code Policy

**New code MUST follow this standard.**

**Existing code is grandfathered** but MUST be improved when touched:
- If you modify an existing file, improve the parts you touch.
- Do NOT refactor the entire file just to fix one bug.
- Follow the Boy Scout Rule: leave the code better than you found it.

## Pre-Code Checklist

Before writing ANY code, answer:

1. [ ] Do I understand the requirement? (Write acceptance criteria first)
2. [ ] What test will I write first?
3. [ ] What is the simplest solution?
4. [ ] What patterns might apply? (Don't force them)
5. [ ] Am I solving a real problem or a hypothetical one?
6. [ ] Does this feature need a new domain operation? (If yes, start with the test.)

## During-Code Checklist

While coding, continuously ask:

1. [ ] Is this the simplest thing that could work?
2. [ ] Does this class/file have a single responsibility?
3. [ ] Am I depending on abstractions or concretions?
4. [ ] Can I name this more clearly?
5. [ ] Is there duplication I should extract? (Rule of Three)
6. [ ] Did I include the tenant check in every query?
7. [ ] Are my resolvers under 15 lines?
8. [ ] Are my domain ops under 30 lines?

## Post-Code Checklist

After the code works:

1. [ ] Do all tests pass?
2. [ ] Is there any dead code to remove?
3. [ ] Can I simplify any complex conditions?
4. [ ] Are names still accurate after changes?
5. [ ] Would a junior understand this in 6 months?
6. [ ] Did I run `pnpm --filter sombra run generate:gql` if I changed type definitions?

## Red Flags - Stop and Rethink

- Writing domain code without a test
- Class with more than 5 instance variables
- Domain operation longer than 30 lines
- Resolver longer than 15 lines
- More than one level of indentation in a function
- Using `else` when early return works
- Hardcoding values that should be configurable
- Creating abstractions before the third duplication
- Adding features "just in case"
- Depending on concrete implementations
- God classes that know everything
- Missing `companyId` / `tenantId` check in a database query
- Exporting type definitions from a feature's `index.ts`
- Using `Date`, `dayjs`, or `moment` instead of Luxon

## Remember

> "A little bit of duplication is 10x better than the wrong abstraction."

> "Focus on WHAT needs to happen, not HOW it needs to happen."

> "Design principles become second nature through practice. Eventually, you won't think about SOLID - you'll just write SOLID code."

The journey: Code-first → Best-practice-first → Pattern-first → Responsibility-first → **Systems Thinking**

Your goal is to reach systems thinking - where principles are internalized and you focus on optimizing the entire development process.
