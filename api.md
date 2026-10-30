# DermaScan AI — API Specification

## Conventions
Base path:
```text
/api/v1
```
Production uses HTTPS. JSON is the default format except file-upload endpoints.

## Standard Responses
Success:
```json
{"success":true,"data":{}}
```

Error:
```json
{"success":false,"error":{"code":"VALIDATION_ERROR","message":"Invalid request."}}
```

Never expose stack traces.

## Authentication
```http
POST /auth/register
POST /auth/login
POST /auth/logout
POST /auth/forgot-password
POST /auth/reset-password
POST /auth/verify-email
```

## User
```http
GET    /users/me
PATCH  /users/me
DELETE /users/me
```

## Profile
```http
GET   /profile
PATCH /profile
POST  /profile/image
```

## Analysis
```http
POST   /analyses
GET    /analyses
GET    /analyses/:id
DELETE /analyses/:id
```

Support pagination for lists.

## Analysis Status
```text
pending
uploading
processing
completed
low_confidence
unable_to_analyze
failed
```

## AI Result
```json
{
  "prediction": "acne",
  "confidence": 0.87,
  "alternatives": [],
  "modelVersion": "dermascan-v1.0"
}
```

Confidence must never be represented as diagnostic certainty.

## Nearby Care
```http
GET /nearby/dermatologists
GET /nearby/hospitals
GET /nearby/places/:placeId
```

Typical parameters:
```text
latitude
longitude
radius
query
```

Validate coordinates and radius.

## Notifications
```http
GET   /notifications
PATCH /notifications/:id/read
```

## Security
Protected endpoints require authentication and authorization. Validate ownership for user resources.

## Validation / Rate Limits
Validate IDs, fields, coordinates, pagination, file metadata and body sizes. Rate-limit login, registration, password reset, upload and analysis creation.

## Versioning
Breaking changes require a versioning strategy. Do not silently change production response contracts.

Any API change must update `api.md`, client models, tests and relevant architecture documentation.
