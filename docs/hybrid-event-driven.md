# Why We Adopted Hybrid Event-Driven Architecture

## 📌 Background Motivation

The iN project is essentially a **multi-stage image processing system**, involving:

- Downloading raw images
- Extracting metadata
- AI analysis and vector generation
- Search, query, and display

This workflow is **asynchronous, segmentable, and event-sensitive**, with side-effect logic like user notifications and indexing. It is well-suited to an **event-driven approach**, but also requires **strong consistency and traceability**, especially for status management and core flow control.

Thus, we did not fully embrace a pure event-driven architecture but opted for:

> **Hybrid Event-Driven Architecture**

---

## ✅ Reasons for Adoption

1. **Precise control & state tracking** for core workflows
   - Using **Task Queues + Durable Objects** to ensure determinism and idempotency.

2. **Decoupled handling for side effects**
   - Side logics like notification or analytics don’t need to block core flows and are better handled asynchronously.

3. **Maintain system clarity & scalability**
   - Separates deterministic core logic from optional subscriber-driven flows for better maintainability and testing.

---

## 🌱 Implementation in iN

| Layer | Mechanism | Explanation |
|-------|-----------|-------------|
| Core Workflow | Task Queues + Durable Objects | Strict control: Download -> Metadata -> AI |
| Event Publication | Optional in Workers (e.g. image.downloaded) | Workers may publish when processing succeeds |
| Event Subscribers | Pluggable Workers (e.g. notification-worker) | Consume from Event Queues |
| Event Interface | Provided in `shared-libs/events/` | Standard `INEvent<T>` interface |
| Event Queues | (Optional) ImageEventsQueue, TaskLifecycleEventsQueue | Enable pub/sub with DLQ support |

---

## 🌈 Benefits

- ✅ Clear control in core logic
- ✅ Scalable & decoupled side-effect handling
- ✅ Improved observability (auditable events)
- ✅ Highly extensible, supports future plugin-based development

---

## ⚠️ Design Principles

- **Events should be facts, not commands**  
  E.g., `image.downloaded` signals completion, not a request.

- **All subscribers must be idempotent**  
  Duplicate events should never cause duplicate effects.

- **Failure in subscriber must not block main flow**  
  Use DLQs and fallback gracefully.

- **Main flow is never modeled as an event chain**  
  Ensures stronger traceability and control.

---

## 🔭 Future Evolution

- Current event queues and definitions are available but **optional**.
- System can be easily extended with new subscribers (e.g., recommenders, loggers, tag enhancers).

---

## 📘 Summary

> The iN project adopts a **Hybrid Event-Driven Architecture**, using task queues for reliable control of core workflows, and event queues for decoupled side-effect broadcasting. This pattern strikes a balance between structure and flexibility, suitable for modern distributed systems.