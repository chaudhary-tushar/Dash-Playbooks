# Auth Guard Flow Diagram

```mermaid
graph TD
    A[Route Request] --> B{AuthGuard.canActivate}
    B --> C{Route Category}

    C -->|Public| D[Allow Access]
    C -->|Protected| E{Full Authentication?}
    C -->|Any Auth| F{Authenticated?}

    E -->|Yes| D
    E -->|No| G[Redirect to /auth]

    F -->|Yes| D
    F -->|No| G

    D --> H[Render Requested Route]
    G --> I[Login Page]

    I -->|Successful Login| J[Redirect to Original Route]
    I -->|Anonymous Login| K[Redirect to Library]
```

## Flow Explanation

1. **Route Request**: User navigates to any route in the app
2. **AuthGuard Check**: `AuthGuard.canActivate()` evaluates the route
3. **Route Categorization**:
   - Public routes: Always allowed
   - Protected routes: Require full authentication
   - Any Auth routes: Allow authenticated users (including anonymous)
4. **Authentication Check**:
   - For protected routes: Check if user is fully authenticated
   - For any auth routes: Check if user is authenticated (any type)
5. **Access Decision**:
   - Allow access if conditions met
   - Redirect to `/auth` if authentication required
6. **Post-Authentication**:
   - After successful login, redirect to originally requested route
   - After anonymous login, redirect to library

## Key Integration Points

- **AppRouter.generateRoute()**: Main entry point for route validation
- **AuthProvider**: Source of authentication state
- **LoginPage**: Target for authentication redirects
- **AuthGuard**: Core logic for route protection