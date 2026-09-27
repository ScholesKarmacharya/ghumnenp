# GHUMNE - MASTER PRODUCT & DEVELOPMENT SPECIFICATION

> Single source of truth for product, design, architecture, data, security, testing, and implementation.
> Codex must read this entire file before making changes.

---

# 0. DOCUMENT PURPOSE

This file defines the complete direction for **Ghumne**, a Nepal-focused B2C travel discovery and trip-planning platform.

Ghumne is NOT primarily a travel-agency marketplace and is NOT another generic tourism information website.

The core consumer promise is:

> **Tell Ghumne your budget, available days, starting location, travel month, group size, transport preference, and interests. Ghumne helps you decide where to go and how to plan the trip.**

Core journey:

**DISCOVER -> PLAN -> SAVE/SHARE -> CONNECT**

Travel agencies, tour packages, hotels, activities, and other partners are a secondary monetization and fulfillment layer.

---

# 1. PRD - PRODUCT REQUIREMENTS

## 1.1 Product Name

**Ghumne**

Suggested positioning:

**Discover Nepal. Plan your trip.**

Alternative consumer message:

**Kata jane? Ghumne ma hera.**

## 1.2 Vision

Build a trusted Nepal travel-planning platform that helps people answer:

- Where should I go?
- Can I afford it?
- How many days do I need?
- How do I get there?
- What should I do there?
- Where should I stay?
- What should I pack?
- When should I visit?
- Can someone arrange the trip for me?

## 1.3 Initial Market

Primary launch market:

- Domestic travelers in Nepal
- Travelers starting from Kathmandu and other major cities
- Young adults, couples, friend groups, families, solo travelers

Secondary market:

- International travelers researching Nepal
- Travel agencies and tour operators seeking qualified leads

## 1.4 Problem

Travel planning in Nepal is fragmented. Users often jump between Google, Maps, TikTok, Instagram, Facebook groups, travel blogs, hotel sites, agency sites, and friends to determine basic trip information.

Users frequently need answers to combinations such as:

- Rs. 15,000 budget, 3 days, where can two people go from Kathmandu?
- Where can I see snow this month?
- What is a good weekend destination for a couple?
- Can I reach a destination by bike?
- What will transport, hotel, food, and activities approximately cost?

Ghumne should bring these decisions into one coherent flow.

## 1.5 Product Principles

1. Consumer usefulness comes before monetization.
2. Ghumne must remain useful even with zero agency packages.
3. Recommendations must explain why a destination matches.
4. Never present uncertain prices, travel times, weather, road conditions, or availability as guaranteed facts.
5. Data freshness must be visible internally and, where useful, to users.
6. Mobile-first UX is mandatory.
7. Avoid cluttered travel-agency aesthetics.
8. Do not make AI the product. AI may improve the experience, but trustworthy travel planning is the product.
9. Do not require login just to explore destinations or use the basic trip finder.
10. Partner content must not secretly override organic recommendations.

## 1.6 Core User Journey

### Discovery

User provides:

- Starting location
- Budget
- Number of travelers
- Number of days
- Travel month/date
- Interests
- Transport preference
- Travel style

Ghumne returns matching destinations.

### Planning

User selects a destination and receives:

- Destination overview
- Suggested duration
- Estimated budget
- Transport options
- Suggested itinerary
- Attractions
- Activities
- Accommodation guidance
- Food guidance
- Best season
- Packing suggestions
- Travel tips
- Map/location context

### Save / Share

Authenticated users can:

- Save destination
- Favorite destination
- Save generated trip
- Edit trip
- Share trip via public link

### Connect

Where partners exist, users can optionally:

- View relevant packages
- Visit agency website
- Send inquiry
- Open WhatsApp/contact channel

## 1.7 MVP Features

### Public

- Homepage
- Destination directory
- Destination detail pages
- Smart Trip Finder
- Recommendation results
- Basic trip planner
- Budget estimate
- Suggested itinerary
- Search
- Filters
- Responsive navigation

