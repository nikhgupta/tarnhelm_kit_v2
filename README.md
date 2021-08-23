# Tarnhelm Kit

Opinionated Ruby On Rails Starter kit with an aim to provide complete SaaS
features out of the box.

For most features, you should be able to enable or disable them from a dashboard. As an
example, Tarnhelm provides passwordless logins with a fallback to passwords, by default.
You can completely disable this fallback or even, remove passwordless logins in your app
by changing a toggle.

You MAY not be able to disable features that are recommended or required for a
SaaS product, e.g. row-level database encryption for sensitive data, but you can
opt-out of such features by not using them in the code that you write.

## Features

### Stack

- [x] Ruby on Rails
- [x] Tailwind CSS
- [x] Hotwire with Typescript support

### Product Management

- [x] Enable/Disable core SaaS features using Flipper gem (rollouts)
- [ ] A/B testing easily

### SaaS Features

- [x] Row-level encryption in database
- [ ] Mailing service integration
- [ ] Payment gateway integration (Stripe)
- [ ] Subscriptions and Plans
- [ ] Notifications system for Users
- [ ] Site-wide Announcements
- [ ] Newsletter support
- [ ] Onboarding Workflow for new Users
- [ ] Analytics integration
- [ ] Real-time chat integration
- [ ] Errors and bugs tracking
- [ ] Feature Requests page
- [ ] Blog Pages with Comments
- [ ] Background processing queues
- [ ] Affiliate tracking (maybe)
- [ ] Theming support (maybe)
- [ ] Customer support module (maybe)
- [ ] Forums (maybe)

### User Management

- [x] Choose any combination of omniauth, passwordless or password auth
- [x] Login
- [x] Registration
- [x] Email verification
- [x] Password recovery workflow
- [x] Profile page
- [x] Passwordless Login/Registration (magic link)
- [x] Fallback to traditional password-based logins
- [x] Omniauth (Google and Twitter example)
- [ ] User invitation system
- [ ] Multi-tenancy (via accounts)
- [ ] User impersonation
- [ ] User roles and permissions
- [ ] Pundit policies for authorization
- [ ] Email templates for authentication mailers
- [ ] API Keys and permission based scopes
- [ ] API endpoints for authentication routes

### Static Pages

- [ ] CMS for static pages (maybe)
- [ ] Provides the following pages:
  - [ ] Landing Page
  - [ ] Pricing Page
  - [ ] About Page
  - [ ] Privacy Policy Page
  - [ ] Terms of Service Page
  - [ ] Contact Page
  - [ ] FAQ Page
  - [ ] Error pages

### Development

- [x] Rubocop style guides
- [ ] Extensive test coverage

### Launch Helpers

- [ ] Demo accounts creation utility
- [ ] Docker scripts and support

---

## Inspiration

The list above has largely been taken from [FullyBearded](https://fullybearded.com/articles/saas-starter-kit-features/):

- [x] A **gorgeous layout with common components** (inputs, buttons, typography,
      ...) based on a popular CSS framework (Bootstrap, Bulma, tailwind, ...).
      Ideally, this layout should already be slightly customized to avoid looking
      "bootstrapy" and should be easy to override to make it look like the fancy
      template provided by the designer. The layout should be responsive if it makes
      sense;

- [ ] **Basic/common pages**: landing, pricing & subscriptions, about, privacy policy,
      contact page, FAQ, ...

- [ ] Integration with a **mailing service** like mailgun, to send emails;

- [x] **User management** (Login, registration, profile page, email verification,
      password recovery workflow and/or OAuth);

- [ ] **Invite system** so your current users can invite others to the platform;

- [ ] If you don't plan to let everyone enter at the same time, then a **gatekeeper**
      might be useful too;

- [ ] Integration with a **stripe** to accept payments and a **billing** system if you do
      so;

- [ ] **CRUD scaffolding** to build your CRUD as fast as possible. If you've never seen
      this, look into ruby on rails;

- [ ] **Backoffice/dashboard** so a super admin can manage day-to-day situations. If you
      build this with Django (and I will), you already have a very good starting point
      for this;

- [ ] If your users need to work in teams (something like google drive), then you'll
      need **multi-tenancy support**. Once you build this, you'll also need a system to
      handle **permissions and security**;

- [ ] **General documentation** of the project and **documentation of the API** (if you have
      one - look into sagger and open API);

- [ ] **Docker support** to build the project and **docker-compose for the development
      environment**;

- [ ] **Real-time chat** in case you need to provide live support. You can build this or
      integrate a service like Intercom;

- [ ] **Analytics, reporting, tracking** and other third party integrations that might
      make sense for your product (google analytics, segment, rollbar);

- [ ] **A/B testing, newsletter support, affiliate tracking** for marketing purposes;

- [ ] An **onboarding workflow** so your users can feel welcome to the platform and
      avoid being lost;

- [x] **Complete test coverage** (unit and integration testing);

- [ ] Workflow to automate the **creation of demo accounts** for demonstration purposes.
