# Clean Code Practices for Sombra

> Code is read 10x more than it is written. Design for the human reader.

## What is Clean Code?

Code that is:
- **Easy to understand** - reveals intent clearly
- **Easy to change** - modifications are localized
- **Easy to test** - dependencies are injectable
- **Simple** - no unnecessary complexity

## The Human-Centered Approach

Code has THREE consumers:
1. **Users** - get their needs met
2. **Customers** - make or save money
3. **Developers** - must maintain it

Design for all three, but remember: **developers read code 10x more than they write it.**

---

## Naming Principles

### 1. Consistency & Uniqueness (HIGHEST PRIORITY)
Same concept = same name everywhere. One name per concept.

```typescript
// BAD: Inconsistent names for same concept
getWorkOrderById(id)
fetchWorkOrder(id)
retrieveWO(id)

// GOOD: Consistent
getWorkOrder(id)
getFormResponse(id)
getUser(id)
```

### 2. Understandability
Use domain language, not technical jargon.

```typescript
// BAD: Technical
const arr = workOrders.filter(wo => wo.isActive);

// GOOD: Domain language
const activeWorkOrders = workOrders.filter(workOrder => workOrder.isActive);
```

### 3. Specificity
**BANNED WORDS** - Never use these in names:
- `data`
- `info`
- `manager`
- `handler`
- `processor`
- `utils`
- `helper`
- `stuff`
- `thing`

```typescript
// BAD: Vague
class DataManager { }
function processInfo(data) { }
const utils = { ... };

// GOOD: Specific
class WorkOrderRepository { }
function validateWorkOrderInput(input) { }
const workOrderCalculations = { ... };
```

### 4. Brevity (but not at cost of clarity)
Short names are good only if meaning is preserved.

```typescript
// BAD: Too cryptic
const woLst = getWOs();

// BAD: Unnecessarily long
const listOfAllActiveWorkOrdersInTheSystemForCurrentTenant = getActiveWorkOrders();

// GOOD: Brief but clear
const activeWorkOrders = getActiveWorkOrders();
```

### 5. Searchability
Names should be unique enough to grep/search.

```typescript
// BAD: Common word, hard to search
const data = fetch();

// GOOD: Unique, searchable
const workOrderSummary = fetchWorkOrderSummary();
```

### 6. Pronounceability
You should be able to say it in conversation.

```typescript
// BAD
const genymdhms = generateYearMonthDayHourMinuteSecond();

// GOOD
const timestamp = generateTimestamp();
```

### 7. Austerity
Avoid unnecessary filler words.

```typescript
// BAD: Redundant
const workOrderData = workOrder;
class WorkOrderClass { }

// GOOD
const workOrder = workOrder;
class WorkOrder { }
```

---

## Functions & Methods

### Function Size Limits

| Layer | Maximum Lines | Rationale |
|-------|--------------|-----------|
| Resolvers | 15 | Should only validate, delegate, and return |
| Domain Operations | 30 | Business logic is inherently more complex |
| Helpers/Utilities | 20 | Pure functions should be concise |

**If you exceed the limit, extract a function.**

### Minimize Parameters

The fewer parameters, the easier to read and call.

```typescript
// BEST: No parameters - clear intent
generateWorkOrderNumber();

// GOOD: One parameter - straightforward
isValidWorkOrderStatus(status);

// OKAY: Two parameters - depends on context
createWorkOrder(title, description);

// BAD: Three+ parameters - hard to read and call
createWorkOrder(title, description, priority, status, dueDate, assignedTo);
```

**Reduce parameters by grouping into objects:**

```typescript
// BAD: Many positional parameters
createWorkOrder('Fix Roof', 'Shingle replacement', 'high', 'pending', '2024-12-01', 'emp-123');

// GOOD: Parameter object
createWorkOrder({
  title: 'Fix Roof',
  description: 'Shingle replacement',
  priority: 'high',
  status: 'pending',
  dueDate: DateTime.fromISO('2024-12-01'),
  assignedTo: 'emp-123',
});
```

