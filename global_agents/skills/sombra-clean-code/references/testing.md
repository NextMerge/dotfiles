# Testing Strategy for Sombra

## The Testing Pyramid

```
       /\
      /  \        E2E Tests (Few)
     /----\       - Full system
    /      \      - Slow, brittle
   /--------\
  /          \    Integration Tests (Some)
 /------------\   - Multiple components
/              \  - Medium speed
----------------
      Unit Tests (Many)
      - Single unit
      - Fast, isolated
```

## Test Types in Sombra

### Unit Tests

Test ONE domain operation or utility function in isolation.

**Characteristics:**
- Fast (milliseconds)
- No external dependencies (mocked or in-memory)
- Most of your tests should be unit tests

```typescript
import { calculateWorkOrderTotal } from './workOrderOps';

describe('calculateWorkOrderTotal', () => {
  it('sums line item prices correctly', () => {
    const items = [
      { price: 100, quantity: 2 },
      { price: 50, quantity: 1 },
    ];

    const result = calculateWorkOrderTotal(items);

    expect(result).toBe(250);
  });
});
```

### Integration Tests

Test multiple components together, especially resolvers with domain operations.

**Characteristics:**
- Slower (uses real database)
- Test boundaries between layers
- Fewer than unit tests

```typescript
import { workOrderCreate } from '../resolvers/workOrderCreate';
import { db } from '../../../test-utils/database';

describe('workOrderCreate resolver', () => {
  it('creates a work order through the full resolver + domain stack', async () => {
    const mockCtx = {
      db,
      tenantId: 'company-1',
      user: { employeeId: 'emp-1' },
    };

    const result = await workOrderCreate(
      null,
      { input: { title: 'Fix Roof', items: [] } },
      mockCtx
    );

    expect(result.workOrder.title).toBe('Fix Roof');
    expect(result.workOrder.companyId).toBe('company-1');
  });
});
```

### E2E / Acceptance Tests

Test the entire system from the GraphQL API perspective.

**Characteristics:**
- Slowest
- Most brittle
- Test critical paths only

```typescript
describe('Work Order Creation Flow', () => {
  it('authenticated user can create a work order', async () => {
    const response = await request(app)
      .post('/graphql')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        query: `
          mutation {
            workOrderCreate(input: { title: "Test", items: [] }) {
              workOrder { id title }
            }
          }
        `,
      });

    expect(response.body.data.workOrderCreate.workOrder.title).toBe('Test');
  });
});
```

---

## Arrange-Act-Assert (AAA)

Structure EVERY test this way:

```typescript
it('applies tenant-specific tax rate to work order total', () => {
  // ARRANGE - Set up the test world
  const mockCtx = { tenantId: 'us-company', user: { employeeId: 'emp-1' } };
  const items = [{ price: 100, quantity: 1 }];

  // ACT - Execute the behavior under test
  const total = calculateWorkOrderTotal({ db, ctx: mockCtx, params: { items } });

  // ASSERT - Verify the expected outcome
  expect(total).toBe(107); // 7% sales tax
});
```

### Writing AAA Backwards

Sometimes easier to write in reverse:
1. **Assert first** - What do you want to verify?
2. **Act** - What action produces that result?
3. **Arrange** - What setup is needed?

---

## Test Naming

### Bad: Abstract, Technical

```typescript
it('should work correctly')
it('handles the edge case')
it('sets the data property')
```

### Good: Concrete Examples, Domain Language

```typescript
it('calculates 13% tax for Canadian tenants')
it('returns error when work order title is empty')
it('assigns sequential work order numbers per tenant')
```

### Format Options

```typescript
// Option 1: should + behavior
it('should apply tax based on tenant location')

// Option 2: when + then
it('when adding 2 items, then returns correct total')

// Option 3: Given-When-Then (for complex scenarios)
describe('given a tenant with premium features', () => {
  describe('when they create a work order', () => {
    it('then it includes advanced status tracking', () => { ... });
  });
});
```

---

## Test Doubles in Sombra

### Dummy

Object passed but never used.

```typescript
const dummyLogger = {} as Logger;
new WorkOrderService(realRepo, dummyLogger);
```

### Stub

Returns predefined values.

```typescript
const stubRepo = {
  findById: () => Promise.resolve({ id: 'wo-1', title: 'Stub Work Order' }),
};
```

### Spy

Records how it was called.

```typescript
const emailSpy = {
  sentEmails: [] as string[],
  send(to: string, message: string) {
    this.sentEmails.push(to);
  },
};

// Later
expect(emailSpy.sentEmails).toContain('manager@example.com');
```

### Mock

Verifies expected interactions.

