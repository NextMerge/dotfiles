# Test-Driven Development in Sombra

## The Core Loop

```
RED → GREEN → REFACTOR → RED → ...
```

### RED Phase
Write a failing test that describes the behavior you want. The test should:
- Use domain language, not technical jargon
- Describe WHAT, not HOW
- Be a concrete example, not an abstract statement

```typescript
// BAD: Abstract
it('can create work orders', () => { ... });

// GOOD: Concrete example
it('when creating a work order with valid data, returns a work order with a generated number', () => { ... });
```

### GREEN Phase
Write the **simplest possible code** to make the test pass. Two strategies:

1. **Fake It** - Return a hardcoded value
   ```typescript
   export const createWorkOrderOperation = async () => {
     return { id: 'wo-1', workOrderNumber: 1 }; // Simplest thing!
   };
   ```

2. **Obvious Implementation** - If you know the solution
   ```typescript
   export const createWorkOrderOperation = async ({ db, ctx, params }) => {
     return await db.insert(workOrders).values(params.workOrderData).returning();
   };
   ```

**Prefer Fake It** when learning or unsure. Let more tests drive the real implementation.

### REFACTOR Phase
This is where **design happens**. Look for:
- Duplication (but wait for Rule of Three)
- Long methods to extract
- Poor names to improve
- Complex conditions to simplify

## The Three Laws of TDD

1. **No production code in `domain/`** without a failing test
2. **No more test code** than sufficient to fail (compilation failures count)
3. **No more production code** than sufficient to pass the one failing test

## TDD Rules by Layer

### Domain Operations (MANDATORY TDD)
All new files in `src/feature-*/domain/` MUST be developed with TDD.

```typescript
// test: domain/workOrderOps.test.ts
import { createWorkOrderOperation } from './workOrderOps';
import { db } from '../../../test-utils/database';
import { Context } from '../../../graphql/context';

describe('createWorkOrderOperation', () => {
  it('when given valid work order data, creates a work order with an auto-incremented number', async () => {
    // ARRANGE
    const mockCtx = { tenantId: 'company-1', user: { employeeId: 'emp-1' } } as Context;
    const params = {
      workOrderData: { title: 'Fix HVAC', description: 'Unit not cooling' },
      items: [],
    };

    // ACT
    const result = await createWorkOrderOperation({ db, ctx: mockCtx, params });

    // ASSERT
    expect(result.workOrderNumber).toBe(1);
    expect(result.companyId).toBe('company-1');
    expect(result.createdBy).toBe('emp-1');
  });
});
```

### Resolvers (TDD Optional, Tests Required)
Thin resolvers don't need TDD, but MUST be covered by integration tests if they contain logic.

```typescript
// Resolver with no logic -> integration test is sufficient
export const workOrderCreate = async (_: unknown, { input }, ctx: Context) => {
  const result = await createWorkOrderOperation({ db: ctx.db, ctx, params: input });
  return { workOrder: result };
};

// Resolver with conditional logic -> write test
export const workOrderCreate = async (_: unknown, { input }, ctx: Context) => {
  if (!input.title) {
    throw new Error('Title is required');
  }
  const result = await createWorkOrderOperation({ db: ctx.db, ctx, params: input });
  return { workOrder: result };
};
```

### Type Definitions (No Tests)
GraphQL type definitions are declarative. They don't need unit tests, but they MUST compile via `generate:gql`.

## The Rule of Three

**Only extract duplication when you see it THREE times.**

Why? Wrong abstractions are worse than duplication. Wait for the pattern to emerge.

```typescript
// Duplication #1 in test setup - Leave it
// Duplication #2 in test setup - Note it, leave it
// Duplication #3 in test setup - NOW extract a test helper
```

## Triangulation

Each new test "sculpts" the solution toward a general, robust implementation.

Think of **degrees of freedom** - like a work order that needs number generation, tenant assignment, and item creation. Each test carves out one degree of freedom until the implementation handles all cases.

## Transformation Priority Premise

When going from RED to GREEN, prefer simpler transformations:

| Priority | Transformation |
|----------|----------------|
| 1 | {} → nil |
| 2 | nil → constant |
| 3 | constant → variable |
| 4 | unconditional → conditional |
| 5 | scalar → collection |
| 6 | statement → recursion |
| 7 | value → mutated value |

Higher priority = simpler. Avoid jumping to complex transformations too early.

## Arrange-Act-Assert in Sombra

Structure every test:

```typescript
it('calculates total with tax for Canadian companies', () => {
  // ARRANGE - Set up the test world
  const mockCtx = { tenantId: 'canada-co', user: { employeeId: 'emp-1' } } as Context;
  const items = [{ price: 100, quantity: 2 }];

  // ACT - Execute the behavior under test
  const result = calculateWorkOrderTotal({ db, ctx: mockCtx, params: { items } });

  // ASSERT - Verify the outcome
  expect(result.subtotal).toBe(200);
  expect(result.tax).toBe(26); // 13% HST
  expect(result.total).toBe(226);
});
```

## Writing Tests Backwards

Sometimes it helps to write AAA in reverse:
1. Write the ASSERT first - what do you want to verify?
2. Write the ACT - what action produces that result?
3. Write the ARRANGE - what setup is needed?

## Test Naming Principles

- Use **behavior-driven names** with domain language
- Provide **concrete examples**, not abstract statements
- **One example per test** for easy debugging
- Avoid leaking implementation details

```typescript
// BAD: Technical, implementation-focused
it('should call db.insert with correct values', () => { ... });

// GOOD: Behavior-focused, domain language
it('when creating a work order, assigns the next sequential number for the tenant', () => { ... });
```

## Classic vs Mockist TDD in Sombra

**Classic (Detroit/Chicago) TDD:**
- Test domain operations with real or in-memory database
- Higher confidence, slightly slower tests
- Best for: Domain operations, pure functions

**Mockist (London) TDD:**
- Mock external dependencies (email services, third-party APIs)
- Faster tests, more isolated
- Best for: Code with infrastructure dependencies

**Recommendation for Sombra:**
- Domain ops: Classic TDD with test database transactions
- Services with external calls: Mockist TDD

## Common TDD Mistakes in Sombra

| Mistake | Problem | Solution |
|---------|---------|----------|
| Writing domain code before tests | Violates the fundamental principle | Delete the code, write the test first |
| Writing too much test | Over-specification | Just enough to fail |
| Writing too much code | Over-engineering | Just enough to pass |
| Skipping refactor | Technical debt accumulates | Always refactor after green |
| Testing implementation | Brittle tests | Test behavior, not Drizzle queries |
| Abstract test names | Hard to understand failures | Use concrete examples |
| Extracting too early | Wrong abstractions | Wait for Rule of Three |
| Not testing tenant isolation | Security risk | Every test verifies `companyId` is set correctly |
