# AI GUIDELINES FOR RAILS CORE BUILDING (BACKEND)

## I. CORE RESPONSIBILITY

*   Your primary goal is to create and modify the backend components: Models, Controllers, basic Views (un-styled), Routes, Migrations, Helpers (for business logic), POROs, Background Jobs, and Tests.
*   You MUST NOT implement UI styling (Tailwind/DaisyUI) or Hotwire interactivity (Turbo/Stimulus). Focus on functionality and structure.
*   Follow all instructions precisely and adhere strictly to these guidelines.

## II. GENERAL CODING & SYNTAX

*   **Ruby Version:** Use Ruby 3.3+ features where appropriate.
*   **Embrace Ruby & OOP:** Write idiomatic Ruby; use object-oriented principles.
*   **KISS (Keep It Simple, Stupid):** Favor the simplest solution that meets requirements.
*   **Single Responsibility Principle:** Each class and method should have one clear responsibility and perform it well. Break down complex tasks into smaller, focused methods.
*   **Naming Conventions:** `snake_case` for files, methods, variables; `CamelCase` for classes/modules. Follow Rails conventions.
*   **Formatting:** Adhere to RuboCop (Rails 8 Omakase + StandardRB) standards. Use `bin/rubocop` to check.
*   **Syntax:** Use expressive Ruby syntax (`unless`, `||=`, `&.`, guard clauses).

## III. DIRECTORY STRUCTURE & FILE PLACEMENT

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

### C. Important Files Reference
*   `config/routes.rb`: Defines application routes and resources.
*   `db/schema.rb`: Authoritative source for the current database schema (generated from migrations).

## IV. ROUTING (`config/routes.rb`)


*   **Prioritize Resourceful Routing:** Use `resources` (for collections) and `resource` (for singletons) to define routes corresponding to standard RESTful controller actions.
*   **Use Nested Routes for Relationships:** Define nested routes using `resources` blocks to represent parent-child relationships (e.g., posts and comments).
*   **Use Shallow Nesting for Deeper Relationships:** If nesting more than one level deep, use the `shallow: true` option on the parent or nested resource. This simplifies URLs and helper paths for member actions (`show`, `edit`, `update`, `destroy`).
*   **Use Namespaces for Grouping:** Group related controllers (e.g., for an admin section) under a common module and URL prefix using `namespace`.
*   **Avoid Custom Actions, Prefer New Controllers:** Instead of adding non-RESTful custom actions to existing controllers, create a new, dedicated controller. For example, for a "publish" action on posts, create a `PublishedPostsController` with a `create` action (`POST /posts/:post_id/published_posts`). The new controller should use a RESTful action that best represents the intent.

## V. CONTROLLERS (`app/controllers/`)

*   **Keep Controllers RESTful:** Primarily use the standard RESTful actions: `index`, `show`, `new`, `create`, `edit`, `update`, `destroy`.
*   **Ensure Controllers Remain Skinny:** Controllers must be lean. Their primary responsibilities are limited to:
    1.  Authenticating and authorizing the user.
    2.  Loading required records using model scopes or finders (often in `before_action`).
    3.  Calling a single primary method on a model, PORO, or Concern to execute business logic.
    4.  Handling parameters using Strong Parameters.
    5.  Rendering a view/template or performing a redirect.