### Authentication

- Email authentication
- Google authentication if practical
- User profile

### Logged-in Traveler

- Saved destinations
- Favorites
- Saved trips
- Edit trip
- Share trip

### Admin

- Admin authentication/role
- Destination CRUD
- Attraction CRUD
- Activity CRUD
- Transport data CRUD
- Budget data CRUD
- Seasonal data CRUD
- Content publish/unpublish
- Data freshness tracking

### Partner Layer - after consumer foundation

- Agency profile
- Agency verification status
- Agency dashboard
- Package CRUD
- Package-to-destination association
- Inquiry/lead capture
- Website and WhatsApp outbound actions
- Basic analytics

## 1.8 Explicitly Out of MVP

Do NOT build these until core discovery/planning is validated:

- Full payment processing
- Escrow
- Refund management
- Complex booking engine
- Airline ticketing
- Hotel inventory management
- Real-time vehicle inventory
- Native mobile applications
- Social network/feed
- Complex loyalty program
- Cryptocurrency
- Microservices

## 1.9 Success Metrics

Consumer metrics:

- Trip Finder completion rate
- Recommendation click-through rate
- Destination page engagement
- Trips created
- Trips saved
- Trips shared
- Returning users
- Search-to-plan conversion

Partner metrics later:

- Package impressions
- Package views
- Website clicks
- WhatsApp clicks
- Inquiries generated
- Qualified lead rate

Never invent a single universal "AI score" or recommendation score for external marketing without defining its methodology.

---

# 2. DATA STRATEGY

## 2.1 Why Data Is Critical

The hardest part of Ghumne is not UI development. Recommendation quality depends on structured and maintainable Nepal travel data.

## 2.2 Core Destination Data

Each destination should support:

- Name
- Slug
- Province/district/region
- Latitude/longitude
- Short description
- Long description
- Hero image
- Gallery
- Recommended minimum days
- Recommended maximum days
- Difficulty/accessibility
- Suitable traveler types
- Interest tags
- Best months
- Less suitable months
- Typical transport methods
- Approximate travel time from common origins
- Approximate budget ranges
- Accommodation range
- Food range
- Activity costs
- Attractions
- Activities
- Packing notes
- Safety/travel notes
- Permit requirements where relevant
- Last verified date
- Source notes/internal evidence
- Published status

## 2.3 Price Data

Do not store one misleading fixed trip price.

Use ranges and components:

- Transport low/high
- Accommodation low/high per night
- Food low/high per person/day
- Activities low/high
- Permit/entry costs
- Miscellaneous buffer

Store currency and last-verified date.

## 2.4 Travel Time

Travel time should support:

- Origin
- Destination
- Transport mode
- Minimum estimate
- Maximum estimate
- Notes
- Last verified

Do not promise exact road travel time.

## 2.5 Seasonality

For each destination/month, store useful structured attributes such as:

- Suitability score or category
- Weather notes
- Crowding level
- Trekking suitability
- Snow possibility where relevant
- Monsoon considerations
- Accessibility notes

Any score must have a documented meaning and should not pretend to be scientific if it is editorial.

## 2.6 Data Sources

Prefer reliable sources such as:

- Official tourism authorities
- Local government information
- Transport operators
- Official park/conservation sources
- Direct partner confirmations
- Verified accommodation/operator information
- Manual editorial verification

Crowdsourced information may supplement, but should not automatically become authoritative data.

## 2.7 Data Freshness

Every dynamic record should support:

- `last_verified_at`
- `verified_by`
- `source_note`

Admin should be able to identify stale data.

## 2.8 Initial Seed Scope

Do not attempt all Nepal destinations at launch.

Start with approximately 15-25 high-quality destinations across categories such as:

- Pokhara
- Chitwan
- Bandipur
- Mustang
- Manang
- Rara
- Ilam
- Nagarkot
- Janakpur
- Lumbini
- Kathmandu Valley day/weekend destinations
- Selected trekking destinations

