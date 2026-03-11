---
name: api-design-rest
description: Design RESTful APIs with correct HTTP semantics, DTOs, pagination, and error handling. Use when building or reviewing REST APIs in any stack (Spring, Node, Go, etc.).
tags: api, rest, http, endpoints
---

# REST API Design

## HTTP Semantics

- Use correct methods: GET (read, idempotent), POST (create), PUT/PATCH (update), DELETE (remove)
- Return proper status codes: 200 OK, 201 Created, 204 No Content, 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 409 Conflict, 422 Unprocessable Entity, 500 Internal Server Error
- Prefer plural resource names: `/users`, `/orders`
- Nest resources when appropriate: `/users/{id}/orders`

## Versioning
- Use path prefix: `/api/v1/...` or header: `Accept: application/vnd.api+json;version=1`

## Request/Response

- Use DTOs or schemas; never expose internal entities directly
- Validate all input using the framework's validation mechanism
- Support `Accept` and `Content-Type` headers

## Collections

- Paginate large lists: `page`, `size` or `limit`, `offset`
- Support sorting and filtering via query params
- Return total count when useful

## Errors

- Global exception handler for consistent error format
- Include error code, message, and optional details
- Log server-side; return safe messages to client