*   **Strictly Avoid Business Logic:** Do not place business logic directly within controller actions. Delegate this logic to models, concerns, or POROs.
*   **Invoke One Core Business Logic Method Per Action:** Ideally, each controller action (beyond standard finders like `set_resource`) should invoke only *one* primary method responsible for the core business logic of that action.
*   **Minimize Instance Variables:** Pass only the necessary instance variables (`@variable`) from the controller to the view. Avoid passing excessive data; rely on models and helpers for view logic.
*   **Define Filters Within Controller Scope:** When using `only:` or `except:` options in action filters (`before_action`, etc.), ensure the specified actions are defined within the same controller class (or its direct parent). Avoid applying filters to inherited actions in a way that obscures their scope.
*   **Prefer Templates Over Inline Rendering:** Always use separate view template files (`.html.erb`, `.turbo_stream.erb`, etc.) located in `app/views/`. Do not use `render inline:`.
*   **Use Symbolic HTTP Status Codes:** When specifying HTTP status codes in `render` or `redirect_to`, use the symbolic representation (e.g., `:ok`, `:created`, `:unprocessable_entity`, `:not_found`, `:forbidden`) instead of numeric codes (e.g., `200`, `201`, `422`, `404`, `403`) for better readability.
*   **Implement Strong Parameters:** Always use strong parameters to whitelist permitted attributes from the `params` hash. Example: `def product_params; params.require(:product).permit(:name, :description); end`

## VI. MODELS (`app/models/`) - ActiveRecord & POROs

### A. Organization & Logic Placement
*   **Leverage POROs and Concerns:** Organize model code effectively. Extract common, reusable logic into Concerns (`app/models/concerns/`). Encapsulate larger pieces of business logic or domain concepts into Plain Old Ruby Objects (POROs) placed directly in `app/models/`.
*   **Non-ActiveRecord Models (POROs):** For objects representing domain concepts without direct database persistence but requiring features like validations or type casting, include `ActiveModel::Model` and optionally `ActiveModel::Attributes`. Place these POROs in `app/models/`.
*   **Business Logic Focus:** Keep model code focused on business logic (rules, calculations, state changes) and data persistence concerns (associations, scopes, validations).
*   **Delegate Presentation Logic:** Avoid putting presentation logic (HTML generation, complex formatting for views) in models. Use helpers for this.
*   **ActiveRecord Model Structure:** Follow this general order within ActiveRecord model files for consistency:
    1.  `default_scope` (use sparingly)
    2.  Constants
    3.  `attr_accessor`, `attr_reader`, `attr_writer` (if needed)
    4.  `enum` definitions
    5.  Association macros (`belongs_to`, `has_many`, `has_one`, `has_and_belongs_to_many` - prefer `has_many :through`)
    6.  `accepts_nested_attributes_for`
    7.  Validation macros (`validates`, `validate`)
    8.  Callback macros (`before_validation`, `after_save`, etc. - use sparingly)
    9.  Other macros (e.g., Devise, FriendlyId if used)
    10. Class methods (including scopes defined as class methods)
    11. Public instance methods
    12. Protected instance methods
    13. Private instance methods

### B. ActiveRecord Conventions & Defaults
*   **Keep Defaults:** Do not override standard ActiveRecord conventions (table names, primary keys, inheritance column) unless there's a very strong reason.
*   **Enums:** Define enums for status fields or similar fixed sets of values: `enum :status, [:shipped, :being_packed, :complete, :cancelled]`

### C. Associations
*   **Prefer `has_many :through`:** Use `has_many :through` instead of `has_and_belongs_to_many` for many-to-many relationships. This allows adding attributes and validations to the join model.
*   **Specify `dependent:` Option:** Always specify the `dependent:` option (`:destroy`, `:delete_all`, `:nullify`, `:restrict_with_error`, `:restrict_with_exception`) for `has_many` and `has_one` associations to explicitly manage associated records upon deletion of the owner.

### D. Validations
*   **Primary Location:** Most data validation logic should reside in the ActiveRecord model (`app/models/*.rb`).
*   **Database Constraints:** Enforce simple, fundamental constraints like `NOT NULL` and `UNIQUE` indexes at the database level via migrations.
*   **ActiveRecord Validations:** Use ActiveRecord validations for user feedback, complex business rules, and application-level checks. They often mirror database constraints but provide richer feedback.
*   **Use Hash-Based Syntax:** Always use the hash-based syntax for standard validation helpers: `validates :email, presence: true, length: { maximum: 100 }`
*   **One Rule Per Line:** Define one validation rule per line for better readability.
*   **Custom Validation Methods:** Create custom validation methods using `validate :method_name`. Name these methods clearly to indicate what they check (e.g., `validate :expiration_date_cannot_be_in_the_past`).
    ```ruby
    # Good: Clearly named custom validation method
    validate :end_date_must_be_after_start_date

    def end_date_must_be_after_start_date
      return if end_date.blank? || start_date.blank?
      errors.add(:end_date, "must be after the start date") if end_date < start_date
    end
    ```
