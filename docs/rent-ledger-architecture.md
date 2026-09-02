# Rent ledger — architecture

**Status: design only. Deliberately not implemented.**

The operating rules for this project say billing is architecture-only, so this
document stops at the design. No migration, model, repository or screen in this
repo implements it yet.

## The gap this closes

"Rent" is in the product mission, and `tenancies` carries `rent_amount`,
`rent_cycle`, `utility_amount` and `deposit_amount` — the *terms*. Nothing
records what was actually **owed** in a given period or what was **received**
against it. Consequences today:

- A manager cannot answer "who is behind, and by how much?"
- `RentPaymentScreen` can show the rent figure but not a balance or a due date
- There is no history to reconcile against when a tenant disputes a payment

Note this is bookkeeping, not payment processing. Taking money (Flutterwave or
otherwise) is a separate concern and stays out of scope under the same rule.

## Shape

Two tables, deliberately separate. Charges are generated; payments are
recorded. Keeping them apart means a payment can be partial, late, or split
across periods without corrupting what was owed.

```
tenancies (exists)
    │ 1
    │
    │ n
rent_charges ─────────< rent_allocations >───── rent_payments
  what was owed          how a payment was        what came in
  for one period         split across charges
```

`rent_allocations` is what makes partial and lump-sum payments work. Without
it, a tenant paying two months at once, or half a month, forces either a fake
charge or a lying balance.

### rent_charges

One row per tenancy per billing period.

| column | type | notes |
|---|---|---|
| `id` | uuid pk | |
| `tenancy_id` | uuid → tenancies | cascade delete |
| `period_start` | date | |
| `period_end` | date | derived from `rent_cycle` |
| `due_date` | date | usually `period_start`; separate so grace periods are expressible |
| `rent_amount` | numeric(12,2) | snapshot, not a join |
| `utility_amount` | numeric(12,2) | snapshot |
| `currency` | text | snapshot from the property |
| `created_at` / `updated_at` | timestamptz | |

Amounts are **snapshotted at generation**, not read live from `tenancies`.
Otherwise raising the rent silently rewrites what a tenant owed last year.

Constraint: `unique (tenancy_id, period_start)` — the generator must be safely
re-runnable.

### rent_payments

One row per amount received.

| column | type | notes |
|---|---|---|
| `id` | uuid pk | |
| `tenancy_id` | uuid → tenancies | |
| `amount` | numeric(12,2) | `check (amount > 0)` |
| `paid_at` | timestamptz | when the money arrived, not when it was keyed in |
| `method` | enum | `cash`, `bank_transfer`, `card`, `other` |
| `reference` | text | teller slip, transfer ref |
| `recorded_by` | uuid → profiles | who keyed it in |
| `note` | text | |

`recorded_by` matters: when a manager records a cash payment there is no
external trace, so the ledger has to carry its own provenance.

### rent_allocations

| column | type |
|---|---|
| `payment_id` | uuid → rent_payments |
| `charge_id` | uuid → rent_charges |
| `amount` | numeric(12,2), `check (amount > 0)` |

Primary key `(payment_id, charge_id)`. Invariant: the allocations for a payment
sum to at most that payment's amount; the remainder sits as credit.

## Derived balances

A view rather than stored columns — a stored balance drifts the first time
someone edits a payment.

```sql
create view rent_charge_balances as
select
  c.*,
  coalesce(sum(a.amount), 0) as paid_amount,
  c.rent_amount + c.utility_amount - coalesce(sum(a.amount), 0) as outstanding,
  case
    when coalesce(sum(a.amount), 0) >= c.rent_amount + c.utility_amount
      then 'paid'
    when current_date > c.due_date then 'overdue'
    when coalesce(sum(a.amount), 0) > 0 then 'part_paid'
    else 'due'
  end as status
from rent_charges c
left join rent_allocations a on a.charge_id = c.id
group by c.id;
```

Status is computed, never written. It cannot go stale, and "overdue" changes on
its own as the date passes without a job running.

## Generating charges

A charge for the current period should exist without anyone remembering to
create it. Options, in order of preference:

1. **On read, idempotently.** A `security definer` function
   `ensure_rent_charges(p_tenancy_id)` that inserts any missing periods between
   the tenancy start and today, relying on the unique constraint. Called when
   the tenant or manager opens a rent view. No scheduler, nothing to monitor,
   and a dormant tenancy costs nothing.
2. **pg_cron nightly.** Simpler to reason about, but adds an extension and a
   failure mode that is invisible until someone notices missing charges.

Option 1 fits an MVP. It also degrades well: if nobody looks, nothing is owed
to anyone's attention anyway.

Generation stops at `end_date`, and skips tenancies with `status = 'ended'`.

## RLS

Follows the existing pattern exactly — `manages_unit()` for the manager side,
ownership for the tenant side, both reached through `tenancies`.

- `rent_charges`: manager of the tenancy's unit has full access; the tenant may
  `select` their own. Tenants never insert — charges are system-generated.
- `rent_payments`: manager full access. Tenant `select` only. A tenant
  recording their own payment would be an unverified claim; if self-reporting
  is wanted later it belongs in a separate `payment_claims` table a manager
  confirms, not in the ledger.
- `rent_allocations`: reachable only via a charge the caller can already see.

A `rents_unit()`-style helper already exists (migration 0013) and generalises
here as `is_tenant_of_tenancy(uuid)`.

## Surfacing

- **Tenant, `RentPaymentScreen`** — replaces the bare rent figure with the
  current period: amount, due date, paid-to-date, outstanding, and a history
  list. The "Pay Rent" action stays honestly disabled until processing exists.
- **Manager, dashboard** — an arrears metric: count of tenancies with any
  overdue charge, and total outstanding. This is the number that would justify
  the product on its own.
- **Manager, unit detail** — the tenancy's ledger, and the action to record a
  payment.

## What to decide before building

1. **Proration.** Does a tenancy starting on the 15th owe a half period, or a
   full one? Affects `rent_charges` generation and is a business decision, not
   a technical one.
2. **Utilities.** Modelled here as a fixed per-period amount alongside rent.
   Metered utilities would need their own charge type.
3. **Deposits.** `deposit_amount` sits on the tenancy and is not a recurring
   charge. It probably wants its own one-off charge row plus a refund path at
   tenancy end.
4. **Currency.** Snapshotted per charge. Multi-currency portfolios would need
   the dashboard totals to stop summing naively across currencies — worth
   checking, since `properties.currency` is already per-property.

Item 4 is a live issue in the current code: `DashboardStats` and the occupancy
figures are currency-agnostic today, but any money total across properties
would not be.
