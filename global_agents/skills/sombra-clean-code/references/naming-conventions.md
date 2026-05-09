# Naming Conventions for Sombra

## Banned Words

**NEVER use these in names.** They are vague, unsearchable, and indicate a lack of thought about responsibility.

| Banned Word | Why | Instead Use |
|-------------|-----|-------------|
| `data` | Adds no meaning | The actual domain concept |
| `info` | Vague and generic | `details`, `summary`, `metadata` |
| `manager` | Unclear responsibility | `repository`, `service`, `coordinator` |
| `handler` | What does it handle? | `processor`, `validator`, `creator` |
| `processor` | Too generic | `transformer`, `calculator`, `generator` |
| `utils` | Dumping ground | Specific noun: `dateUtils` -> `dateFormatter` |
| `helper` | Unclear scope | Specific verb-based name |
| `stuff` | Unprofessional | The actual domain concept |
| `thing` | Meaningless | The actual domain concept |

## Sombra Naming Patterns

### Feature Folder

```
src/feature-{kebab-case-name}/
```

Examples:
- `feature-work-orders`
- `feature-form-responses`
- `feature-inventory-items`

### Resolvers

**Per operation:**
```typescript
// Mutation resolvers
{entity}{Action}.ts           // e.g., workOrderCreate.ts
{entity}{Action}.typeDefs.ts  // e.g., workOrderCreate.typeDefs.ts

// Query resolvers
{entity}{Query}.ts            // e.g., workOrderGet.ts
{entity}{Query}.typeDefs.ts   // e.g., workOrderGet.typeDefs.ts
```

**Per entity (grouped):**
```typescript
{entity}.resolvers.ts         // e.g., workOrder.resolvers.ts
{entity}.typeDefs.ts          // e.g., workOrder.typeDefs.ts
```

### Domain Operations

```typescript
{entity}Ops.ts                // e.g., workOrderOps.ts
{entity}{Purpose}Ops.ts       // e.g., workOrderPDFOps.ts
```

**Function names:**
```typescript
{action}{Entity}Operation     // e.g., createWorkOrderOperation
{action}{Entity}{Purpose}     // e.g., generateWorkOrderPDF
```

### Exports from index.ts

```typescript
// Mutation resolvers export
export const feature{PascalCase}MutationResolvers = {
  {camelCaseAction},
};

// Query resolvers export
export const feature{PascalCase}QueryResolvers = {
  {camelCaseQuery},
};
```

## Booleans

Use yes/no questions. Prefix with `is`, `has`, `can`, `should`.

```typescript
// GOOD
isActive
hasPermission
canBeAssigned
shouldNotify

// BAD
active       // noun or adjective, not a question
notify       // sounds like an action
permission   // sounds like a property
```

## Collections

Use plural nouns for arrays. Use specific collection names when wrapping.

```typescript
// GOOD
const workOrders: WorkOrder[] = [];
const activeWorkOrders = workOrders.filter(wo => wo.isActive);

// BAD
const workOrderList = [];  // redundant
const workOrderArray = []; // redundant
const items = [];          // too vague
```

## Async Functions

Prefix with the action, not the mechanism.

```typescript
// GOOD
getWorkOrder(id)
createWorkOrder(input)
validateWorkOrder(data)

// BAD
fetchWorkOrder(id)     // Inconsistent if others use get
asyncWorkOrder(id)     // Implementation detail
promiseWorkOrder(id)   // Implementation detail
```

## GraphQL Types

Follow the existing pattern:

```typescript
// Input types
{Operation}Input        // e.g., WorkOrderCreateInput

// Output types
{Operation}Output       // e.g., WorkOrderCreateOutput

// Feature mutation namespace
Feature{Name}Mutation   // e.g., FeatureWorkOrdersMutation

// Feature query namespace
Feature{Name}Query      // e.g., FeatureWorkOrdersQuery
```

## Consistency Rules

1. **One term per concept.** If you call it `workOrder` in one file, do not call it `wo`, `job`, or `task` in another.
2. **One concept per term.** Do not use `get` to mean both "fetch from database" and "calculate derived value."
3. **Domain over technical.** `workOrder` is better than `record`. `tenant` is better than `company` when referring to the isolation boundary.
4. **Searchability matters.** Avoid generic names like `result`, `value`, `item` in local scope. Use `createdWorkOrder`, `taxAmount`, `inventoryItem`.
