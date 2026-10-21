# Europa Clean API

## Authentication

All successful sign-ins return an application JWT in the `Authorization`
response header as `Bearer <token>`.

Email and password:

```http
POST /api/auth/sign_in
Content-Type: application/json

{"user":{"email":"person@example.com","password":"password123"}}
```

Google Identity:

```http
POST /api/auth/google
Content-Type: application/json

{"google":{"id_token":"<Google Identity ID token>"}}
```

Set `GOOGLE_CLIENT_IDS` to the comma-separated Google OAuth client IDs allowed
to authenticate (for example, web and mobile client IDs). The API verifies the
token's signature, issuer, expiry, audience, and verified email before issuing
its own JWT.

Sign out and revoke the current application JWT:

```http
DELETE /api/auth/sign_out
Authorization: Bearer <token>
```