*   **Avoid Skipping Validations:** Avoid methods like `update_column`, `update_columns`, `toggle!`, `increment!`, `decrement!`, `update_all`, `touch` when business rules/callbacks need to run. These methods bypass validations and callbacks, potentially leading to inconsistent data. Prefer standard methods like `update`, `save`, etc.

### E. Callbacks
*   **Use Callbacks Cautiously:** Be mindful when using callbacks (`before_save`, `after_commit`, etc.) as they can make control flow less explicit and harder to debug. Prefer calling methods explicitly from controllers or POROs/Concerns when logic is tied to specific user actions rather than the inherent model lifecycle.
*   **Declare in Execution Order:** List callback declarations in the order they are intended to execute (e.g., `before_validation` before `before_save`).
*   **`before_destroy` Prepending:** Use `prepend: true` for `before_destroy` callbacks that perform validations or checks which *must* run *before* any `dependent:` options trigger the deletion of associated records.

### F. Scopes & Class Methods
*   **Use `scope` for Simple Queries:** Define simple, chainable query logic using the `scope` macro.
*   **Use Class Methods for Complex Queries:** For more complex query logic that might not be easily chainable or involves significant logic, prefer defining a class method that returns an `ActiveRecord::Relation` object instead of creating an overly complex `scope` lambda.

### G. Querying (ActiveRecord Query Interface)
*   **Use Bang Methods or Check Return Values:** Always use bang methods (`create!`, `save!`, `update!`, `destroy!`) which raise exceptions on failure, OR explicitly check the boolean return value of the non-bang equivalents (`create`, `save`, `update`, `destroy`) to handle potential failures gracefully.
*   **Prevent SQL Injection:** *Never* use raw string interpolation for user-provided values in database queries. Always use placeholders (`?` or named `:placeholders`) or hash conditions to safely construct queries. Example: `Client.where(country_code: params[:country], status: 'active')`
*   **Finding Single Records:**
    *   Use `find(id)` to find by primary key (raises `ActiveRecord::RecordNotFound` if not found).
    *   Use `find_by(attribute: value)` to find the first record matching attributes (returns `nil` if not found).
    *   Use `find_by!(attribute: value)` to find the first record matching attributes (raises `ActiveRecord::RecordNotFound` if not found).
*   **Hash Conditions:** Prefer hash syntax (`where(name: 'Alice')`, `where.not(status: 'archived')`) for simple equality and inequality conditions.
*   **`where.missing`:** Use `where.missing(:association)` (Rails 6.1+) to find records that do not have a specific association.
*   **Ordering:** Do *not* rely on ordering by `id` for chronological purposes. Use timestamp columns (`created_at`, `updated_at`) or other meaningful attributes explicitly.
*   **Selecting Specific Data:**
    *   Use `pluck(:column_name)` to retrieve an array of values for a single column directly from the database.
    *   Use `pick(:column_name)` to retrieve a single value from the first matching record.
    *   Prefer `ids` over `pluck(:id)` for retrieving just the primary keys.
