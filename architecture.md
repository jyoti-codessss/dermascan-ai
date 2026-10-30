# DermaScan AI — System Architecture

## Goal
Build a secure, modular and scalable platform while keeping the MVP simple.

## High-Level Architecture
```text
Flutter Mobile App
        ↓
Node.js + TypeScript API
        ↓
PostgreSQL
        ↘
   Object Storage
        ↘
    AI Service
        ↘
   Maps/Places
```

## Backend
Use a modular monolith initially.

Modules:
```text
Auth
Users/Profile
Analysis
History
Nearby Care
Notifications
Storage
Admin
Common
```

Do not introduce microservices merely for complexity.

## AI
Keep ML inference isolated in a Python/FastAPI service where appropriate so the model can be replaced independently.

## Analysis
MVP:
```text
Client → Backend → AI Service → Result → Database
```

Scalable:
```text
Client → Backend → Queue → AI Worker → Model → Database → Notification
```

Introduce queues only when workload/inference time requires them.

## Storage
Use private object storage for images. PostgreSQL stores image metadata/object references, not large binaries.

## Ownership
```text
Authenticated user → Resource ownership check → Allow/Deny
```
Never trust a client-supplied user ID.

## API
Client communicates only through versioned APIs:
```text
/api/v1
```

## Errors
Return safe structured errors. Never expose stack traces, secrets or internal infrastructure details.

## Observability
Monitor API latency/errors, AI latency/failures, queue failures, storage failures, authentication failures and crashes. Do not log private images or unnecessary health data.

## Environments
```text
Development → Staging → Production
```

## Architecture Decisions
For major changes document:
1. Problem solved
2. Why current architecture is insufficient
3. Added complexity
4. Security impact
5. Cost impact
6. Development impact
7. Documentation affected

Record important decisions in `memory.md`.