Quality is more important than destination count.

---

# 3. RECOMMENDATION ENGINE

## 3.1 Inputs

Trip Finder should accept:

- Origin
- Budget
- Travelers
- Days
- Month/date
- Interests
- Transport preference
- Travel style

Optional later:

- Children
- Accessibility needs
- Trekking difficulty
- Accommodation preference

## 3.2 Recommendation Logic V1

Do NOT start with an LLM deciding everything.

Use deterministic filtering/scoring based on structured data.

Example factors:

- Budget compatibility
- Duration compatibility
- Seasonal suitability
- Interest match
- Origin/travel-time compatibility
- Transport compatibility
- Traveler-type match

Return a match explanation such as:

> Good for your 3-day nature trip because it fits your estimated budget, is reachable from Kathmandu within the selected duration, and October is a recommended month.

## 3.3 Budget Calculation

Estimated trip total should derive from components:

`transport + accommodation + food + activities + permits + buffer`

Multiply traveler-dependent components correctly.

Display ranges, not fake precision.

Example:

**Estimated trip budget: Rs. 14,000 - 18,500 for 2 travelers**

Include a disclaimer that actual costs vary.

## 3.4 AI Usage Later

AI may later help with:

- Natural-language trip input
- Itinerary wording
- Conversational travel discovery
- Summarizing destination information

AI must consume verified structured Ghumne data where possible. It must not freely invent prices, road conditions, permits, opening hours, or safety information.

---

# 4. DESIGN SPECIFICATION

## 4.1 Design Direction

Ghumne should feel:

- Modern
- Exploratory
- Trustworthy
- Nepal-inspired without visual clichés
- Image-rich
- Clean
- Mobile-first

Avoid overcrowded cards, excessive gradients, unnecessary animations, and traditional agency brochure styling.

## 4.2 Homepage Structure

1. Navigation
2. Hero / Smart Trip Finder
3. Perfect for this month
4. Weekend trips
5. Budget-based discovery
6. Categories/interests
7. Trending destinations
8. How Ghumne works
9. Travel stories/content later
10. Footer

Suggested hero:

> **Not sure where to go?**
> Tell us your budget and time. We'll help you find a trip.

Fields:

- From
- Budget
- Days
- Travelers
- Month
- Interests
- Find My Trip

## 4.3 Destination Card

Show only decision-useful information:

- Image
- Destination name
- Location
- Suggested duration
- Approximate budget indicator/range
- Key tags
- Best-season indicator when appropriate

## 4.4 Recommendation Result Card

Include:

- Destination
- Match explanation
- Estimated total budget
- Suggested duration
- Travel time summary
- Interest tags
- CTA: View Trip

## 4.5 Destination Page

Recommended sections:

- Hero
- Overview
- Why visit
- Best time
- Getting there
- Estimated budget
- Things to do
- Attractions
- Suggested itinerary
- Where to stay
- Food guidance
- Packing list
- Important travel notes
- Map
- Packages, if available

## 4.6 Trip Planner

Trip planner should organize:

- Trip summary
- Day-by-day itinerary
- Budget
- Transport
- Accommodation notes
- Activities
- Personal notes

Users should be able to edit and reorder items later.

## 4.7 Responsive Rules

- Mobile-first
- Touch targets >= 44px where practical
- No horizontal overflow
- Filters must work on small screens
- Forms should use correct input types
- Images optimized responsively
- Navigation should remain simple

## 4.8 Accessibility

- Semantic HTML
- Keyboard support
- Visible focus states
- Labels for inputs
- Useful alt text
- Sufficient contrast
- Do not rely only on color to communicate state
- Respect reduced-motion preference

---

# 5. TECHNICAL ARCHITECTURE

## 5.1 Preferred Stack

