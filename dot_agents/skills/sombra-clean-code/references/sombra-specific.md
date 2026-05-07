# Sombra-Specific Rules

These rules are NON-NEGOTIABLE for all new code in Sombra. They are specific to this project's architecture, security model, and technology choices.

---

## 1. Tenant Isolation

**CRITICAL SECURITY REQUIREMENT:** The database contains data from ALL tenants. Every query MUST check `ctx.tenantId` against `companyId`.

### Pattern for ALL Queries

```typescript
import { and, eq } from "drizzle-orm";

// In domain operations:
const result = await db.query.someTable.findFirst({
  where: (table, { and, eq }) =>
    and(
      eq(table.id, params.id),
      eq(table.companyId, ctx.tenantId),
    ),
});

// With update/delete:
await db
  .update(someTable)
  .set({ /* ... */ })
  .where(
    and(
      eq(someTable.id, params.id),
      eq(someTable.companyId, ctx.tenantId),
    ),
  );
```

### Tenant Check Checklist

- [ ] Every findFirst/findMany includes eq(table.companyId, ctx.tenantId)
- [ ] Every update includes tenant check in where()
- [ ] Every delete includes tenant check in where()
- [ ] Subqueries include tenant check

---

## 2. Resolver Thinness

Resolvers must be THIN. Maximum 15 lines. Extract business logic to domain/.

### Good Pattern

```typescript
export const workOrderCreate = async (_: unknown, { input }, ctx: Context) => {
  const result = await createWorkOrderOperation({
    db: ctx.db, ctx, params: input,
  });
  return { workOrder: result };
};
```

### Bad Pattern

Putting validation, number generation, database inserts, and related item creation all in the resolver.

---

## 3. GraphQL Type Definition Rules

### NEVER Export Type Definitions from index.ts

```typescript
// CORRECT: index.ts only exports resolvers
export const featureWorkOrdersMutationResolvers = {
  workOrderCreate, workOrderUpdate,
};
```

### ALWAYS Import Type Definitions Directly from resolvers/

In schemaTypeDefs.ts:

```typescript
/* eslint-disable custom/restrict-feature-imports */
import {
  featureWorkOrdersMutationTypeDefs,
} from '../feature-work-orders/resolvers/workOrders.typeDefs';
```

This is intentional and required to prevent cyclic dependencies during codegen.

---

## 4. Feature Import Restrictions

Features must be self-contained. No cross-feature imports from index.ts files.

```typescript
// WRONG: Cross-feature import
import { formResponseOps } from '../feature-forms';

// CORRECT: Shared code in packages/
import { dateUtils } from '@company/shared-utils';
```

---

## 5. Date and Time Handling

### ALWAYS Use Luxon

- Use Luxon for all date/time operations
- Do not use Date, dayjs, or moment in new code

### Parse Database Strings Correctly

```typescript
// BAD: fromISO produces wrong results with SQL timestamps
const createdAt = DateTime.fromISO(workOrder.createdAt);

// GOOD:
const createdAt = DateTime.fromSQL(workOrder.createdAt);
```

### Test Dates with Explicit UTC

```typescript
// GOOD: Explicit UTC in tests
const dueDate = DateTime.fromSQL('2024-01-15 10:00:00', { zone: 'utc' });
```

---

## 6. Phone Numbers

Store and transmit in E.164 format: +15141234567

---

## 7. GraphQL Code Generation

After creating new resolvers or type definitions, run:

```bash
pnpm --filter sombra run generate:gql
```

Resolvers will not compile until types are generated.

---

## 8. Database Query Style

Use db.query instead of db._query. The underscore syntax is deprecated.

```typescript
// GOOD:
const result = await db.query.workOrders.findFirst({...});

// BAD (deprecated):
const result = await db._query.workOrders.findFirst({...});
```