```typescript
const mockRepo = {
  create: jest.fn().mockResolvedValue([{ id: 'wo-1' }]),
};

// After test
expect(mockRepo.create).toHaveBeenCalledWith(
  expect.objectContaining({ companyId: 'company-1' })
);
```

### Fake

Working implementation (simplified).

```typescript
class InMemoryWorkOrderRepo implements WorkOrderRepository {
  private workOrders: Map<string, WorkOrder> = new Map();
  private counters: Map<string, number> = new Map();

  async create(data: WorkOrderInsert): Promise<WorkOrder[]> {
    const tenantCount = this.counters.get(data.companyId) || 0;
    this.counters.set(data.companyId, tenantCount + 1);
    const workOrder = {
      ...data,
      id: `wo-${tenantCount + 1}`,
      workOrderNumber: tenantCount + 1,
    } as WorkOrder;
    this.workOrders.set(workOrder.id, workOrder);
    return [workOrder];
  }

  async findById(id: string): Promise<WorkOrder | null> {
    return this.workOrders.get(id) || null;
  }
}
```

---

## Testing Strategies by Layer

### Domain Layer (Most Tests)

- Unit tests with no external mocks
- Test business rules, calculations, validations
- Fast, comprehensive

```typescript
describe('WorkOrder pricing', () => {
  it('calculates total with tax for US tenants', () => {
    const items = [{ price: 100, quantity: 2 }];
    const result = calculateTotal(items, 'US');
    expect(result).toBe(214); // 7% tax
  });

  it('calculates total with tax for Canadian tenants', () => {
    const items = [{ price: 100, quantity: 2 }];
    const result = calculateTotal(items, 'CA');
    expect(result).toBe(226); // 13% HST
  });
});
```

### Resolver Layer

- Integration tests with real database
- Test GraphQL-specific concerns (input validation, auth directives, error formatting)

```typescript
describe('workOrderCreate resolver', () => {
  it('returns error when user is not authenticated', async () => {
    const mockCtx = { user: null };
    await expect(
      workOrderCreate(null, { input: { title: 'Test' } }, mockCtx)
    ).rejects.toThrow('Unauthorized');
  });
});
```

### Infrastructure Layer

- Integration tests with real dependencies
- Test database queries, external API integrations

```typescript
describe('DrizzleWorkOrderRepository', () => {
  let repo: DrizzleWorkOrderRepository;

  beforeAll(async () => {
    repo = new DrizzleWorkOrderRepository(testDb);
  });

  it('persists and retrieves work order with tenant isolation', async () => {
    const workOrder = await repo.create({
      title: 'Test',
      companyId: 'tenant-1',
    });

    const found = await repo.findById(workOrder.id);
    expect(found).toEqual(workOrder);

    // Verify tenant isolation
    const otherTenant = await repo.findByIdForTenant(workOrder.id, 'tenant-2');
    expect(otherTenant).toBeNull();
  });
});
```

---

## High-Value Integration Tests

Focus integration tests on:

1. **Boundaries** - Where GraphQL meets domain, where domain meets database
2. **Critical paths** - Money calculations, tenant isolation, auth
3. **Complex queries** - Multi-table Drizzle operations

---

## Test Builders for Sombra

Create test objects easily to reduce boilerplate.

```typescript
class WorkOrderBuilder {
  private props: Partial<WorkOrderInsert> = {
    title: 'Default Work Order',
    description: 'Test description',
    status: 'pending',
    priority: 'medium',
  };

  withTitle(title: string): WorkOrderBuilder {
    this.props.title = title;
    return this;
  }

  withStatus(status: string): WorkOrderBuilder {
    this.props.status = status;
    return this;
  }

  withPriority(priority: string): WorkOrderBuilder {
    this.props.priority = priority;
    return this;
  }

  build(): WorkOrderInsert {
    return this.props as WorkOrderInsert;
  }
}

// Usage
const workOrder = new WorkOrderBuilder()
  .withTitle('Urgent Repair')
  .withPriority('high')
  .build();
```

---

## Running Tests

```bash
# Run all sombra tests
pnpm --filter sombra test:no-coverage

# Run specific test files
pnpm --filter sombra test:no-coverage workOrderOps.test.ts workOrderCreate.test.ts
```

## Common Testing Mistakes in Sombra

| Mistake | Problem | Solution |
|---------|---------|----------|
| Testing implementation (Drizzle queries) | Brittle tests | Test behavior and outcomes |
| Too many mocks | Tests prove nothing | Use real database for domain tests |
| Shared database state | Flaky tests | Clean/transactional setup per test |
| No assertions | False confidence | Always assert something meaningful |
| Testing trivial code | Wasted effort | Focus on logic and edge cases |
| Slow tests | Reduced feedback | Optimize queries, use unit tests |
| Missing tenant isolation tests | Security risk | Always verify `companyId` filtering |