*   **Complex SQL (Rare Cases):** If ActiveRecord methods are insufficient (which should be rare), use squished heredocs (`<<-SQL.squish`) for readability when writing raw SQL with `find_by_sql` or similar methods.
*   **Counting Records:** Prefer `size` on relations. It intelligently uses `count` (database query) if the relation isn't loaded, or `length` (in-memory count) if the relation's records are already loaded. Use `count` directly only if you specifically need the database count without loading records. Use `length` only if you intend to load the entire collection anyway.
*   **Ranges in `where`:** Use Ruby ranges for database comparisons (`start..end`, `start...end`, `start..`, `..end`, `...end`).
*   **`where.not` with Multiple Attributes:** Avoid hash syntax for `where.not` with multiple attributes like `where.not(status: 'active', plan: 'basic')` as it generates `NOT (status = 'active' AND plan = 'basic')`. For `OR` logic within the `NOT`, use SQL strings: `where.not('status = ? OR plan = ?', 'active', 'basic')`. For `AND` logic (i.e., `NOT status = 'active' AND NOT plan = 'basic'`), chain `where.not` calls: `where.not(status: 'active').where.not(plan: 'basic')`.
*   **Avoid Redundant `all`:** Do not chain query methods after `Model.all`. Apply scopes and query methods directly to the model class or an existing relation (e.g., `User.order(:name)` instead of `User.all.order(:name)`). Be aware of subtle differences, e.g., `user.posts.delete_all` (uses association) vs. `Post.where(user: user).delete_all` (uses relation).
*   **Iterating Over Large Datasets:** Use `find_each` (for record-by-record processing) or `in_batches` (for processing groups/batches of records) when iterating over a large number of records to reduce memory consumption.

