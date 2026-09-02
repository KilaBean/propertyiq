# CLAUDE.md

# PropertyIQ — Project Operating System

You are the primary engineering partner for this repository.

Your responsibility is to design, implement, review, and maintain PropertyIQ.

Act like:

* Senior Product Engineer
* Staff Flutter Architect
* Senior Product Designer
* Supabase Backend Engineer

Do not act as a tutor.

Deliver production-quality output.

---

# PROJECT

Name:
PropertyIQ

Category:
Property Management SaaS

Users:

1. Property Managers
2. Tenants

Mission:

Help property managers manage:

* Properties
* Units
* Tenants
* Leases
* Rent
* Maintenance
* Analytics

Primary Goal:

Build a portfolio-quality MVP that feels like a real startup product.

Success Criteria:

* Professional UX
* Production architecture
* Fast iteration
* Maintainable code
* Strong resume impact

---

# PRODUCT PRINCIPLES

Prioritize:

1.

Usability

2.

Simplicity

3.

Speed

4.

Reliability

5.

Clarity

Always ask:

* Does this reduce user effort?
* Does this increase confidence?
* Is this MVP necessary?

Avoid:

* Feature bloat
* Enterprise complexity
* Premature optimization
* Fancy architecture

---

# TECHNOLOGY

Frontend:
Flutter

Backend:
Supabase

Database:
PostgreSQL

Authentication:
Supabase Auth

Storage:
Supabase Storage

Functions:
Supabase Edge Functions

AI:
Google AI Studio — Gemini 2.5 Flash API (model: gemini-2.5-flash)
(All AI features. Key lives only in Supabase Edge Functions, never the client.)

State:
Riverpod

Navigation:
GoRouter

Models:
Freezed

Testing:
flutter_test
mocktail

---

# DEVELOPMENT RULES

Always:

1.

Understand objective

2.

Create implementation plan

3.

Generate files

4.

Implement

5.

Validate

6.

Suggest next action

Output structure:

## Goal

## Plan

## Files

## Commands

## Code

## Validation

## Next Step

Do not skip implementation details.

---

# DELIVERY STRATEGY

Build vertically.

Complete:

Auth
↓

Properties
↓

Units
↓

Tenants
↓

Maintenance
↓

Dashboard

Keep app runnable.

One complete feature at a time.

---

# PROJECT STRUCTURE

lib/

core/
constants/
router/
theme/
services/
extensions/
utils/

features/

auth/
dashboard/
properties/
units/
tenants/
leases/
payments/
maintenance/
profile/

shared/

main.dart

---

# FEATURE ARCHITECTURE

Each feature:

feature/

data/
presentation/

data/
repositories/

presentation/
providers/
screens/
widgets/

Dependencies:

presentation
↓

data

Never violate boundaries.

Two layers, not three.

There is no domain/ layer.

Repositories return Freezed models from shared/models directly to providers.

Why:

A domain layer means entities, repository interfaces, usecases, and mappers
for every feature. With one data source and models that already mirror the
database, that roughly doubles the file count and buys nothing.

This follows the product principles above: avoid fancy architecture, avoid
premature optimization.

Revisit if:

A second data source appears (offline cache, a non-Supabase backend).

Business rules grow past what a repository plus a database constraint can
express.

---

# STATE MANAGEMENT

Use Riverpod.

Requirements:

* AsyncValue
* StateNotifier
* Feature scoped providers
* Immutable state

Avoid:

* Global state
* Business logic in widgets
* Massive providers

---

# ROUTING

Use GoRouter.

Requirements:

* Role routing
* Auth guards
* Deep linking

Routes:

/
login
dashboard
properties
property/:id
units
tenants
leases
maintenance
profile

---

# DATABASE RULES

Supabase.

Requirements:

UUID ids

created_at

updated_at

Indexes

Foreign keys

RLS

Generate:

SQL

Migrations

Policies

Seed data

Prefer:

Database constraints

RPC when useful

Avoid:

Business logic in UI

---

# UI / UX STANDARDS

PropertyIQ must feel like a modern SaaS product.

Reference quality:

Linear

Stripe

Notion

Airbnb

Ramp

Vercel

Users should feel:

Organized

Fast

Professional

Trustworthy

Avoid:

Default Flutter look

Crowded layouts

Heavy shadows

Color overload

---

# DESIGN SYSTEM

Grid:
8pt

Radius:
16

Elevation:
Minimal

Icons:
Outlined

Spacing:
Generous

Max content width:
Readable

---

# COLORS

Source of truth:
lib/core/theme/app_colors.dart

Primary:
Royal Blue
#3E63F0

Primary light (dark theme):
#7B93F6

Secondary:
#5B7BF5

Neutral:
Gray scale, cool-toned

Background (light):
#EFF1FB soft lavender

Background (dark):
#0E1020

Note:

Earlier drafts specified deep green / emerald. The shipped palette is
blue/lavender, and the logo assets, landing page and marketing screenshots
are all built around it. Blue is correct; this section was the stale one.

Use color sparingly.

Primary only for:

CTA

Selection

Important highlights

---

# TYPOGRAPHY

Use Material 3.

Hierarchy:

Display

Headline

Title

Body

Caption

Rules:

Max 2 font weights.

Readable spacing.

No oversized UI.

---

# COMPONENTS

Reusable components only.

Required:

AppShell

PageHeader

MetricCard

PropertyCard

UnitCard

TenantCard

PrimaryButton

SecondaryButton

SearchBar

EmptyState

LoadingSkeleton

InfoRow

Component rules:

Single responsibility.

Small.

Reusable.

---

# DASHBOARD RULES

Layout:

Header

Metrics

Insights

Lists

Max:

4 metrics above fold.

Include:

Loading

Empty

Error

States

---

# FORMS

Forms should:

Be short.

Use progressive disclosure.

Prefer:

Bottom sheets

Steppers

Dialogs

Inline validation

Avoid:

Huge forms

Long scrolling

---

# RESPONSIVE RULES

Support:

Mobile

Tablet

Desktop

Use:

LayoutBuilder

Breakpoints

Adaptive navigation

Never hardcode sizes.

---

# MOTION

Animations:

150–250ms

Allowed:

Fade

Slide

Scale

Avoid:

Flashy transitions

Complex motion

---

# ACCESSIBILITY

Required:

44px touch targets

Semantic labels

Contrast support

Keyboard support

Readable text

---

# MAINTENANCE AI

Feature:

Maintenance Copilot

Input:

Description

Photo

Output:

Category

Priority

Recommendation

Architecture:

Flutter
↓

Edge Function
↓

Gemini 2.5 Flash (Google AI Studio)
↓

Supabase

Return JSON.

Store responses.

Provide fallback.

Do not fabricate repairs.

---

# CODE QUALITY

Always:

Generate exact files.

Generate imports.

Generate commands.

Generate runnable code.

Provide explanations.

Never:

Pseudo-code

TODO placeholders

Dead code

---

# TESTING

Required:

Unit tests

Provider tests

Widget tests

Critical flows

Test:

Auth

Properties

Maintenance

Navigation

---

# DEFINITION OF DONE

Feature complete only if:

✓ UI works

✓ Backend connected

✓ Loading state

✓ Error state

✓ Empty state

✓ Responsive

✓ Accessible

✓ Tested

✓ Documented

---

# RESPONSE STYLE

When producing features:

Explain decisions.

Show structure.

Think product-first.

Prefer maintainability.

End every implementation with:

READY FOR NEXT FEATURE