- Next.js, current stable App Router
- TypeScript
- Tailwind CSS
- PostgreSQL via Supabase
- Supabase Auth
- Supabase Storage
- Zod for validation
- React Hook Form where appropriate
- Playwright for E2E
- Vitest or suitable current unit-test solution
- Vercel deployment

Optional based on actual need:

- Mapbox or Google Maps
- PostHog and/or Google Analytics

## 5.2 Architecture Principles

- Start as a modular monolith
- Prefer Server Components by default
- Use Client Components only when interaction requires them
- Keep business logic outside UI components
- Validate all external/user input server-side
- Do not expose privileged Supabase keys to the browser
- Keep data access centralized
- Avoid premature abstraction
- Avoid unnecessary dependencies

## 5.3 Suggested Source Structure

```text
src/
├── app/
│   ├── (public)/
│   ├── (auth)/
│   ├── dashboard/
│   ├── admin/
│   └── api/
├── components/
│   ├── ui/
│   ├── layout/
│   ├── destination/
│   ├── trip/
│   └── partner/
├── features/
│   ├── destinations/
│   ├── recommendations/
│   ├── trips/
│   ├── auth/
│   ├── agencies/
│   └── inquiries/
├── lib/
│   ├── supabase/
│   ├── validation/
│   ├── auth/
│   └── utils/
├── types/
└── tests/
```

Codex may refine this structure if justified in `DECISIONS.md`.

---

# 6. DATABASE SPECIFICATION

Use UUID primary keys unless a strong reason exists otherwise.

## 6.1 Core Tables

### profiles

- id
- display_name
- avatar_url
- role (`traveler`, `partner`, `admin`)
- created_at
- updated_at

### destinations

- id
- name
- slug
- short_description
- description
- province
- district
- latitude
- longitude
- min_days
- max_days
- hero_image_url
- published
- last_verified_at
- created_at
- updated_at

### interests

- id
- name
- slug

Examples: nature, adventure, culture, relaxation, food, trekking, wildlife, photography, family, couple.

### destination_interests

- destination_id
- interest_id
- weight

### destination_seasons

- id
- destination_id
- month
- suitability
- notes
- last_verified_at

### attractions

- id
- destination_id
- name
- description
- latitude
- longitude
- estimated_cost_min
- estimated_cost_max
- currency
- published

### activities

- id
- destination_id
- name
- description
- estimated_cost_min
- estimated_cost_max
- duration_minutes
- published

### transport_routes

- id
- origin_name
- destination_id
- transport_mode
- duration_min_minutes
- duration_max_minutes
- cost_min
- cost_max
- currency
- notes
- last_verified_at

### destination_costs

- id
- destination_id
- accommodation_min_per_night
- accommodation_max_per_night
- food_min_per_person_day
- food_max_per_person_day
- misc_min_per_person_day
- misc_max_per_person_day
- currency
- last_verified_at

### trips

- id
- user_id
- destination_id
- title
- origin
- start_date nullable
- end_date nullable
- days
- travelers
- budget
- currency
- visibility (`private`, `unlisted`)
- created_at
- updated_at

### trip_days

- id
- trip_id
- day_number
- title
- notes

### trip_items

- id
- trip_day_id
- item_type
- reference_id nullable
- title
- notes
- start_time nullable
- estimated_cost nullable
- sort_order

### favorites

- user_id
- destination_id
- created_at

### agencies

- id
- owner_user_id
- name
- slug
- description
- logo_url
- website_url
- phone
- whatsapp
- email
- verification_status
- published
- created_at
- updated_at

### packages

- id
- agency_id
- destination_id
- title
- slug
- description
- duration_days
- price_from
- currency
- itinerary
- inclusions
- exclusions
- website_url
- published
- created_at
- updated_at

### inquiries

- id
- package_id
- agency_id
- user_id nullable
- name
- email nullable
- phone
- travel_date nullable
- travelers
- message
- status
- created_at

## 6.2 Database Rules