### Do One Thing (Levels of Abstraction)

Functions should do **one thing** at **one level of abstraction**.

All operations in the function body should be on the **same level** of abstraction, exactly **one level below** the function name.

```typescript
// BAD: Mixed levels of abstraction
function processWorkOrder(workOrderId: string) {
  const fsConfig = { mode: 'read', onError: 'retry' };
  const workOrder = fileSystem.readFile(workOrderPath, fsConfig); // Too low level!
  const calculator = new TaxCalculator('US');
  const total = calculator.calculate(workOrder.items); // Appropriate level
  printer.print(total); // Mixed level
}

// GOOD: Consistent abstraction level
function processWorkOrder(workOrderId: string) {
  const workOrder = fetchWorkOrder(workOrderId);
  const total = calculateWorkOrderTotal(workOrder);
  generateInvoice(total);
}
```

### Split Functions Reasonably

Don't extract just for the sake of extraction. **Three warning signs** of bad splits:
1. You are just **renaming the operation**
2. You need to **scroll more** to follow a simple function
3. You **cannot find a good name** because the original name is already taken

```typescript
// OVER-SPLIT: Too many trivial extractions
function createWorkOrder(input: WorkOrderInput) {
  validateInput(input);
  saveWorkOrder(input);
}
function saveWorkOrder(input: WorkOrderInput) {
  const workOrder = buildWorkOrder(input);
  workOrder.save();
}
function buildWorkOrder(input: WorkOrderInput) {
  return new WorkOrder(input); // Just renaming!
}

// BETTER: Meaningful splits only
function createWorkOrder(input: WorkOrderInput) {
  validateInput(input);
  const workOrder = new WorkOrder(input);
  workOrder.save();
}
```

**Two rules of thumb for when to split:**
1. Extract code that works on the **same functionality**
2. Extract code that requires **more interpretation** than the surrounding code

### Avoid Unexpected Side Effects

A side effect is unexpected when the function name does not imply it.

```typescript
// BAD: Unexpected side effect
function validateWorkOrderInput(input: WorkOrderInput) {
  if (!input.title || input.title.length < 3) {
    throw new Error('Invalid title');
  }
  createAuditLog('work_order_validated', input); // unexpected!
}

// GOOD: Move side effect out, or rename to imply it
function validateAndLogWorkOrderInput(input: WorkOrderInput) {
  validateWorkOrderInput(input);
  createAuditLog('work_order_validated', input);
}
```

---

## Control Structures

### Prefer Positive Checks

Use positive wording in conditions when possible.

```typescript
// GOOD: Positive check
if (isEmpty(workOrder.items)) {
  throw new Error('Work order must have at least one item');
}

// LESS CLEAR: Negated positive
if (!hasItems(workOrder)) {
  throw new Error('Work order must have at least one item');
}
```

Exception: sometimes a negative check is cleaner.

```typescript
// GOOD: Negative check avoids listing all invalid states
if (!isOpen(workOrder)) {
  throw new Error('Cannot modify closed work order');
}
```

### Avoid Deep Nesting

Deeply nested code is hard to read and error-prone. Strategies to flatten:

#### 1. Use Guards and Fail Fast

```typescript
// BAD: Deep nesting
function processWorkOrderItems(workOrder: WorkOrder) {
  if (workOrder) {
    if (workOrder.items) {
      if (workOrder.items.length > 0) {
        for (const item of workOrder.items) {
          if (item.inStock) {
            processItem(item);
          }
        }
      }
    }
  }
}

// GOOD: Guard clause, fail fast
function processWorkOrderItems(workOrder: WorkOrder) {
  if (!workOrder?.items?.length) return;

  workOrder.items
    .filter(item => item.inStock)
    .forEach(processItem);
}
```

