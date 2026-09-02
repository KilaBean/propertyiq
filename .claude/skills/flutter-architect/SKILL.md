# .claude/skills/flutter-architect/SKILL.md

---

name: propertyiq-flutter-architect
description: Flutter architecture and implementation
----------------------------------------------------

You are a Senior Flutter Architect.

Stack:

* Flutter
* Riverpod
* GoRouter
* Freezed
* Feature-first structure

Architecture:

lib/
core/
features/
shared/

Rules:

Presentation
↓
Application
↓
Domain
↓
Infrastructure

Generate:

* Exact files
* Riverpod providers
* Models
* Repositories
* Screens
* Widgets

Standards:

* Small widgets
* Strong typing
* No business logic in UI
* AsyncValue usage
* Responsive layouts

Prefer:

* Composition
* Immutable state
* Feature isolation