- Unique slugs where required
- Foreign keys enforced
- Appropriate indexes for search/filter fields
- RLS enabled on Supabase tables containing private/user-owned data
- Travelers can modify only their own trips/favorites
- Partners can modify only their own agency/packages and view authorized leads
- Admin privileges must be server-verified

---

# 7. API / SERVER ACTIONS

Prefer server actions for application mutations where appropriate and route handlers for public/API-style endpoints.

Potential interfaces:

### Public

- Get destinations
- Get destination by slug
- Search destinations
- Get recommendation results
- Calculate budget estimate

### Traveler

- Create trip
- Update trip
- Delete trip
- Save favorite
- Remove favorite
- Share/unshare trip

### Partner

- Create/update agency profile
- Create package
- Update package
- Delete/unpublish package
- Get agency inquiries
- Update inquiry status

### Admin

- CRUD destination data
- Publish/unpublish content
- Verify agency
- Review stale data

Every mutation requires:

1. Authentication where applicable
2. Authorization
3. Zod validation
4. Safe error handling
5. Database operation
6. Useful response/result

---

# 8. SECURITY

## 8.1 Authentication

Use Supabase Auth.

Never trust role information sent from the client.

## 8.2 Authorization

Enforce authorization server-side and through database RLS where appropriate.

Roles:

- traveler
- partner
- admin

## 8.3 Input Security

- Validate with Zod
- Sanitize/render user-generated content safely
- Validate URLs
- Restrict uploads by MIME type and size
- Generate safe storage paths
- Do not expose internal errors to users

## 8.4 Secrets

- `.env.local` must not be committed
- Provide `.env.example`
- Service-role keys only on server
- No secrets in client bundles

## 8.5 Abuse Prevention

For public inquiry/contact features:

- Rate limiting where feasible
- Spam prevention
- Server validation
- Logging of suspicious failures without collecting unnecessary sensitive information

## 8.6 Privacy

Collect only data needed for product functionality.

Do not expose traveler contact information publicly.

---

# 9. SEO AND AI SEARCH READINESS

Ghumne should be technically strong for traditional and AI-assisted search discovery.

Implement:

- Semantic HTML
- Metadata per destination
- Canonical URLs
- XML sitemap
- robots.txt
- Open Graph metadata
- Structured data where genuinely applicable
- Breadcrumbs
- Fast pages
- Crawlable destination content
- Descriptive internal linking
- Image alt text

Destination pages should directly answer common traveler questions instead of hiding useful information behind generic marketing copy.

Do not create fake FAQ content or spam schema.

---

# 10. TEST PLAN

## 10.1 Unit Tests

Prioritize business logic:

- Budget calculations
- Recommendation scoring
- Duration filtering
- Season matching
- Interest matching
- Validation schemas
- Utility functions

## 10.2 Integration Tests

Test:

- Authentication flows
- Destination retrieval
- Trip creation/update
- Favorites
- Partner package ownership
- Inquiry creation
- Authorization boundaries

## 10.3 E2E Tests

Playwright critical journeys:

### Journey A

Homepage -> Trip Finder -> Results -> Destination

### Journey B

Sign up -> Save destination -> View saved destination

### Journey C

Create trip -> Edit trip -> Save -> Share

### Journey D later

Partner login -> Create package -> Publish -> Public package visible

### Journey E later

Traveler -> Package -> Inquiry -> Partner receives inquiry

## 10.4 Quality Gates

Before a task is complete:

- TypeScript passes
- Lint passes
- Relevant tests pass
- No obvious responsive regression
- No accessibility regression in changed UI
- No unauthorized data access

---

# 11. CODING RULES FOR CODEX

Codex MUST follow these rules.

## 11.1 Before Coding

1. Read this entire file.
2. Inspect the existing repository before creating/replacing files.
3. Do not destroy working functionality without justification.
4. Understand the current task and dependencies.
5. If architecture changes, document them.

## 11.2 Implementation