### H. User-Friendly URLs
*   Implement user-friendly URLs using descriptive attributes instead of just IDs.
    *   **Option 1: `to_param` (Simple Cases):** Override the `to_param` method in the model. Ensure your controller's finder method can correctly extract the ID if needed.
        ```ruby
        # Good: Overriding to_param
        class Post < ApplicationRecord
          def to_param
            "#{id}-#{title.parameterize}"
          end
        end
        # In controller: Post.find(params[:id].split('-').first)
        ```
    *   **Option 2: `friendly_id` Gem (Robust):** Use the `friendly_id` gem for more advanced slug generation, history tracking, etc. (Note: This adds a dependency, weigh against the "Minimize Dependencies" principle, but it's a common and reliable choice if complex slugging is needed).
        ```ruby
        # Good: Using friendly_id gem (if added as a dependency)
        class Post < ApplicationRecord
          extend FriendlyId
          friendly_id :title, use: :slugged # Requires migration for slug column
        end
        # In controller: Post.friendly.find(params[:id])
        ```

## VII. VIEWS (`app/views/`) & HELPERS (`app/helpers/`) - Backend Focus

### A. General View Principles
*   **Standard View Files:** Primarily create view templates for the standard RESTful actions: `index.html.erb`, `show.html.erb`, `new.html.erb`, and `edit.html.erb`.
    *   The `create` action typically renders the `new` template on validation failure or redirects/renders Turbo Stream on success.
    *   The `update` action typically renders the `edit` template on validation failure or redirects/renders Turbo Stream on success.
    *   The `destroy` action typically redirects or renders a Turbo Stream response.
*   **Keep Views Logic-Free & Simple:** Avoid complex data manipulation, calculations, or heavy formatting logic directly within view templates (`.erb` files). Views should focus on presentation.

### B. Partials (`app/views/shared/`, `app/views/{resource}/_*.html.erb`)
*   **Use Partials for DRY Views:** Utilize Rails partials (`_partial_name.html.erb`) extensively to simplify views and reuse common UI components.
*   **Form Partials:** Use partials for forms, especially for `new` and `edit` actions, to keep the form structure consistent (e.g., `_form.html.erb`).
*   **Organize Shared Partials:** Place partials used across multiple resource types in `app/views/shared/`.
*   **Pass Local Variables to Partials:** *Always* pass data into partials explicitly using local variables (`render 'partial', locals: { key: value }` or the shorthand `render 'partial', key: value`). Do *not* rely on instance variables (`@variable`) being implicitly available within partials, as this makes them less reusable and harder to understand.

### C. Helpers (`app/helpers/`)
*   **Use Built-In View Helpers:** Leverage Rails' extensive set of built-in view helpers for common tasks like generating links (`link_to`), buttons (`button_to`), formatting numbers/dates (`number_to_currency`, `time_ago_in_words`), handling assets (`image_tag`), sanitization, etc.
*   **Create Custom Helpers for Presentation Logic:** For more complex presentation logic specific to a view or resource, create dedicated helper methods in the corresponding helper file (e.g., `app/helpers/articles_helper.rb` for `ArticlesController` views).
*   **Resource-Specific Helpers:** Each resource typically has its own helper module (e.g., `PostsHelper` for `posts` views).
*   **Application-Wide Helpers:** Place helper methods shared across multiple parts of the application in `app/helpers/application_helper.rb`.

### D. Forms (`form_with`)
*   **Use `form_with` Exclusively:** Always use the `form_with` helper to generate `<form>` tags. Avoid the older `form_tag` and `form_for` helpers.
*   **Utilize the Form Builder Object:** Always use the form builder object yielded by `form_with` (e.g., `|form|`) to generate form controls (`form.text_field`, `form.label`, `form.select`, `form.submit`, etc.). This ensures correct input naming (`model[attribute]`) and integration with model state and validation errors.
*   **`form_with model:` for Resourceful Forms:** For forms corresponding to a model object (new/create, edit/update), use `form_with model: @object`. Rails' record identification will automatically set the correct URL and HTTP method (`POST` for new records, `PATCH` for existing ones).
*   **Custom URLs/Methods:** Forms can be pointed to custom URLs or use different methods if necessary: `form_with(url: search_path, method: "get")` or `<%= form_with url: "/posts/1/publish", method: :post do |form| %>`.
*   **Leverage Form Helpers:** Use the appropriate form builder helpers for different input types: `form.text_field`, `form.date_field`, `form.time_field`, `form.password_field`, `form.email_field`, `form.url_field`, `form.hidden_field`, `form.number_field`, `form.search_field`, `form.text_area`, etc.
*   **Collection Helpers:** For select dropdowns, radio buttons, or checkboxes based on a collection of objects (e.g., from an ActiveRecord query or an array), use the collection helpers: `form.collection_select`, `form.collection_radio_buttons`, `form.collection_checkboxes`. Specify the `value_method` and `text_method` appropriately.
    *   Example: `<%= form.collection_select :city_id, City.all, :id, :name, { prompt: 'Select a City' }, { class: 'select select-bordered' } %>`
*   **Select Fields:** Create basic select fields:
    *   Simple array: `<%= form.select :city, ["Berlin", "Chicago", "Madrid"] %>`
    *   With distinct values: `<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]] %>`
    *   With a pre-selected value: `<%= form.select :city, [...], selected: "CHI" %>`
*   **Prioritize Accessibility with Labels:** *Every* form input must have an associated `<label>`. Use the `form.label` helper to generate labels linked correctly via the `for` attribute.
    *   Label syntax example: `<%= form.label :flavor_chocolate_chip, "Chocolate Chip" %>` (assuming the input ID is `model_flavor_chocolate_chip`).
*   **Apply Styling via Helper Options:** Apply TailwindCSS utilities and DaisyUI component classes using the `class:` option within the form builder helpers (e.g., `form.text_field :name, class: 'input input-bordered w-full'`). Do not write separate CSS rules specifically for basic form styling.
*   **Use `fields_for` for Nested Attributes:** For editing associated records within a parent form (e.g., multiple addresses for a person), use `form.fields_for :association_name` in conjunction with `accepts_nested_attributes_for :association_name` configured in the parent model. Ensure nested parameters are permitted correctly in the controller's strong parameters. Handling the dynamic addition/removal of nested fields often requires Stimulus if doing it without full page reloads.


## VIII. DATABASE & MIGRATIONS (`db/migrate/`)


*   **Use PostgreSQL:** Leverage PostgreSQL as the application database.
*   **Use UUID Primary Keys:** Use UUIDs as the primary key type for database tables. (`id: :uuid` in migrations).
*   **Define Defaults in Migrations:** Set default values for columns directly within the migration using the `default:` option. Do not rely solely on application-level logic (e.g., model callbacks) to enforce database defaults.
*   **Boolean Columns:** Always define boolean columns with a non-null constraint and an explicit default value (`default: true` or `default: false`) to avoid three-valued logic issues (`true`, `false`, `NULL`). Example: `t.boolean :is_active, null: false, default: false`
*   **Foreign Key Constraints:** Always add foreign key constraints at the database level using the `foreign_key: true` option in `add_reference` or by explicitly using `add_foreign_key`. This enforces referential integrity.
*   **Prefer `change` Method:** Use the `change` method for migrations that perform operations ActiveRecord knows how to reverse automatically (e.g., `create_table`, `add_column`, `add_index`, `rename_column`). Use explicit `up` and `down` methods only when `change` is insufficient.
*   **Avoid Model Usage in Migrations (Data Migrations):** Do *not* directly reference your application's ActiveRecord models (`app/models/*`) within migration files. Model logic can change over time, breaking older migrations. If data manipulation is needed, define a temporary plain Ruby class within the migration or use SQL.
*   **Use Generators for Modifications:** Use `bin/rails generate migration AddDetailsToProducts ...` or `RemoveFieldFromUsers ...` only to create migrations for adding/removing/modifying existing columns or adding associations/indexes between tables.

## IX. BACKGROUND JOBS (`app/jobs/`)

*   **Use ActiveJob:** Define background jobs using Rails' ActiveJob framework.
*   **Use Solid Queue:** Utilize Solid Queue as the ActiveJob backend for running asynchronous tasks. It's part of the Rails 8 "Solid" stack and uses the database, avoiding external dependencies like Redis for basic job queuing.

## X. TESTING (`test/`)

*   **Use Minitest:** Employ Minitest, Rails' default testing framework.
*   **Minimalist Approach:** Focus testing efforts on critical code paths that significantly increase confidence in the application's correctness. Avoid testing trivial code or Rails internals.
*   **Use Fixtures:** Utilize fixtures for setting up test data in a simple and repeatable way.
*   **Prohibited:** No RSpec.

## XI. PERFORMANCE & SECURITY (Implementation)

*   **Database Indexing:** Use database indexes effectively on columns frequently used in `WHERE` clauses, `JOIN` conditions, or `ORDER BY` clauses.
*   **Caching:** Implement caching strategies where appropriate (e.g., fragment caching, Russian Doll caching) to reduce database load and improve response times. Use Solid Cache (part of the Rails 8 "Solid" stack) as the cache store.
*   **Eager Loading (N+1 Prevention):** Use eager loading (`includes`, `preload`, `eager_load`) in controllers or scopes to avoid N+1 query problems when accessing associated records.
*   **Optimize Database Queries:** Select only necessary columns (`select`), use appropriate join methods (`joins`, `left_outer_joins`), and ensure queries are efficient.
*   **Strong Parameters:** Always use strong parameters in controllers to prevent mass assignment vulnerabilities.
*   **SQL Injection Prevention:** Consistently use safe query construction methods (placeholders, hash conditions) as detailed in the Models/Querying section.
*   **Run Brakeman:** Periodically run `bin/brakeman` to perform static analysis security vulnerability scanning.

## XII. TOOLING & DEPENDENCIES

*   **Generators:** Use `bin/rails g model`, `bin/rails g controller`, etc.
*   **Runner:** Use `bin/rails runner` for scripts.
*   **Routes:** Check with `bin/rails routes`.
*   **RuboCop:** Run `bin/rubocop`.
*   **Brakeman:** Run `bin/brakeman`.
*   **Devise:** Implement authentication using Devise helpers/modules according to its documentation.
*   **Active Storage/Text:** Set up model associations (`has_one_attached`, `has_rich_text`).
*   **Prohibited:** No external form gems. No RSpec. No `tmp/restart.txt`. Avoid `credentials:edit`.