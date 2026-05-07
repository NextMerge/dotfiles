# SOLID Principles in Sombra

## Overview

SOLID helps structure software to be flexible, maintainable, and testable. These principles reduce coupling and increase cohesion. In Sombra, they apply to domain operations, resolvers, and feature structure.

## S - Single Responsibility Principle (SRP)

> "A class should have one, and only one, reason to change."

### Problem It Solves
God objects that do everything - hard to test, hard to change, hard to understand.

### How to Apply in Sombra
Each file and class handles ONE responsibility. If you find yourself saying "and" when describing what a module does, split it.

```typescript
// BAD: Resolver doing business logic
export const workOrderCreate: FeatureWorkOrdersMutationResolvers['workOrderCreate'] =
  async (_: unknown, { input }, ctx: Context) => {
    // Validation
    // Number generation
    // Database insert
    // Related item creation
    // All in one function!
    return { ... };
  };

// GOOD: Thin resolver delegates to domain
export const workOrderCreate: FeatureWorkOrdersMutationResolvers['workOrderCreate'] =
  async (_: unknown, { input }, ctx: Context) => {
    const result = await createWorkOrderOperation({
      db: ctx.db,
      ctx,
      params: { workOrderData: input, items: input.items },
    });
    return { workOrder: result };
  };
```

### Detection Questions
- Does this file have multiple reasons to change?
- Can I describe it without using "and"?
- Would different stakeholders request changes to different parts?

---

## O - Open/Closed Principle (OCP)

> "Software entities should be open for extension but closed for modification."

### Problem It Solves
Having to modify existing, tested code every time requirements change. Risk of breaking working features.

### How to Apply in Sombra
Design features so new behavior is added through new files, not edits to existing ones.

```typescript
// BAD: Must modify to add new export format
function exportFormResponses(format: string, data: FormResponse[]) {
  if (format === 'csv') return toCsv(data);
  if (format === 'pdf') return toPdf(data);
  // Must add more ifs for new formats!
}

// GOOD: Open for extension
interface FormResponseExporter {
  export(data: FormResponse[]): Promise<Buffer>;
}

class CsvExporter implements FormResponseExporter {
  async export(data: FormResponse[]): Promise<Buffer> { /* ... */ }
}

class PdfExporter implements FormResponseExporter {
  async export(data: FormResponse[]): Promise<Buffer> { /* ... */ }
}

// Add new format by creating new class, not modifying existing
class XlsxExporter implements FormResponseExporter {
  async export(data: FormResponse[]): Promise<Buffer> { /* ... */ }
}
```

### Architectural Insight
OCP at the feature level means: **design your feature so new operations are added by adding files, not changing existing resolvers or domain ops.**

---

## L - Liskov Substitution Principle (LSP)

> "Subtypes must be substitutable for their base types without altering program correctness."

### Problem It Solves
Subclasses that break expectations, requiring type-checking and special cases.

### How to Apply in Sombra
Subclasses and implementations must honor the contract of the parent/interface.

```typescript
// BAD: Violates parent's contract
class BasePermissionChecker {
  async canAccess(userId: string, resourceId: string): Promise<boolean> {
    return true;
  }
}

class StrictPermissionChecker extends BasePermissionChecker {
  async canAccess(userId: string): Promise<boolean> {
    // Different signature! Breaks expectations
    return false;
  }
}

// GOOD: Honors contract
class BasePermissionChecker {
  async canAccess(userId: string, resourceId: string): Promise<boolean> {
    return true;
  }
}

class StrictPermissionChecker extends BasePermissionChecker {
  async canAccess(userId: string, resourceId: string): Promise<boolean> {
    const user = await getUser(userId);
    const resource = await getResource(resourceId);
    return user.role === 'admin' || resource.ownerId === userId;
  }
}
```

---

## I - Interface Segregation Principle (ISP)

> "Clients should not be forced to depend on methods they do not use."

### Problem It Solves
Fat interfaces that force partial implementations, empty methods, or throws.

### How to Apply in Sombra
Split large parameter objects and context usage into smaller, cohesive pieces.

```typescript
// BAD: Fat context usage
async function someOperation({
  db,
  ctx,
  params,
}: OperationArguments<{
  userId: string;
  email: string;
  phone: string;
  address: string;
  notificationPreference: string;
}>) {
  // Only uses userId and email!
}

// GOOD: Segregated parameters
interface UserIdentificationParams {
  userId: string;
  email: string;
}

async function someOperation({
  db,
  ctx,
  params,
}: OperationArguments<UserIdentificationParams>) {
  // Clean, focused
}
```

### Detection
If you see unused destructured properties or parameters that are only partially used, the interface is too fat.

---

## D - Dependency Inversion Principle (DIP)

> "High-level modules should not depend on low-level modules. Both should depend on abstractions."

### Problem It Solves
Tight coupling to specific implementations (databases, APIs, frameworks). Hard to test, hard to swap.

### How to Apply in Sombra
For new features, depend on interfaces. For existing features, move toward abstraction when refactoring.

```typescript
// BAD: Direct dependency on Drizzle
class WorkOrderService {
  async create(data: WorkOrderInsert) {
    return await db.insert(workOrders).values(data).returning();
  }
}

// GOOD: Depend on abstraction
interface WorkOrderRepository {
  create(data: WorkOrderInsert): Promise<WorkOrder[]>;
  findById(id: string): Promise<WorkOrder | null>;
}

class DrizzleWorkOrderRepository implements WorkOrderRepository {
  constructor(private db: Database) {}

  async create(data: WorkOrderInsert): Promise<WorkOrder[]> {
    return this.db.insert(workOrders).values(data).returning();
  }

  async findById(id: string): Promise<WorkOrder | null> {
    // ... with tenant check
  }
}

// Domain operation uses interface
export const createWorkOrderOperation = async ({
  repo,
  ctx,
  params,
}: {
  repo: WorkOrderRepository;
  ctx: Context;
  params: { workOrderData: WorkOrderInsert; items: WorkOrderItemInsert[] };
}) => {
  return await repo.create({
    ...params.workOrderData,
    companyId: ctx.tenantId,
    createdBy: ctx.user.employeeId,
  });
};
```

### The Dependency Rule in Sombra
Source code dependencies should point **inward** toward high-level policies (domain logic), never toward low-level details (infrastructure).

```
Resolvers → Domain Operations → Repository Interfaces → Drizzle Implementation
   ↑              ↑                    ↑                      ↑
 (thin)       (business)          (contracts)            (outer)
```

---

## Applying SOLID at the Feature Level

These principles scale beyond individual files:

| Principle | Feature-Level Application |
|-----------|--------------------------|
| SRP | Each `feature-{name}/` has one clear responsibility |
| OCP | New features = new folders, not edits to existing feature resolvers |
| LSP | Feature resolvers with same mutation pattern are substitutable |
| ISP | Thin resolver params, focused domain operation inputs |
| DIP | Domain operations don't know about GraphQL or HTTP |

## Quick Reference

| Principle | One-Liner | Red Flag |
|-----------|-----------|----------|
| SRP | One reason to change | "This file handles X and Y and Z" |
| OCP | Add, don't modify | `if/else` chains for types in domain ops |
| LSP | Subtypes are substitutable | Type-checking or casting in calling code |
| ISP | Small, focused interfaces | Unused parameters in operations |
| DIP | Depend on abstractions | Direct `db.insert()` in resolver instead of domain op |