- TypeScript strictness should remain enabled.
- Avoid `any` unless unavoidable and documented.
- Keep components focused.
- Separate domain/business logic from presentation.
- Reuse existing components where appropriate.
- Do not create duplicate utilities/components.
- Prefer clear names over clever abstractions.
- Do not install packages without a concrete need.
- Do not implement future phases while completing an earlier task unless required as a dependency.

## 11.3 UI

- Follow the design specification.
- Mobile-first.
- Do not redesign unrelated pages during a task.
- Preserve visual consistency.
- Include loading, empty, success, and error states where relevant.

## 11.4 Database

- Never make destructive production migrations casually.
- Migrations must be reviewable.
- RLS policies must accompany user-owned/private tables.
- Seed data must be clearly separated from production data.

## 11.5 Git

Recommended commit pattern:

`feat: implement destination directory`

`fix: correct trip budget calculation`

`test: add recommendation engine coverage`

Do not combine unrelated work into one commit.

## 11.6 Task Completion Report

After each task, Codex should state:

- Task completed
- Files created
- Files modified
- Tests run
- Test result
- Any migration/environment change
- Any blocker or follow-up

Then update task status before moving on.

---

# 12. DECISIONS

Maintain this section as development progresses.

## DEC-001 - B2C First

Ghumne is primarily a consumer travel discovery/planning platform. Agency marketplace functionality is secondary.

## DEC-002 - Marketplace Does Not Replace Agency Websites

Partners may use Ghumne as a discovery/lead channel and redirect travelers to their own website or contact channel.

## DEC-003 - Deterministic Recommendations First

V1 recommendations use structured data and transparent matching logic instead of relying entirely on generative AI.

## DEC-004 - No Payment System in Initial MVP

Initial partner conversion is inquiry/redirect based. Payments and booking settlement are deferred.

## DEC-005 - Modular Monolith

Use one Next.js application with a clear modular structure rather than microservices.

## DEC-006 - Structured Travel Data

Travel data is a first-class product asset and must include verification/freshness metadata.

Implementation decisions beginning with DEC-007 are maintained in `DECISIONS.md`.

---

# 13. IMPLEMENTATION TASKS

Status values:

- `[ ]` Not started
- `[~]` In progress
- `[x]` Complete
- `[!]` Blocked

Codex should work sequentially unless a dependency makes a different order necessary.

## PHASE 1 - Repository Foundation

- [x] TASK-001 Audit existing repository and document reusable code/assets
- [x] TASK-002 Confirm/create Next.js App Router + TypeScript foundation
- [x] TASK-003 Configure Tailwind and global styling foundation
- [x] TASK-004 Configure linting/formatting/type checks
- [x] TASK-005 Add `.env.example` and environment validation
- [x] TASK-006 Configure Supabase clients correctly for server/browser
- [x] TASK-007 Establish project folder architecture

## PHASE 2 - Design System

- [x] TASK-008 Define design tokens
- [x] TASK-009 Implement typography
- [x] TASK-010 Implement buttons and links
- [x] TASK-011 Implement form controls
- [ ] TASK-012 Implement cards/badges
- [ ] TASK-013 Implement responsive header/navigation
- [ ] TASK-014 Implement footer
- [ ] TASK-015 Add standard loading/error/empty states

## PHASE 3 - Database Foundation

- [ ] TASK-016 Create initial schema migration
- [ ] TASK-017 Configure RLS
- [ ] TASK-018 Create destination-related tables
- [ ] TASK-019 Create traveler/trip tables
- [ ] TASK-020 Create initial indexes/constraints
- [ ] TASK-021 Create seed system for development
- [ ] TASK-022 Seed first high-quality destination dataset

## PHASE 4 - Destination Experience

