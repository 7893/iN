# Shared Libraries and Abstractions in iN Project

## Overview

This document outlines the core components that are abstracted into shared libraries or implemented outside of individual Workers within the iN project. This supports modularity, maintainability, and modern software engineering practices like Separation of Concerns and Functional Programming.

---

## ✅ Shared Libraries (shared-libs/)

These are utilities and modules reused across multiple Workers and are essential to ensure consistent behavior, better testing, and centralized maintenance.

### 1. `logger.ts` – Structured Logging
**Purpose**: Outputs uniform JSON logs.
**Used by**: All Workers  
**Features**:
- Injects `traceId`, `taskId`, `workerName`.
- Supports `debug/info/warn/error`.
- Default output to `console` for Logpush compatibility.

### 2. `trace.ts` – Trace ID Management
**Purpose**: Generate, extract, propagate `traceId`.
**Used by**: All API and task Workers  
**Features**:
- Generate UUID/nanoid.
- Extract from headers or queue messages.
- Safe context handling.

### 3. `auth.ts` – Authentication Handler
**Purpose**: Validate JWT and HMAC.
**Used by**: All API Workers (via API Gateway)  
**Features**:
- JWT + claims check.
- HMAC verification.
- Produces `INUserContext`.

### 4. `task.ts` – DO Task State Wrapper
**Purpose**: Read/write to Task Coordinator DO.
**Used by**: `config-worker`, `download-worker`, `metadata-worker`, `ai-worker`  
**Features**:
- Encapsulates `setState()`, `getState()`.
- Optionally enforces state transition.
- Includes trace logging.

### 5. `events/` – Event Definitions
**Purpose**: Shared structure and types for system events.
**Used for**: Future Pub/Sub and logging consistency  
**Features**:
- Defines `INEvent<T>` interface.
- Centralizes `event-types.ts`.

### 6. `shared-utils/` (Optional)
**Purpose**: Utility functions
**Examples**:
- `toISO()`, `toUnix()` timestamps.
- `generateTaskId()`.
- Retry logic.
- Shared env loader.

---

## ✅ Non-Worker Logic Modules

Modules not deployed directly but critical to runtime or development flow.

### Secrets Management
**Tool**: Cloudflare Secrets Store  
**Purpose**: Centralized secret handling.  
**Managed via**: `.env`, `terraform.tfvars`, CI/CD.

### Request Validation
**Suggested**: `request-schema.ts`  
**Tooling**: Zod / Valibot  
**Purpose**: Validate incoming requests schema.

### Test Utilities
**Suggested**: `test-utils.ts`  
**Purpose**:
- Generate mocks.
- Simulate Queue messages.
- Useful in Vitest/Jest.

---

## 🧩 Summary Table

| Category         | Module / Folder                  | Description                                 |
|------------------|----------------------------------|---------------------------------------------|
| Logging          | `shared-libs/logger.ts`          | Structured JSON logging for all Workers     |
| Tracing          | `shared-libs/trace.ts`           | Trace ID propagation                        |
| Authentication   | `shared-libs/auth.ts`            | JWT/HMAC verification logic                 |
| Task State Mgmt  | `shared-libs/task.ts`            | Durable Object state update wrapper         |
| Event Modeling   | `shared-libs/events/`            | Event types and interfaces                  |
| Utility Toolkit  | `shared-libs/shared-utils/`      | Time, ID, retry, env                        |
| Test Mocks       | `shared-libs/test-utils.ts`      | Helpers for test and integration scenarios  |
| Request Schema   | `shared-libs/request-schema.ts`  | Schema validators for API inputs            |
| Secrets Mgmt     | Cloudflare Secrets Store         | Global secret distribution and storage      |

---

This modular structure promotes consistency, type safety, and long-term maintainability across the entire iN architecture.