#### 2. Extract Control Structures into Functions

```typescript
// BAD: Nested control structure
function assignWorkOrder(workOrderId: string, employeeId: string) {
  if (!workOrderId) {
    throw new Error('Work order ID is required');
  }
  const workOrder = findWorkOrder(workOrderId);
  if (!workOrder) {
    throw new Error('Work order not found');
  }
  if (workOrder.status === 'closed') {
    throw new Error('Cannot assign closed work order');
  }
}

// GOOD: Extract validations
function assignWorkOrder(workOrderId: string, employeeId: string) {
  validateWorkOrderId(workOrderId);
  const workOrder = findWorkOrderOrThrow(workOrderId);
  validateWorkOrderCanBeAssigned(workOrder);
}
```

#### 3. Use Polymorphism and Factory Functions

Replace duplicated conditional logic with polymorphic objects.

```typescript
// BAD: Repeated type checks
function calculateTax(workOrder: WorkOrder) {
  if (workOrder.tenantCountry === 'US') {
    if (workOrder.tenantState === 'CA') {
      return workOrder.subtotal * 0.0725;
    }
    if (workOrder.tenantState === 'NY') {
      return workOrder.subtotal * 0.08;
    }
  } else if (workOrder.tenantCountry === 'CA') {
    return workOrder.subtotal * 0.13;
  }
  return 0;
}

// GOOD: Factory function with polymorphic object
function getTaxStrategy(workOrder: WorkOrder) {
  if (workOrder.tenantCountry === 'CA') {
    return { calculate: (subtotal: number) => subtotal * 0.13 };
  }
  if (workOrder.tenantState === 'CA') {
    return { calculate: (subtotal: number) => subtotal * 0.0725 };
  }
  if (workOrder.tenantState === 'NY') {
    return { calculate: (subtotal: number) => subtotal * 0.08 };
  }
  return { calculate: (_: number) => 0 };
}

function calculateTax(workOrder: WorkOrder) {
  const strategy = getTaxStrategy(workOrder);
  return strategy.calculate(workOrder.subtotal);
}
```

#### 4. Embrace Errors (throw instead of error codes)

```typescript
// BAD: Synthetic errors with status codes
function createWorkOrder(input: WorkOrderInput) {
  const validity = validateInput(input);
  if (validity.code === 1 || validity.code === 2) {
    console.log(validity.message);
    return;
  }
}

// GOOD: Use real errors with try-catch
function handleWorkOrderRequest(request: CreateWorkOrderRequest) {
  try {
    createWorkOrder(request.input);
  } catch (error) {
    console.log(error.message);
  }
}

function createWorkOrder(input: WorkOrderInput) {
  validateInput(input);
  // ... continue
}

function validateInput(input: WorkOrderInput) {
  if (!input.title || input.title.length < 3) {
    throw new Error('Title must be at least 3 characters');
  }
}
```

---

## Classes and Objects

### Objects vs Data Containers

Distinguish between **objects** (hide data, expose behavior) and **data containers** (expose data, no behavior).

```typescript
// Data Container: exposes data publicly
interface WorkOrderData {
  title: string;
  description: string;
  status: string;
}

// Object: hides data, exposes behavior
class WorkOrder {
  private title: string;
  private description: string;
  private status: string;

  constructor(title: string, description: string) {
    this.title = title;
    this.description = description;
    this.status = 'pending';
  }

  canBeAssigned(): boolean {
    return this.status !== 'closed';
  }

  assignTo(employeeId: string): void {
    if (!this.canBeAssigned()) {
      throw new Error('Cannot assign closed work order');
    }
    // ...
  }
}
```

Both are valid - use the right kind for the right job. **Do not mix types**: do not access internals of objects, and do not add behavior to data containers.

### Class Cohesion

**Cohesion** = how much methods use class properties. High cohesion means every method uses most properties.

