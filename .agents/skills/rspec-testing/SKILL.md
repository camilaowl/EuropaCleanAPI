---
name: rspec-testing
description: Write, review, debug, and improve Ruby on Rails tests with RSpec, FactoryBot, Capybara, WebMock, and VCR. Use when adding test coverage, fixing failing specs, designing Rails test boundaries, or improving test speed and reliability.
---

# Testing — Ruby on Rails

You are an expert in testing Ruby on Rails applications using RSpec and supporting libraries like FactoryBot, Capybara, and VCR.

## Overview

Effective RSpec testing combines unit tests (models and services), integration tests (requests), and system tests (browser-driven) to build confidence without excessive test suites.

## Core Philosophy

Tests exist to give you confidence to change code. A test suite that is slow, brittle, or tightly coupled to implementation details achieves the opposite — it makes developers afraid to refactor because every change breaks dozens of specs. The best Rails test suites are fast, focused on behavior, and structured as a pyramid: many unit tests, fewer integration tests, and a small number of system tests for critical user flows.

Test what your code does, not how it does it. Assert on return values, side effects, and observable behavior rather than on which internal methods were called or in what order. This distinction matters because implementation-focused tests break every time you refactor, even when the behavior is unchanged. Behavior-focused tests break only when you actually introduce a bug.

Speed is a feature of your test suite. Every second added to the feedback loop reduces how often developers run tests, which reduces confidence, which reduces code quality. Prefer `build` and `build_stubbed` over `create`, run tests in parallel, minimize system tests, and audit factory chains that create unnecessary associated records. A fast test suite is one that developers actually use.

## Anti-Patterns

- **The Integration-Only Suite**: Writing request specs or system tests for everything, including pure logic that could be tested at the unit level. Integration tests are slow and provide broad coverage. Unit tests are fast and provide precise feedback. You need both, but the ratio should heavily favor unit tests.

- **Factory Cascade Blindness**: Calling `create(:post)` without realizing it also creates a user, an organization, a subscription, and three associated records behind the scenes. Audit your factories to understand their dependency chains and use `build_stubbed` whenever persistence is not required.

- **Sleep-Based Synchronization**: Adding `sleep 2` in system tests to wait for asynchronous operations instead of using Capybara's built-in waiting matchers like `have_text` or `have_selector`. Sleep-based waits are both slow (they always wait the full duration) and flaky (they sometimes do not wait long enough).

- **Testing Framework Behavior**: Writing specs that validate `validates_presence_of` actually works, or that `has_many` creates the right SQL. These are tests of Rails itself, not of your application. Focus tests on your custom business rules, edge cases, and integration points.

- **Shared Mutable State**: Writing tests that depend on records created by other tests, or on a specific test execution order. Every test should set up its own state in `before`/`setup` blocks and leave no trace when it finishes.

## Core Concepts

### RSpec Setup

```ruby
# Gemfile
group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
end

group :test do
  gem "shoulda-matchers"
  gem "capybara"
  gem "selenium-webdriver"
  gem "webmock"
  gem "vcr"
  gem "simplecov", require: false
end
```

```ruby
# spec/rails_helper.rb
require "spec_helper"
require "rspec/rails"

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end

# spec/support/shoulda_matchers.rb
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
```

## Implementation Patterns

### Model Specs (RSpec)

```ruby
# spec/models/user_spec.rb
RSpec.describe User, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_length_of(:username).is_at_least(3) }
  end

  describe "associations" do
    it { is_expected.to have_many(:posts).dependent(:destroy) }
    it { is_expected.to have_one(:profile).dependent(:destroy) }
    it { is_expected.to belong_to(:organization).optional }
  end

  describe "#full_name" do
    it "combines first and last name" do
      user = build(:user, first_name: "Jane", last_name: "Doe")
      expect(user.full_name).to eq("Jane Doe")
    end
  end

  describe "#active?" do
    context "when the subscription is current" do
      it "returns true" do
        user = build(:user, subscription_expires_at: 1.month.from_now)
        expect(user).to be_active
      end
    end

    context "when the subscription has expired" do
      it "returns false" do
        user = build(:user, subscription_expires_at: 1.day.ago)
        expect(user).not_to be_active
      end
    end
  end
end
```

### Request Specs (RSpec)

