# DermaScan AI — Database Specification

## Database
Recommended primary database:
```text
PostgreSQL
```
Use controlled migrations for schema changes.

## Core Entities
```text
users
profiles
analyses
analysis_alternatives
notifications
```

Future entities such as doctors, providers, appointments and consultations should not be added to the MVP without a product requirement.

## Users
```text
id
email
password_hash
status
email_verified
created_at
updated_at
```

Rules: unique email, secure password hashing, appropriate indexes, no plaintext passwords.

## Profiles
```text
id
user_id
display_name
phone
profile_image_url
date_of_birth
location
language
created_at
updated_at
```

## Analyses
```text
id
user_id
image_object_key
status
prediction
confidence
model_version
created_at
updated_at
```

Recommended index:
```text
(user_id, created_at)
```

## Analysis Alternatives
```text
id
analysis_id
condition
confidence
```

## Notifications
```text
id
user_id
title
message
type
is_read
created_at
```

Recommended index:
```text
(user_id, is_read, created_at)
```

## Relationships
```text
User
 ├── Profile
 ├── Analyses
 │     └── Analysis Alternatives
 └── Notifications
```

## Images
Store image binaries in private object storage. Store object keys/metadata in PostgreSQL.

## Privacy
Collect only required data. Support analysis deletion, account deletion and appropriate retention policies. Define cascading behavior intentionally.

## Audit
If admins access sensitive resources, introduce an audit mechanism:
```text
actor_user_id
action
resource_type
resource_id
created_at
metadata
```

Do not put sensitive payloads unnecessarily in logs.

## Migrations
```text
Change schema → Create migration → Test → Review → Staging → Production
```

## Backups
Production requires automated backups, appropriate retention and tested restores.

## Security
Restrict network access, use strong credentials, encrypted connections where appropriate, least privilege and never expose the database directly to mobile clients.