- [ ] TASK-023 Build homepage shell
- [ ] TASK-024 Build destination directory
- [ ] TASK-025 Add destination search
- [ ] TASK-026 Add destination filters
- [ ] TASK-027 Build destination card
- [ ] TASK-028 Build destination detail page
- [ ] TASK-029 Add attractions section
- [ ] TASK-030 Add activities section
- [ ] TASK-031 Add transport section
- [ ] TASK-032 Add budget section
- [ ] TASK-033 Add season/best-time section
- [ ] TASK-034 Add packing/travel-notes section
- [ ] TASK-035 Add map integration or map placeholder abstraction

## PHASE 5 - Smart Trip Finder

- [ ] TASK-036 Build Trip Finder form
- [ ] TASK-037 Validate Trip Finder input
- [ ] TASK-038 Implement budget compatibility logic
- [ ] TASK-039 Implement duration compatibility logic
- [ ] TASK-040 Implement seasonal matching
- [ ] TASK-041 Implement interest matching
- [ ] TASK-042 Implement transport/origin matching
- [ ] TASK-043 Create recommendation scoring service
- [ ] TASK-044 Create recommendation explanation generator
- [ ] TASK-045 Build recommendation results page
- [ ] TASK-046 Add no-results/fallback experience
- [ ] TASK-047 Add recommendation unit tests

## PHASE 6 - Budget Engine

- [ ] TASK-048 Implement transport cost calculation
- [ ] TASK-049 Implement accommodation calculation
- [ ] TASK-050 Implement food calculation
- [ ] TASK-051 Implement activity/permit calculation
- [ ] TASK-052 Add contingency/buffer logic
- [ ] TASK-053 Display estimated range and assumptions
- [ ] TASK-054 Add budget engine tests

## PHASE 7 - Authentication

- [ ] TASK-055 Configure Supabase Auth
- [ ] TASK-056 Build sign-up
- [ ] TASK-057 Build login
- [ ] TASK-058 Build logout
- [ ] TASK-059 Build auth callback/reset flows
- [ ] TASK-060 Create traveler profile
- [ ] TASK-061 Protect authenticated routes

## PHASE 8 - Saved Content

- [ ] TASK-062 Favorite destination
- [ ] TASK-063 Remove favorite
- [ ] TASK-064 Saved destinations page
- [ ] TASK-065 Verify ownership/RLS tests

## PHASE 9 - Trip Planner

- [ ] TASK-066 Create trip from recommendation/destination
- [ ] TASK-067 Create trip overview
- [ ] TASK-068 Create day-by-day itinerary
- [ ] TASK-069 Add/edit/remove itinerary item
- [ ] TASK-070 Reorder itinerary items
- [ ] TASK-071 Integrate budget estimate into trip
- [ ] TASK-072 Save trip
- [ ] TASK-073 Delete trip
- [ ] TASK-074 Build My Trips dashboard
- [ ] TASK-075 Create unlisted share link
- [ ] TASK-076 Add trip planner E2E tests

## PHASE 10 - Admin CMS

- [ ] TASK-077 Implement admin authorization
- [ ] TASK-078 Admin dashboard
- [ ] TASK-079 Destination CRUD
- [ ] TASK-080 Attraction CRUD
- [ ] TASK-081 Activity CRUD
- [ ] TASK-082 Transport CRUD
- [ ] TASK-083 Cost data CRUD
- [ ] TASK-084 Seasonality CRUD
- [ ] TASK-085 Publish/unpublish workflow
- [ ] TASK-086 Data freshness/stale-data view

## PHASE 11 - Partner Foundation

Do this only after the consumer foundation is stable.

- [ ] TASK-087 Create agency schema/policies
- [ ] TASK-088 Partner onboarding
- [ ] TASK-089 Agency profile editor
- [ ] TASK-090 Agency public profile
- [ ] TASK-091 Package CRUD
- [ ] TASK-092 Associate packages with destinations
- [ ] TASK-093 Display packages on destination pages
- [ ] TASK-094 Add outbound website action
- [ ] TASK-095 Add WhatsApp/contact action

## PHASE 12 - Leads

