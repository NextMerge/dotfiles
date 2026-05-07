# Software Architecture for Sombra

## The Goal of Architecture

Enable the development team to:
1. **Add** features with minimal friction
2. **Change** existing features safely
3. **Remove** features cleanly
4. **Test** features in isolation
5. **Deploy** independently when possible

---

## Architectural Principles

### 1. Vertical Boundaries (Features/Slices)

Organize by **feature**, not by technical layer.

```
BAD: Layer-first
src/
  controllers/
    WorkOrderController.ts
    FormResponseController.ts
  services/
    WorkOrderService.ts
    FormResponseService.ts
  repositories/
    WorkOrderRepository.ts
    FormResponseRepository.ts

GOOD: Feature-first (Sombra standard)
src/
  feature-work-orders/
    resolvers/
      workOrderCreate.ts
      workOrderCreate.typeDefs.ts
      workOrderGet.ts
      workOrderGet.typeDefs.ts
    domain/
      workOrderOps.ts
    utils/
  feature-forms/
    resolvers/
      formResponseCreate.ts
      formResponseCreate.typeDefs.ts
    domain/
      formResponseOps.ts
    utils/
```

**Why:** Changes to "work orders" feature stay in `feature-work-orders/`. High cohesion within features.

### 2. Horizontal Boundaries (Layers)

Separate concerns into layers with clear dependencies.

```
GraphQL Resolvers (Presentation)
         |
         v
    Domain Operations (Application/Business)
         |
         v
   Database / External Services (Infrastructure)
```

**In Sombra:**
- **Resolvers** handle GraphQL concerns (input parsing, auth, output formatting)
- **Domain Operations** handle business logic (validation, calculations, orchestration)
- **Database** handles persistence (Drizzle ORM)

### 3. The Dependency Rule

**Dependencies point INWARD.**

```
Resolvers -> Domain Operations -> Database/External
    (outer)      (middle)          (inner)
```

- Inner layers know NOTHING about outer layers
- Domain operations have zero dependencies on GraphQL types or HTTP concerns
- Use interfaces to invert dependencies where beneficial

```typescript
// Domain defines the interface (inner)
interface WorkOrderRepository {
  create(data: WorkOrderInsert): Promise<WorkOrder[]>;
  findById(id: string): Promise<WorkOrder | null>;
}

// Infrastructure implements it (outer)
class DrizzleWorkOrderRepository implements WorkOrderRepository {
  constructor(private db: Database) {}

  async create(data: WorkOrderInsert): Promise<WorkOrder[]> {
    return this.db.insert(workOrders).values(data).returning();
  }

  async findById(id: string): Promise<WorkOrder | null> {
    // ... with tenant check
  }
}
```

### 4. Contracts

Interfaces define boundaries between components.

```typescript
// The contract
interface PDFGenerator {
  generate(template: string, data: Record<string, unknown>): Promise<Buffer>;
}

// Multiple implementations possible
class PuppeteerPDFGenerator implements PDFGenerator { }
class MockPDFGenerator implements PDFGenerator { }  // For tests
```

### 5. Cross-Cutting Concerns

Concerns that span multiple features: logging, auth, validation, error handling, tenant isolation.

**In Sombra:**
- `@isAuthenticated` directive on GraphQL fields
- `ctx.tenantId` injected into every resolver context
- `OperationArguments` pattern for passing db + ctx + params to domain ops

---

## Feature-Driven Structure in Sombra

```
src/feature-{name}/
├── index.ts                    # Exports resolvers ONLY
├── resolvers/                  # GraphQL resolvers + type definitions
│   ├── {operation}.ts          # Individual resolver
│   ├── {operation}.typeDefs.ts # Type definitions for operation
│   ├── {entity}.resolvers.ts # Grouped resolvers (alternative)
│   ├── {entity}.typeDefs.ts  # Grouped type definitions (alternative)
│   └── ...
├── domain/                     # Business logic ONLY
│   ├── {entity}Ops.ts         # Domain operations
│   ├── {entity}{Purpose}.ejs  # Templates for PDF generation
│   └── ...
└── utils/                      # Feature-specific utilities
    └── ...
```

**Key files and their responsibilities:**

| File | Responsibility | Layer |
|------|---------------|-------|
| `index.ts` | Export resolvers for schema registration | Interfacer |
| `resolvers/*.ts` | Parse GraphQL input, call domain, format output | Interfacer |
| `resolvers/*.typeDefs.ts` | Define GraphQL schema fragments | Contract |
| `domain/*Ops.ts` | Business logic, database operations, validation | Service Provider |

---

## The Walking Skeleton

When starting a new feature, build the thinnest possible end-to-end slice:

1. **One mutation or query** that touches all layers
2. **Compiles** from day one
3. **Proves the architecture** works

Example walking skeleton for a new `feature-inventory`:
- User can create ONE inventory item (hardcoded defaults)
- GraphQL type definitions compile
- Resolver calls domain operation
- Domain operation inserts into database
- Response returns the created item

From there, flesh out each operation fully.

---

## Testing Architecture

```
E2E / Acceptance Tests (Few)
  - Full GraphQL API calls
  - Test critical paths only

Integration Tests (Some)
  - Resolvers + Domain + Database
  - Test layer boundaries

Unit Tests (Many)
  - Domain operations in isolation
  - Fast, comprehensive
```

**Test by layer:**
- **Domain:** Unit tests (most tests here)
- **Resolvers:** Integration tests with real database
- **Infrastructure:** Integration tests with real dependencies
- **E2E:** Critical paths only

---

## Architecture Decision Records (ADRs)

Document significant decisions in the `services/sombra/` README or a dedicated `docs/` folder:

```markdown
# ADR 001: Use Drizzle ORM for database access

## Status
Accepted

## Context
We need type-safe database queries. Options: Drizzle, Prisma, raw SQL

## Decision
Drizzle for:
- Type safety
- SQL-like syntax
- Performance
- Team familiarity

## Consequences
- Schema defined in TypeScript
- Migrations managed via Drizzle Kit
```

---

## Red Flags in Sombra Architecture

- **Circular dependencies** between features
- **Domain depending on GraphQL types** (domain should not import from `graphql/__generated`)
- **Resolver containing business logic** (should be in domain/)
- **No clear boundaries** between features
- **Shared mutable state** across features
- **Util or Common packages** that grow forever
- **Database schema driving domain model** without abstraction
- **Missing tenant checks** in database queries
- **Exporting type definitions from feature index.ts**