```ruby
# spec/requests/posts_spec.rb
RSpec.describe "Posts", type: :request do
  let(:user) { create(:user) }
  let(:valid_attrs) { { title: "Test Post", body: "Content here" } }

  before { sign_in user }

  describe "GET /posts" do
    it "returns a successful response" do
      create_list(:post, 3, user: user)
      get posts_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /posts" do
    context "with valid parameters" do
      it "creates a new post and redirects" do
        expect {
          post posts_path, params: { post: valid_attrs }
        }.to change(Post, :count).by(1)

        expect(response).to redirect_to(Post.last)
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity" do
        post posts_path, params: { post: { title: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /posts/:id (JSON)" do
    it "returns the post as JSON" do
      post_record = create(:post, user: user)
      get post_path(post_record), as: :json

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json["title"]).to eq(post_record.title)
    end
  end
end
```

### System Tests (Browser Tests)

```ruby
# spec/system/user_registration_spec.rb
RSpec.describe "User Registration", type: :system do
  before { driven_by(:selenium_chrome_headless) }

  it "allows a new user to register" do
    visit new_user_registration_path

    fill_in "Email", with: "new@example.com"
    fill_in "Password", with: "securepassword123"
    fill_in "Password confirmation", with: "securepassword123"
    click_button "Sign up"

    expect(page).to have_text("Welcome! You have signed up successfully.")
    expect(User.find_by(email: "new@example.com")).to be_present
  end

  it "shows inline validation errors" do
    visit new_user_registration_path
    click_button "Sign up"

    expect(page).to have_text("Email can't be blank")
  end
end
```

### Factories (FactoryBot)

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    username { Faker::Internet.username(specifier: 5..20) }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    password { "password123" }

    trait :admin do
      role { :admin }
    end

    trait :with_posts do
      transient do
        posts_count { 3 }
      end

      after(:create) do |user, ctx|
        create_list(:post, ctx.posts_count, user: user)
      end
    end

    trait :expired do
      subscription_expires_at { 1.day.ago }
    end

    factory :admin_user, traits: [:admin]
  end
end

# Usage
create(:user)
create(:user, :admin, :with_posts, posts_count: 5)
build_stubbed(:user) # No database hit
```

### Shared Examples

```ruby
# spec/support/shared_examples/authenticatable.rb
RSpec.shared_examples "requires authentication" do
  it "redirects unauthenticated users" do
    sign_out :user
    make_request
    expect(response).to redirect_to(new_user_session_path)
  end
end

# Usage in specs
RSpec.describe "Posts", type: :request do
  describe "POST /posts" do
    it_behaves_like "requires authentication" do
      let(:make_request) { post posts_path, params: { post: { title: "X" } } }
    end
  end
end
```

### Mocking External APIs

```ruby
# Using WebMock
RSpec.describe PaymentService do
  before do
    stub_request(:post, "https://api.stripe.com/v1/charges")
      .with(body: hash_including(amount: "1000"))
      .to_return(status: 200, body: { id: "ch_123" }.to_json)
  end

  it "creates a charge" do
    result = PaymentService.charge(amount: 1000, currency: "usd")
    expect(result.id).to eq("ch_123")
  end
end

# Using VCR for recorded HTTP interactions
RSpec.describe GithubClient do
  it "fetches repository info", vcr: { cassette_name: "github/repo" } do
    repo = GithubClient.new.repository("rails/rails")
    expect(repo[:full_name]).to eq("rails/rails")
  end
end
```

## Best Practices

- Prefer `build` or `build_stubbed` over `create` when you do not need database persistence -- it is significantly faster.
- Use `let` (lazy) by default; use `let!` (eager) only when the record must exist before the test runs.
- Write request specs for controller logic; reserve system specs for critical user flows.
- Keep factories minimal. Use traits for variations rather than deeply nested factory inheritance.
- Use the project's configured RSpec parallelization strategy when the suite is large enough to benefit from it.
- Test behavior, not implementation. Assert on outcomes, not on which methods were called.
- Use `freeze_time` or `travel_to` for time-dependent tests instead of stubbing `Time.now`.

## Common Pitfalls

- **Slow test suites**: Overuse of `create` and system tests. Keep the test pyramid balanced: many unit tests, fewer integration tests, fewest system tests.
- **Flaky system tests**: Race conditions from asynchronous JavaScript. Use Capybara's built-in waiting matchers (`have_text`, `have_selector`) instead of `sleep`.
- **Factory cascades**: A single `create(:post)` that also creates a user, organization, and subscription. Audit factory dependencies.
- **Testing Rails internals**: Do not test that `validates_presence_of` works. Test your custom logic and important business rules.
- **Shared state between tests**: Forgetting `DatabaseCleaner` or transactional fixtures leads to order-dependent failures.
- **Brittle mocks**: Over-mocking hides integration bugs. Mock at the boundary (HTTP calls, external services), not between your own classes.