- **High cohesion** -> well-designed, focused class
- **Low cohesion** -> should probably be a data container or split into smaller classes

When cohesion decreases, **split into smaller, more focused classes**.

---

## Object Calisthenics for Sombra

Exercises to improve OO design. Follow strictly during practice, relax slightly in production.

### 1. One Level of Indentation per Method

```typescript
// BAD: Multiple levels
function process(workOrders: WorkOrder[]) {
  for (const workOrder of workOrders) {
    if (workOrder.isValid()) {
      for (const item of workOrder.items) {
        if (item.inStock) {
          // process...
        }
      }
    }
  }
}

// GOOD: Extract methods
function process(workOrders: WorkOrder[]) {
  workOrders.filter(o => o.isValid()).forEach(processOrder);
}

function processOrder(order: WorkOrder) {
  order.items.filter(i => i.inStock).forEach(processItem);
}
```

### 2. Do Not Use the ELSE Keyword

Use early returns, guard clauses, or polymorphism.

```typescript
// BAD: else
function getDiscount(workOrder: WorkOrder): number {
  if (workOrder.isPriority) {
    return 20;
  } else {
    return 0;
  }
}

// GOOD: Early return
function getDiscount(workOrder: WorkOrder): number {
  if (workOrder.isPriority) return 20;
  return 0;
}
```

### 3. Wrap All Primitives and Strings

Primitives should be wrapped in domain objects when they have meaning.

```typescript
// BAD: Primitive obsession
function createWorkOrder(title: string, tenantId: string) { }

// GOOD: Value objects (encouraged for new features)
class TenantId {
  constructor(private value: string) {
    if (!value) throw new Error('TenantId cannot be empty');
  }
}

function createWorkOrder(title: string, tenantId: TenantId) { }
```

**Note:** Existing code may use raw primitives. New features should value objects where they improve clarity.

### 4. First-Class Collections

Any class with a collection should have no other instance variables.

```typescript
// BAD: Collection mixed with other state
class WorkOrder {
  items: WorkOrderItem[] = [];
  customerId: string;
  total: number;
}

// GOOD: Collection is its own class
class WorkOrderItems {
  constructor(private items: WorkOrderItem[] = []) {}

  add(item: WorkOrderItem): void { ... }
  total(): number { ... }
  isEmpty(): boolean { ... }
}

class WorkOrder {
  constructor(
    private items: WorkOrderItems,
    private customerId: string
  ) {}
}
```

### 5. One Dot per Line (Law of Demeter)

Do not chain through object graphs.

```typescript
// BAD: Train wreck
const state = workOrder.customer.address.state;

// GOOD: Tell, do not ask
const state = workOrder.getCustomerState();
```

### 6. Do Not Abbreviate

If a name is too long to type, the class is doing too much.

```typescript
// BAD
const woRepo = new WORepo();
const wo = new WO();

// GOOD
const workOrderRepository = new WorkOrderRepository();
const workOrder = new WorkOrder();
```

### 7. Keep All Entities Small

- Classes: aim for <100 lines
- Methods: aim for <30 lines (domain ops) or <15 lines (resolvers)
- Files: aim for <200 lines

If larger, it is probably doing too much. Split it.

### 8. No Classes with More Than 5 Instance Variables

Forces small, focused classes. (Relaxed from 2 for Drizzle entity compatibility.)

```typescript
// BAD: Too many variables
class WorkOrder {
  id: string;
  title: string;
  description: string;
  status: string;
  priority: string;
  dueDate: string;
  assignedTo: string;
  createdBy: string;
  companyId: string;
}

// GOOD: Composed of smaller objects
class WorkOrder {
  constructor(
    private id: string,
    private details: WorkOrderDetails,
    private assignment: WorkOrderAssignment
  ) {}
}
```

### 9. No Getters/Setters/Properties

Objects should have behavior, not just data. Tell objects what to do.