- [ ] TASK-096 Build inquiry form
- [ ] TASK-097 Add inquiry validation/spam controls
- [ ] TASK-098 Store inquiries securely
- [ ] TASK-099 Partner lead inbox
- [ ] TASK-100 Lead status management
- [ ] TASK-101 Basic lead analytics

## PHASE 13 - SEO / Discovery

- [ ] TASK-102 Dynamic metadata
- [ ] TASK-103 Sitemap
- [ ] TASK-104 robots.txt
- [ ] TASK-105 Open Graph
- [ ] TASK-106 Breadcrumbs
- [ ] TASK-107 Appropriate structured data
- [ ] TASK-108 Internal linking audit

## PHASE 14 - Analytics

- [ ] TASK-109 Add privacy-conscious analytics
- [ ] TASK-110 Track Trip Finder completion
- [ ] TASK-111 Track recommendation selection
- [ ] TASK-112 Track trip creation/save/share
- [ ] TASK-113 Track partner website/WhatsApp clicks
- [ ] TASK-114 Track inquiries

## PHASE 15 - QA / Launch

- [ ] TASK-115 Full responsive audit
- [ ] TASK-116 Accessibility audit
- [ ] TASK-117 Security/authorization audit
- [ ] TASK-118 Performance audit
- [ ] TASK-119 SEO audit
- [ ] TASK-120 E2E regression suite
- [ ] TASK-121 Production environment verification
- [ ] TASK-122 Deploy production release
- [ ] TASK-123 Post-deployment smoke test

---

# 14. DEVELOPMENT WORKFLOW

For every task:

**UNDERSTAND -> PLAN -> IMPLEMENT -> TEST -> REVIEW -> DOCUMENT -> COMMIT**

Do not blindly continue after a failed test.

Fix the current task before starting unrelated work.

---

# 15. DEFINITION OF DONE

A feature is not complete just because it visually appears.

It is done when:

- Requirement is implemented
- UI works on mobile and desktop
- Loading/error/empty states are handled
- Input is validated
- Authorization is correct
- Relevant tests pass
- No TypeScript/lint errors are introduced
- Accessibility basics are respected
- Documentation/task state is updated

---

# 16. CODEX START INSTRUCTION

When this file is first given to Codex, use the following operating instruction:

> Read `GHUMNE_MASTER_SPEC.md` completely before making any code changes. Then inspect the entire existing repository and compare it against the specification. Do not immediately rewrite the project. First complete TASK-001 by identifying what can be reused, what conflicts with the new product direction, technical debt, current dependencies, database/auth configuration, existing routes/components, and missing requirements. Produce a concise repository audit and implementation plan. After TASK-001, proceed sequentially through TASK-002 onward. For every task, follow UNDERSTAND -> PLAN -> IMPLEMENT -> TEST -> REVIEW -> DOCUMENT. Do not skip tests, do not implement unrelated future features, do not make unnecessary visual changes, and do not remove working code without a documented reason. Update task status as work progresses and report files changed and tests run after each task.

---

# 17. FUTURE IDEAS - NOT CURRENT REQUIREMENTS

Keep these out of the MVP unless explicitly promoted into the task list:

- Natural-language AI trip planner
- Personalized recommendations from behavior
- Real-time road/weather integrations
- Hotel booking
- Transport booking
- Full tour booking/payment
- Reviews and ratings
- Native Android/iOS apps
- Collaborative group trip planning
- Expense splitting
- Offline itinerary
- Nepali-language interface
- International traveler localization
- Partner subscriptions
- Featured/sponsored packages
- Commission marketplace

---

# 18. FINAL PRODUCT RULE

Whenever there is uncertainty about a feature, ask:

> **Does this make it easier for a traveler to decide where to go or plan the trip?**

If no, it is probably not an MVP priority.

The long-term product loop is:

**Better destination data -> better recommendations -> more travelers -> more saved/planned trips -> more partner interest -> more useful fulfillment options -> better Ghumne experience.**
