## I. CORE PHILOSOPHY & PRINCIPLES

*   **Project Understanding:** Always start by reading and understanding the project brief/requirements.
*   **Monolithic Architecture:** Design and build a full-stack, server-rendered monolithic Rails application. **Prohibited:** Do not design or build separate JSON APIs for consumption by external frontend frameworks (React, Vue, etc.).
*   **Rails MVC:** Strictly adhere to the Model-View-Controller pattern.
*   **Vanilla Rails Focus:** Minimize external dependencies. Leverage Rails' built-in features (ActiveRecord, ActionPack, ActiveJob, ActiveStorage, ActionText, Hotwire, Solid Stack) extensively before adding gems.
*   **KISS (Keep It Simple, Stupid):** Favor the simplest solution that meets requirements.
*   **YAGNI (You Ain't Gonna Need It):** Avoid implementing features not currently required.
*   **Single Responsibility Principle (SRP):** Design classes and methods with a single, well-defined purpose.
*   **Convention Over Configuration:** Follow Rails conventions for naming, structure, and common patterns.
*   **Embrace Ruby & OOP:** Utilize Ruby idioms and object-oriented principles.

## III. TECHNOLOGY STACK CHOICES

*   Use the following tech stack and stick to them
*   **Ruby Version:** 3.3+
*   **Rails Version:** 8+ (Implied by Solid Stack)
*   **Database:** PostgreSQL (with UUID primary keys)
*   **Background Jobs:** ActiveJob with Solid Queue backend.
*   **Caching:** ActiveSupport Caching with Solid Cache backend.
*   **WebSockets:** Action Cable with Solid Cable backend (if real-time features are needed).
*   **Authentication:** Devise gem.
*   **File Uploads:** Active Storage.
*   **Rich Text:** Action Text.
*   **Asset Pipeline:** Propshaft.
*   **JavaScript Management:** Import Maps.
*   **Frontend Framework:** Hotwire (Turbo + Stimulus).
*   **CSS Framework:** TailwindCSS v4 (utility-first).
*   **UI Component Library:** DaisyUI v5 (on top of Tailwind).
*   **Testing Framework:** Minitest (with Fixtures).
*   **Linting/Formatting:** RuboCop (Rails 8 Omakase + StandardRB config).
*   **Security Scanning:** Brakeman.
*   **Icons:** `rails_icons` gem (Heroicons).
*   **Prohibited:** RSpec, SimpleForm, Formtastic, Webpacker, esbuild (unless absolutely necessary), Redis (use Solid Stack), alternative frontend frameworks (React, Vue, etc.).

## IV. KEY ARCHITECTURAL PATTERNS

* Each architecture descions you make need to be based on the following patterns:
*   **Skinny Controllers:** Controllers handle request/response flow, authentication, authorization, parameter handling, and delegating business logic. They do *not* contain business logic itself.
*   **Fat Models / Concerns / POROs:** Business logic resides primarily in Models, extracted into Concerns (`app/models/concerns/`) for reusability, or into Plain Old Ruby Objects (POROs in `app/models/`) for complex domain concepts or service-like operations.
*   **Resourceful Routing:** Use `resources`, `resource`, nesting (`shallow: true`), and `namespace` for clear, conventional routes. Avoid custom controller actions where a new resource/controller makes sense.
*   **Logic-Free Views:** Views focus on presentation (HTML structure, CSS classes, basic ERB). Delegate presentation logic to Helpers (`app/helpers/`).
*   **Server-Rendered HTML:** Generate HTML primarily on the server via ERB. Use Hotwire for dynamic updates, not client-side rendering of core content.
*   **Utility-First CSS:** Style elements directly in HTML using Tailwind classes. Avoid writing separate CSS files.
*   **Progressive Enhancement (Hotwire):** Build functional HTML first, then layer Turbo/Stimulus for better UX.
*   **Performance:** Prioritize eager loading (N+1 prevention), database indexing, and consider caching strategies (Fragment, Russian Doll) using Solid Cache.
*   **Security:** Enforce Strong Parameters, prevent SQL injection, run Brakeman.

## V. DIRECTORY STRUCTURE OVERVIEW

*   **Adhere to Structure:** Organize files according to Rails conventions.
*   **Standard Directory Layout:**
    ```
    /app
    └── assets/
    ├── controllers/      # Rails Controllers
    ├── javascript/       # Stimulus controllers
    │   └── controllers/
    ├── jobs/             # Solid Queue Background jobs (ActiveJob)
    ├── mailers/          # Action Mailer classes
    ├── models/           # Active Record models & ActiveModel::Models
    │   └── concerns/     # Model concerns
    ├── views/            # View templates & partials
    │   └── shared/       # Shared partials
    ├── helpers/          # View helpers
    /config               # Configuration, initializers, environments, routing
    /db
    ├── migrate/          # Database migrations
    /test                 # Minitest tests
    ```

### Important Files Reference
*   `config/routes.rb`: Defines application routes and resources.
*   `db/schema.rb`: Authoritative source for the current database schema (generated from migrations).

## VI. PROHIBITED ARCHITECTURAL DECISIONS

*   Do not build JSON APIs for separate frontends.
*   Do not introduce alternative frontend frameworks or build tools.
*   Do not deviate from the specified core technology stack (Solid Stack, Postgres, Hotwire, Tailwind, Devise, Minitest).
*   Do not use legacy routing (`match`).