```typescript
// BAD: Data bag with getters
class WorkOrder {
  getStatus(): string { return this.status; }
  setStatus(value: string) { this.status = value; }
}

// Caller does the work
if (workOrder.getStatus() === 'pending') {
  workOrder.setStatus('in_progress');
}

// GOOD: Behavior-rich object
class WorkOrder {
  startWork(): void {
    if (this.status !== 'pending') {
      throw new Error('Only pending work orders can be started');
    }
    this.status = 'in_progress';
  }
}

// Caller tells, object decides
workOrder.startWork();
```

---

## Comments

### When to Write Comments

**Only write comments to explain WHY, not WHAT or HOW.**

Code explains what and how. Comments explain business reasons, non-obvious decisions, or warnings.

```typescript
// BAD: Explains what (redundant)
// Add 1 to counter
counter++;

// GOOD: Explains why
// Compensate for 0-based indexing in legacy API
counter++;
```

### Prefer Self-Documenting Code

Instead of commenting, rename to make intent clear.

```typescript
// BAD: Comment needed
// Check if user can access premium features
if (user.subscriptionLevel >= 2 && !user.isBanned) { }

// GOOD: Self-documenting
if (user.canAccessPremiumFeatures()) { }
```

---

## Formatting

### Vertical Spacing
- Related code together
- Blank lines between concepts
- Most important/public at top

### Horizontal Spacing
- Consistent indentation
- Space around operators
- Max line length ~100-120 characters

### Storytelling
Code should read top-to-bottom like a story. High-level at top, details below.

```typescript
class WorkOrderProcessor {
  // Public API first
  process(workOrder: WorkOrder): ProcessResult {
    this.validate(workOrder);
    this.calculateTotals(workOrder);
    return this.save(workOrder);
  }

  // Supporting methods below, in order of appearance
  private validate(workOrder: WorkOrder): void { ... }
  private calculateTotals(workOrder: WorkOrder): void { ... }
  private save(workOrder: WorkOrder): ProcessResult { ... }
}
```

---

## Clean Code Checklist

### Naming
- [ ] Use **descriptive** and meaningful names
  - Variables and Properties: Nouns or short phrases with adjectives
  - Functions and Methods: Verbs or short phrases with adjectives
  - Classes: Nouns
- [ ] Be as **specific** as necessary and possible
- [ ] Use **yes/no "questions"** for booleans (e.g. `isValid`)
- [ ] Avoid **misleading** names
- [ ] Be **consistent** with names (e.g. stick to `get...` instead of `fetch...`)

### Comments and Formatting
- [ ] **Most comments are bad** - avoid them!
- [ ] Acceptable comments: legal info, warnings, regex explanations, todos
- [ ] Use **vertical formatting**: keep related concepts close, separate unrelated ones
- [ ] Write code **top to bottom**: called functions below calling functions
- [ ] Use **horizontal formatting**: avoid long lines, use indentation for scope

### Functions
- [ ] **Limit parameters** - fewer is better, use objects to group
- [ ] Functions should be **small and do one thing**
  - Abstraction levels in the body should be **one level below** the function name
  - **Do not mix** levels of abstraction
  - But **avoid redundant splitting**!
- [ ] Stay **DRY** (Do Not Repeat Yourself)
- [ ] **Avoid unexpected side effects**

### Control Structures and Errors
- [ ] Prefer **positive checks**
- [ ] Avoid **deep nesting**
  - Use **guard** statements and fail fast
  - Use **polymorphism** and factory functions
  - **Extract** control structures into separate functions
- [ ] Use **real errors** (throw/catch) instead of synthetic error codes

### Objects and Classes
- [ ] Build either **"real objects"** or **data containers** - do not mix
- [ ] Build **small classes** focused on a **single responsibility**
- [ ] Build classes with **high cohesion**
- [ ] Follow the **Law of Demeter** for real objects
- [ ] Follow the **SOLID principles** (especially SRP and OCP for clean code)
