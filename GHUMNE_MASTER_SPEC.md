# GHUMNE - MASTER PRODUCT & DEVELOPMENT SPECIFICATION

> Product authority for Ghumne, developed by Zenlabs.
> Revised: 2026-10-20. Read this file before implementation.
> This product/database plan supersedes the former secondary-marketplace direction. It does not represent implemented features or permission to apply migrations.

## 0. Purpose and product direction

Ghumne is a Nepal-focused B2C travel discovery, multi-agency package marketplace and smart trip-planning platform. All three experiences are core to the MVP. Marketplace foundations precede public package matching; agencies are no longer a late optional partner layer.

Traveler promise: **Discover Nepal, compare trips from approved agencies, or plan your own trip around your budget and time.**

Journey: **DISCOVER -> COMPARE PACKAGES / PLAN -> SAVE / SHARE -> INQUIRE / VISIT AGENCY**. The product remains useful with no agency inventory. Agencies may retain their existing websites as booking destinations. Initial conversion uses inquiry forms, WhatsApp and external booking links. No payment processing, inventory reservations, booking settlement or booking commissions are included.

Current authorization covers TASK-015 verification, provisional V1 policies and reviewable SQL migrations/tests. Preserve completed foundation code. Stop before executing any database migrations or destructive changes; do not introduce paid services without explicit approval. [V1_BUSINESS_POLICIES.md](V1_BUSINESS_POLICIES.md) records the owner's provisional decisions and remaining final commercial choices.

## 1. Product requirements

### 1.1 Market and problem

Serve domestic Nepal travelers first: solo travelers, couples, friends and families starting from Kathmandu and other cities. International travelers researching Nepal are secondary. Approved agencies are core marketplace suppliers.

Travel research is fragmented across maps, social media, blogs, transport operators and agency websites. Travelers need to know where to go, what a whole group can afford, how long a trip takes, and which actual agency offers fit. Agencies need owned profiles, accurate listings and qualified inquiries without replacing their websites.

Working positioning: **Discover Nepal. Compare packages. Plan your trip.** Update existing foundation copy with its assigned UI task; this revision does not redesign the application.

### 1.2 Three core experiences

1. **Travel Discovery:** Search Nepal destinations by name/location or discover places using total group budget, duration, origin, interests, group size, transport and month/dates. Show destination guidance and relevant eligible agency packages automatically.
2. **Travel Package Marketplace:** Multiple approved agencies may list offers for the same destination. Travelers browse/filter/compare agency, itinerary, duration, group total, inclusions, exclusions, origin and availability. Eligible published offers enter organic matching results without manual featured assignment.
3. **Smart Trip Planning:** Explore destination information, estimate component budgets, generate/edit itineraries, save trips and compare the same group/date assumptions against actual agency packages. Clearly distinguish estimates from agency prices.

### 1.3 Roles

| Role          | Capabilities                                                                                                                                                                                                          |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Traveler      | Explore/search without login, compare packages, use Finder and planner, submit inquiries, open contacts/booking links; save/favorite/share with an account                                                            |
| Travel Agency | Onboard company, manage its own profile, view/request subscription changes, author packages/revisions, maintain prices/itinerary/availability, publish when eligible, handle its own inquiries and entitled analytics |
| Ghumne Admin  | Approve/suspend agencies, manage destinations, review/unpublish listings, control plans/subscriptions, manage labeled featured placements, inspect freshness and oversee marketplace activity                         |

These are capabilities, not client-editable profile labels. An agency member can also plan personal travel. Trusted role grants plus agency membership determine access. Admin access is assigned through a controlled process, never self-sign-up.

### 1.4 Mandatory business rules

- Consumer usefulness, truthful data, mobile usability and accessibility remain central. Ghumne works with zero agency packages.
- Never invent real agencies, live package prices, availability, reviews or ratings.
- One destination can have packages from many agencies; one package can visit many destinations.
- Agencies manage only their own company data, drafts, subscriptions, inquiries and analytics. Travelers own their saved content.
- Public eligibility requires an approved active agency, a current publishing subscription, an approved published revision and valid pricing. Date/seat compatibility additionally requires applicable confirmed availability. Enforce eligibility on every public surface, including direct links and caches.
- Eligible offers appear automatically in matching organic results. Subscription tier does not secretly boost organic rank.
- Budget means the **total for all selected travelers** by default. Explicit per-person input must be converted before matching.
- Calculate whole-group package charges and mandatory fees using explicit units. Unknown/excluded costs and unconfirmed dates are visible.
- Sponsored placements use a visible **Sponsored** text label on every placement. Sponsorship never bypasses matching or eligibility.
- Plans may limit published listings, analytics and promotional privileges. A subscription record does not imply payment integration.
- An agency may keep its booking website. Initially use inquiry forms, WhatsApp and validated external links; no claim that Ghumne reserves seats or confirms bookings.
- No exact package match: show labeled alternatives explaining mismatches and offer a self-planned itinerary. Never silently relax constraints.

### 1.5 MVP scope

**Public:** Homepage, destination directory/details, package directory/details, public agency profiles, unified destination/package search, Smart Trip Finder, exact/alternative/no-inventory states, group-price comparison, estimated budgets, suggested itineraries and contact actions.

**Traveler:** Email authentication/reset, profile, favorites, saved/editable trips and revocable unlisted sharing. Google authentication is optional after configuration review.

**Agency:** Company onboarding/profile, approval and subscription status, entitlement/change-request view, package drafts/revisions, itinerary, price rules, availability, review/publication flow, inquiry inbox/status and plan-gated analytics.

**Admin:** Destination/attraction/activity/transport/cost/season CRUD, freshness, agency approval, package review, plan versions, manual subscription assignment/renewal/suspension, listing limits, sponsored placements and audit history.

**Conversion:** Inquiry acknowledgement, agency inbox, WhatsApp and external booking actions. Automated email/SMS or external message delivery needs a separate decision; an inquiry is not a booking.

### 1.6 Out of MVP

No payment collection, checkout, automated subscription billing, escrow, settlement, refunds, commissions, booking engine, inventory reservations, airline/hotel/vehicle inventory, microservices, native apps, social feed, loyalty or cryptocurrency. No dependency on paid maps, AI or analytics. Agency subscriptions and labeled featured placements are now MVP scope, but commercial terms remain unapproved.

### 1.7 Metrics

Measure Finder completion, destination/package engagement, comparisons, trip creation/save/share, returning travelers, inquiry conversion and website/WhatsApp clicks. Track agency activation, review turnaround, eligible listing count and freshness. Separate organic/sponsored attribution. Do not infer confirmed sales or bookings from clicks/inquiries or market an undefined AI score.

## 2. Data strategy

### 2.1 Destination knowledge

Start with approximately 15-25 researched destinations across city, culture, nature, weekend and trekking categories. Candidates include Pokhara, Chitwan, Bandipur, Mustang, Manang, Rara, Ilam, Nagarkot, Janakpur, Lumbini and Kathmandu Valley trips. This is editorial scope, not a claim that current data exists or is verified.

Support name/slug, province/district/region, coordinates, overview/descriptions, licensed hero/gallery images, suggested duration, difficulty/accessibility, traveler types, interests, seasons, getting there, travel-time ranges, estimated costs, attractions, activities, accommodation/food guidance, packing, safety/permit notes, publish state and source/verification metadata.

Prefer official tourism/local-government/park information, transport operators, direct agency confirmations and manual verification. Crowdsourced content is supplementary. No external data service is selected.

### 2.2 Estimates versus agency claims

Planning data uses low/high cost components with explicit units: per-person/vehicle transport, per-room/night accommodation and occupancy, food per-person/day, activities, permits and contingency. Never store one misleading destination trip price. Travel times are origin/mode ranges, not guaranteed road arrival times.

Agency price rules are commercial claims for a specific package revision, group and validity period. Availability is agency-reported and timestamped. Platform approval is not a price, inventory or service guarantee.

Dynamic destination data, price rules and availability carry verification/source context and timestamps. Show appropriate confirmation context publicly. Admin can identify stale records. The provisional V1 package/availability reconfirmation interval is 30 days, enforced against the exact published revision; absent/expired confirmation is never treated as confirmed availability. Material changes still require moderation.

Seasonality records store month, documented editorial suitability category, weather/crowding/monsoon/access notes and verification. Do not imply live weather or scientific precision.

### 2.3 Development and launch data

Synthetic agencies/packages/prices are restricted to isolated test/development fixtures with conspicuous demo labels and no production publishing path. Launch inventory requires real agency consent, reviewed agency-supplied prices/dates and licensed media. Zero inventory is an acceptable honest state.

## 3. Search, matching, pricing and planning

### 3.1 Shared search contract

Destination search and Finder normalize destination/query, origin, `budget_total_minor`, currency, travelers, days/nights, exact dates or month, interests, transport and travel style. Nepal travel dates use `Asia/Kathmandu` calendar dates; subscription/publish timestamps use UTC instants. Validate positive integer travelers/days, date order and consistency between dates and duration.

One deterministic package eligibility/matching service serves search, destination details, Finder and plan comparison. Results distinguish destination recommendations, organic exact package matches, labeled alternatives and sponsored placements. A destination recommendation does not imply an agency offer exists.

### 3.2 Eligibility and exact matching

Apply these checks before ranking/promotion:

1. Agency is approved/active, subscription permits publishing now, listing quota is resolved, package has a published approved revision, and associated destination content is public.
2. Destination associations satisfy explicit destination selection. Multi-stop offers explain which requested place they visit; a stop is not represented as the whole trip.
3. Travelers fit package min/max and one price-rule tier. Requested days match fixed duration; flexible duration is not inferred.
4. Origin matches the selected departure location, or the traveler explicitly accepts another origin. Unknown transfers/time/cost are not silently included.
5. A calculable full-group quote fits total budget/currency. Unknown mandatory fees or necessary excluded expenses prevent claiming the entire trip fits the budget.
6. Exact dates match a confirmed fixed departure or operating window covering the whole trip, with sufficient agency-reported capacity and valid applicable pricing. Month searches show actual departures/windows within that month; they do not confirm the traveler's unspecified dates.
7. Package interests overlap the selected interests (V1: at least one, with explanation). Explicit must-have filters remain strict. Transport/style preferences are strict when marked required, otherwise explained ranking factors.

No dates supplied means availability is **not checked**: label preference matches "Choose dates to confirm availability". Missing, stale, `on_request`, closed or sold-out availability, or unknown remaining capacity, cannot qualify as exact available matches. Search/inquiry never holds seats; travelers reconfirm with the agency.

### 3.3 Ranking and alternatives

Use transparent deterministic relevance factors and stable tie-breakers. Explain budget/duration/interests/origin fit. Subscription tiers do not affect organic rank.

Alternatives can relax budget, duration, destination, origin, interests or date preferences only with reasons such as "One additional day", "Over your group budget" or "Dates require agency confirmation". Never relax approval, subscription, moderation or tenant isolation. Closed/sold-out offers are not available alternatives. Unpriced/on-request offers, if shown, are separate and cannot claim affordability.

No exact match always offers changed filters and a self-planned itinerary. Sponsored candidates use the same eligibility checks and exact/alternative category, with their own label and placement. Promotional entitlement cannot insert mismatched offers among exact matches.

### 3.4 Package group prices

Store integer minor units plus currency; initially NPR (100 minor units per rupee). No floating point arithmetic or implicit currency conversion. `price_from` may be derived for display but is never the matching source of truth.

A price rule defines nonoverlapping travel-date and traveler scopes, one basis (`per_person` or `per_group`), base amount, sales validity/verification and fee components. A group-tier rate is a rule for an interval, not another multiplier. V1 uses a uniform traveler rate; child/room-specific offers require an explicit supported model before publication.

`group_total = base_amount * (travelers if per_person else 1) + sum(mandatory_fee_amount * fee_quantity)`

Fee quantities specify per-person/per-group and per-trip/day/night basis. Avoid double-counting included fees. Quantify taxes/mandatory charges; unknown required charges mean "Quote required". Itemize optional extras and exclusions. Unknown necessary whole-trip exclusions prevent certifying total-trip budget fit even when package charges are known.

Synthetic arithmetic example only: NPR 5,000 per person for 3 travelers plus NPR 600 per group = NPR 15,600. NPR 12,000 per group remains NPR 12,000 for a group within the tier. Out-of-tier, overlapping, expired or missing rules cannot yield an automatic quote.

Recalculate server-side at comparison/inquiry time. Snapshot inputs, price revision, components, exclusions, computed time and confirmation status. Historical snapshots are not price locks or booking confirmations.

### 3.5 Self-planned estimates and itinerary

Estimate low/high totals from transport + accommodation + food + activities + permits + contingency. Multiply by actual units; shared rooms/vehicles use required units (ceiling of travelers / occupancy), not blindly traveler count. Distinguish days/nights, return/one-way and group/person costs. Missing components make an estimate incomplete, never zero by default.

Display group ranges, source dates, assumptions and uncertainty. Generate itinerary suggestions from structured content, permit editing/reordering and save owned trips. Compare packages/plans using the same group, origin, dates and duration, explaining differences in inclusions/exclusions.

### 3.6 AI later

Start with pure deterministic pricing/matching. Later AI can interpret natural language or phrase/summarize verified content. It cannot invent agencies, prices, inventory, permits, travel times, road conditions or safety facts.

## 4. Design specification

Preserve the existing forest-green/warm-neutral semantic tokens, restrained clay accents, system typography and accessible shared controls. Use clean, trustworthy, image-rich, Nepal-inspired mobile-first pages without crowded brochure styling.

- Homepage: destination/package search, Finder, real eligible offers when present, seasonal/weekend/budget discovery, interests and explanation of Ghumne. Honest empty inventory.
- Destination cards: image, name/location, suggested duration, labeled estimated group budget and tags/season context.
- Destination detail: overview, best time, transport, estimates, attractions/activities, itinerary, stay/food guidance, packing/permit/safety notes, location context and automatically matched packages.
- Package cards/details: agency, stops, duration/origin, group total and basis, inclusions/exclusions, dates/availability and confirmation time, compare/inquire/WhatsApp/external booking actions. Every sponsored placement has a text label.
- Finder: destination suggestions, exact offers, separate alternatives and self-planning path. Preserve filters on errors/no results.
- Planner: summary, ordered itinerary, transport, accommodation, activities, notes, estimated range and package comparison.
- Agency workspace: approval/subscription status, remaining allowance, publication requirements, draft/published revisions, prices, availability, inquiries and entitled analytics.
- Admin: content CRUD, review reasons, subscription controls, placement periods, freshness and audit history.

Semantic HTML, headings, keyboard use, visible focus, labels, useful alt text, sufficient contrast and reduced motion are mandatory. Target 44px controls, no horizontal overflow, mobile filters and optimized images. Reuse existing loading/error/empty/success primitives. Never expose internal errors or link to unfinished routes, fake contacts, ratings or policies.

## 5. Technical architecture

Keep the existing Next.js App Router, React, strict TypeScript, Tailwind, Zod, Vitest and Supabase SSR clients. Runtime versions are preserved. Playwright/axe and a PostgreSQL WebAssembly parser are development-only additions for the authorized verification. Planned persistence is Supabase PostgreSQL/Auth/Storage. No live application schema or auth flow exists yet. Feedback E2E is implemented; full product E2E and production hosting remain later work.

Use one modular monolith, Server Components by default, thin Server Actions/Route Handlers, centralized request-scoped data access and pure matching/pricing services. No speculative dependencies. Maps can start with sourced coordinates/external links; no paid maps, analytics, billing, AI or messaging is assumed.

`ARCHITECTURE.md` maps current versus planned folders. Extend feature boundaries with packages, pricing, availability, subscriptions, search, moderation, promotions and analytics when needed. Keep traveler, agency and admin workspaces distinct. Reuse existing `components/partner` without a cosmetic directory rename.

Use one shared public eligibility predicate/projection, tenant-scoped agency queries and verified admin operations. Publication/quota/subscription transitions are transactional. Server checks complement RLS. Private content is never publicly cached. Public caches cannot outlive subscription/price/availability/placement expiry; invalidate on affected mutations. Eligibility is evaluated at reads and important writes, not solely by scheduled jobs.

## 6. Planned database entities and relationships

**Logical design plus unapplied SQL drafts.** Nine ordered migration files and a guarded pgTAP test bundle now exist in `supabase/`; SQL/procedure syntax and static security contracts pass locally. No migrations or database tests were executed and no application tables/data were created. [DATABASE_IMPLEMENTATION_REVIEW.md](DATABASE_IMPLEMENTATION_REVIEW.md) describes the physical design, tests and outstanding runtime risks. Generate types only from the subsequently approved, applied and verified schema.

Use UUID primary keys except composite joins. Mutable records have timestamps. Enforce foreign keys, same-tenant ownership, nonnegative integer money, valid intervals and unique keys in PostgreSQL. Use UTC instants and Nepal calendar dates as specified above.

### 6.1 Identity and tenant ownership

| Entity               | Key fields and relationships                                                                                                                                                                                   |
| -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `profiles`           | `id -> auth.users.id`, display name/avatar; no self-editable authorization field. Private profile is not public agency contact data.                                                                           |
| `user_roles`         | `(user_id, role)` grants: traveler/agency/admin. Controlled signup can grant traveler; agency/admin grants are not self-assigned.                                                                              |
| `agencies`           | Name, unique slug, description/logo, website/public contacts/WhatsApp, approval status (pending/approved/rejected), operational status (active/suspended/archived), review reason/actor/time and verification. |
| `agency_memberships` | `(agency_id, user_id)`, membership role/status. Proposal: one active owner initially, staff later. Controlled ownership creation/transfer; active membership and capability required.                          |

Onboarding creates agency capability/membership through controlled operations, never automatic approval. Members cannot update their role grants, agency approval, suspension or ownership through profile forms. Private verification evidence, if required, stays admin-scoped.

### 6.2 Destination knowledge

| Entity                               | Key fields and relationships                                                                                                                                                                              |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `locations`                          | Normalized Nepal places/origins, names/slugs/aliases, geography/coordinates; shared by routes/packages/search. An origin need not be a published destination.                                             |
| `destinations`                       | Unique slug, optional location FK, descriptions/geography/coordinates, min/max days, difficulty/traveler types, packing/permit/safety/stay/food notes, publish and verification metadata.                 |
| `destination_media`                  | Destination FK, path/URL, alt text, credit/license/source, hero/gallery role/order.                                                                                                                       |
| `interests`, `destination_interests` | Unique interest slugs; destination/interest composite join with documented editorial weight.                                                                                                              |
| `destination_seasons`                | Destination FK, month 1-12, suitability/access/weather notes, verification; unique destination/month.                                                                                                     |
| `attractions`, `activities`          | Destination FKs, descriptions, coordinates/duration where applicable, cost ranges/currency/unit, publish and verification metadata.                                                                       |
| `transport_routes`                   | Origin location FK, destination FK, mode, time/cost ranges, person/vehicle basis, capacity, one-way/return assumption, verification/notes.                                                                |
| `destination_costs`                  | Destination FK, component category, min/max amount/currency, person/group/room/vehicle unit, trip/day/night frequency, occupancy/capacity, validity/source. Replaces ambiguous flat accommodation fields. |

### 6.3 Subscriptions

| Entity                         | Key fields and relationships                                                                                                                                                         |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `subscription_plans`           | Stable code/name and active status; commercial terms not invented.                                                                                                                   |
| `subscription_plan_versions`   | Plan FK/version, can_publish, max_published_packages, analytics capability, promotional eligibility/allowance. Immutable once assigned; null unlimited differs from zero disallowed. |
| `agency_subscriptions`         | Agency FK, plan-version FK, pending/active/suspended/expired/cancelled, start/end instants, admin actor/reason. No payment or commission integration.                                |
| `subscription_change_requests` | Agency FK, requested plan-version/term, requester, pending/approved/rejected status, admin reviewer/reason/time. A request never activates entitlement by itself.                    |

At most one effective publishing subscription per agency at any instant; prevent overlapping effective periods. Eligibility requires active status and `starts_at <= now < ends_at`. Admin initially activates/renews manually; agencies can request changes but cannot grant entitlement. V1 supports free pilot, monthly and annual models with configurable immutable prices/entitlements. Monthly/annual periods use one Nepal calendar month/year; pilot duration is explicit admin input. Final names, fees, limits, trials and grace terms remain open.

Provisional expiry/downgrade behavior: immediately hide ineligible packages, retain all data, resolve over-limit published selections before activation. No automatic grace, arbitrary deletion or hidden grandfathering. Expiry never deletes agency records. Commercial grace/renewal policy remains a final decision.

### 6.4 Packages, moderation, pricing and availability

| Entity                                              | Key fields and relationships                                                                                                                                                                                                                              |
| --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `packages`                                          | Agency FK, unique `(agency_id, slug)`, draft/published/paused/archived state, published_revision_id and publication timestamps. Public route includes agency slug.                                                                                        |
| `package_revisions`                                 | Package/agency FKs, version, draft/pending_review/approved/rejected, title/descriptions, days/nights, min/max travelers, transport/style, booking URL, inclusions/exclusions, media, verification, reviewer/reason/time. Approved versions are immutable. |
| `package_destinations`                              | Revision/destination join, stop order and primary/visit role. Many-to-many; never unique on destination across agencies.                                                                                                                                  |
| `package_origins`, `package_interests`              | Revision/location and revision/interest joins. Missing data is unknown, not an automatic match.                                                                                                                                                           |
| `package_media`                                     | Revision/agency FK, ordered HTTPS URL, alt text, credit/license; approved media metadata is immutable with its revision. Storage uploads remain a separate implementation.                                                                                |
| `package_itinerary_days`, `package_itinerary_items` | Revision -> ordered days -> ordered items; unique day/order within parent; typed destination/activity references where needed.                                                                                                                            |
| `package_price_rules`                               | Revision FK, person/group basis, amount/currency, traveler interval, travel-date scope or explicit undated scope, sales validity and verification. Optional departure-specific rule belongs to the same revision.                                         |
| `package_price_components`                          | Rule FK, label/category, amount, unit/frequency, included/mandatory/optional classification. Required unpriced exclusions make quote incomplete.                                                                                                          |
| `package_availability`                              | Revision FK, fixed-departure/operating-window type, start/end local dates, open/on_request/closed/sold_out, capacity/remaining travelers when known, confirmation/source/time.                                                                            |

The published pointer references an approved revision belonging to the same package/agency. Child rows carry or derive tenant ownership; composite foreign keys prevent cross-agency references. Draft edits do not mutate the published revision. Material content/price edits create a reviewable revision; availability can be refreshed separately, timestamped/audited, without rewriting price terms.

Quota counts published packages, not draft revisions. Publication checks and transitions are atomic under an agency lock. Review approval alone does not publish, activate subscription or override suspension. Require complete public fields and a valid pricing path to publish; confirmed dated matching additionally needs valid availability. Reject ambiguous overlapping price scopes and availability rows.

### 6.5 Traveler plans and comparison

| Entity                     | Key fields and relationships                                                                                                                                                                     |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `trips`                    | Owner FK, primary destination FK, title/origin location FK, days/nights, travelers, total budget/currency, optional dates, private/unlisted visibility, versioned estimate snapshot/assumptions. |
| `trip_days`, `trip_items`  | Trip -> ordered days/items, title/notes/time, quantities/units/estimated ranges; explicit destination/attraction/activity FKs or user text instead of unenforced polymorphic reference_id.       |
| `favorites`                | Composite user/destination FK, created time.                                                                                                                                                     |
| `trip_shares`              | Trip FK, hashed unguessable token, expiry/revocation. Safe read-only projection excludes contacts/private notes; trip UUID alone is not permission.                                              |
| `trip_package_comparisons` | Owner/trip FK, package/revision FKs, selected availability/rule, input/quote/estimate snapshots, computed time/version and mismatch reasons. Revalidate live eligibility/quote on reopening.     |

### 6.6 Inquiries, promotion and oversight

| Entity                | Key fields and relationships                                                                                                                                                                                                        |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `inquiries`           | Package/revision/agency FKs with tenant consistency, optional traveler FK, contacts/consent, travelers/dates/message, quote/input snapshot, new/contacted/closed status and timestamps. Agency is derived server-side from package. |
| `featured_placements` | Package/agency FKs, surface, start/end instants, admin status/approval, label fixed to Sponsored, entitlement allocation. Recheck eligibility and allowance when serving.                                                           |
| `marketplace_events`  | Minimal event/time, package/revision/agency/placement references, organic/sponsored source, short-lived deduplication context. No contacts/message bodies or implied bookings.                                                      |
| `audit_logs`          | Actor, tenant/target/action, reason, safe change metadata/time for roles, approvals, subscriptions, reviews, price, availability, publishing and placement. Trusted append operations only.                                         |

Inquiry creation uses server validation, durable abuse controls and a narrow database write path. Guests cannot browse or insert arbitrary rows/tenant/status fields. Travelers can read their own inquiries; owning agencies update workflow status without rewriting identity/submission/quote history. No inquiry sends an external message automatically.

### 6.7 Relationship summary

- auth.users -> profiles -> user_roles / agency_memberships -> agencies.
- agencies -> agency_subscriptions -> subscription_plan_versions -> subscription_plans.
- agencies -> packages -> package_revisions -> destinations / origins / interests / itinerary / prices / availability.
- profiles -> trips -> days -> items; trips -> comparisons -> package revision.
- package + agency + optional traveler -> inquiries; packages -> featured placements / events.

### 6.8 Integrity, indexes and RLS

Enforce same-tenant composite FKs, unique slugs/joins, ordered children, positive group/duration counts, month/coordinate bounds and ordered nonnegative ranges. Exclude ambiguous pricing scopes and overlapping subscriptions. Validate state transitions and ownership in transactional operations.

Index tenant/status, package/publication/revision, destination/interest/origin joins, durations/group ranges, price/availability dates, subscription periods, agency inquiry status/time and placement surface/period. Add search indexes from measured query plans, not a paid search dependency.

RLS and least-privilege grants cover every application table, including public catalog/lookup tables. Anon reads published destination and eligible agency/package projections only. Drafts, memberships, subscriptions, private contacts, raw events and audits are not public. Traveler policies cover owned profile/favorites/trips/children/comparisons/shares. Agency policies require active membership and field-sensitive mutation paths. Admin policies use trusted grants, never self-editable metadata.

Public views/functions must preserve RLS/eligibility and expose safe columns. Review privileged function search paths and execution grants. No browser service-role access. Storage mirrors owner/tenant restrictions; approved public media is separate from private verification documents. Schema application requires RLS, constraints, grants and tests together, never temporarily unprotected tables.

## 7. Server interfaces

Use Server Actions for mutations and Route Handlers for explicit endpoints/callbacks. Public services cover destination/agency/package reads, unified search, matching, group quotes, estimates and safe shared plans. Traveler services cover favorites, owned trip CRUD/reordering/sharing/comparison and inquiries. Agency services cover owned onboarding/profile/revisions, review requests, publishing, availability, subscription change requests, inquiry workflow and entitled analytics. Admin services cover destination data, review/approval/suspension, plan assignments, placements, freshness and audit inspection.

Each operation validates with Zod, verifies identity when applicable, role/tenant/field permissions, calls RLS-protected or narrow transactional data access and returns a safe typed result. Never trust client role, agency ID, quote, quota or entitlement. Recheck quote and eligibility at inquiry time; use retry/idempotency handling for duplicate submissions and publication races.

## 8. Security and privacy

Use Supabase Auth with verified server identity. Existing SSR factories are infrastructure only: wire refresh through `src/proxy.ts` before authenticated rendering, preserve cookies/cache headers, and add feature authorization/RLS. Keep `.env.local` uncommitted and privileged credentials out of browser configuration. Retain the existing modern publishable-key validation boundary.

Safely render content, validate URL protocols, restrict upload type/size/path and disallow executable HTML. Inquiry writes need durable rate limiting/spam controls, deduplication and contact consent. Do not log raw contacts/messages/tokens. Private notes/contacts never enter public shares or analytics. Retention periods, verification evidence and consent wording require policy approval before launch.

## 9. SEO and discovery

Use crawlable destination/package content, semantic HTML, metadata, canonicals, sitemap, robots.txt, Open Graph, breadcrumbs, meaningful links, alt text and fast images. Agency-scoped package routes avoid slug collisions. Exclude private dashboards, drafts, internal preview and share tokens from indexing. Structured data describes real published content only; no invented reviews, availability, FAQs or bookable offers. Expired/unpublished direct routes must honor eligibility.

## 10. Verification plan

**Unit:** Group/person/tier pricing, mandatory fees, integer money, day/night/occupancy units, missing data/expiry; origin/duration/interests/date/month matching; exact/alternative categories; estimate/scoring/explanation/validation. Fixtures are explicitly synthetic.

**Database/integration:** Approved local/test project with anon, traveler A/B, agency A/B and admin. Test RLS, cross-tenant child/FK attacks, protected fields, draft leakage, expiry/downgrade, concurrent quotas, immutable revisions, overlapping price/subscription scopes, inquiry tenant derivation/privacy, share revocation and promotion allowance. Mocked clients do not prove RLS.

**Critical E2E:** Search/Finder -> automatic relevant package -> group quote -> inquiry in owning inbox; approved subscribed agency -> draft/review/publish -> organic visibility without manual placement; unapproved/suspended/expired/over-limit agency blocked; no exact match -> alternative/self-plan -> save/compare; traveler save/edit/share/revoke; Sponsored label and expiry behavior.

**Gates:** Formatting, lint, strict types, relevant tests and production build. Changed UI needs mobile/desktop, keyboard, loading/error/empty and accessibility checks. Real integration needs configured authorized test infrastructure. Passing tests does not approve migrations, services or deployment.

## 11. Implementation rules

Read existing source and instructions first. Preserve working foundation, strict types and semantic UI. Separate domain logic/data access/presentation. Avoid duplicate utilities, broad rewrites, speculative dependencies, unrelated future work or undocumented any.

Draft migrations/RLS together. Never apply migrations, delete data or introduce paid services without approval. Keep fixtures apart from live data. The task list is not automatic deployment authorization.

For each coding task: understand -> plan -> implement -> test -> review -> document -> focused commit when user scope/permissions permit. A feature is done when behavior, validation/access, tests, responsive/accessibility checks and completion record are complete. Documentation-only work does not authorize the next coding task.

## 12. Decisions and approval register

Product decisions DEC-001 through DEC-006 originated here. History and revision decisions are in `DECISIONS.md`.

- DEC-001 superseded by DEC-015: replace secondary-marketplace sequencing with three core experiences and early marketplace foundations; retain consumer usefulness.
- DEC-002 retained: agency websites may remain booking destinations.
- DEC-003 retained: deterministic recommendations from structured data first.
- DEC-004 expanded: no payment processing, automated billing or commissions; inquiry/contact conversion.
- DEC-005 retained: modular monolith.
- DEC-006 retained: structured travel data with verification/freshness.

Already directed by the user: core marketplace, multiple agency offers per destination, approved subscribed publishers, automatic matching, whole-group prices, tenant isolation, labeled sponsorship, no invented live data, no payments/commissions.

| Pending decision     | Proposed starting point requiring approval before dependent live behavior                                                                                                          |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Commercial plans     | Pilot/monthly/annual configurable versions are provisional V1. Final names, fees, limits and pilot/grace terms remain open.                                                        |
| Expiry/downgrade     | Preserve all data; immediate loss of eligibility and resolving excess listings are V1 assumptions. Final grace/renewal terms remain open.                                          |
| Agency/review policy | Free registration, manual approval, moderation and 30-day reconfirmation are provisional V1. One owner is an assumption; evidence, appeals and transfer rules remain open.         |
| Pricing/date scope   | NPR/person/group pricing is provisional V1; reviewed group-tier reductions and rejection of unsupported discounts are confirmed for preparation. Child/room/coupon/percentage-discount expansion remains open. |
| Sponsorship          | Separate labeled placements preserving eligibility/relevance; define allowance/allocation/duration/commercial terms before activation.                                             |
| Privacy/operations   | Minimal collection, configurable retention categories and disabled-by-default inquiries are prepared. Final periods, consent, evidence handling and cleanup execution remain open. |
| Database application | Review final migrations/RLS, designate local/test project and obtain explicit permission before application; production separately approved.                                       |

The owner's V1 provisional rules supersede earlier unresolved-policy wording: free registration/manual approval, moderated changes, 30-day reconfirmation, NPR/group pricing, inquiry/contact conversion, free pilot/monthly/annual configurable subscriptions, preserved data on expiry, labeled sponsorship and relevance-first organic results. See [V1_BUSINESS_POLICIES.md](V1_BUSINESS_POLICIES.md) for assumptions and final commercial decisions. No response is assumed to approve a final commercial proposal. This request stops after SQL/test preparation and reporting, before database execution.

## 13. Revised implementation sequence

Keep historical IDs and completed work. Reorder unstarted tasks by dependency; moving a task never completes it. `[ ]` not started, `[~]` in progress, `[x]` complete, `[!]` blocked. This is the new order; `PROGRESS.md` records evidence/mapping.

### Phase A - Preserve foundation and reconcile direction

- [x] TASK-001 Original repository audit (historical baseline)
- [x] TASK-002 Next.js App Router + TypeScript
- [x] TASK-003 Tailwind/global styling
- [x] TASK-004 Lint/format/type checks
- [x] TASK-005 Environment template/validation
- [x] TASK-006 Supabase clients (local scope; live verification pending)
- [x] TASK-007 Folder architecture
- [x] TASK-008 Design tokens
- [x] TASK-009 Typography
- [x] TASK-010 Buttons/links
- [x] TASK-011 Form controls
- [x] TASK-012 Cards/badges
- [x] TASK-013 Responsive header/navigation
- [x] TASK-014 Footer
- [x] TASK-124 Audit current code and reconcile marketplace product/data/architecture/plan docs
- [x] TASK-015 Verify feedback components, accessibility/reflow, tests and completion record
- [x] TASK-125 Establish provisional V1 policies and record final commercial decisions still open

### Phase B - Reviewable database and tenant foundation

- [x] TASK-016 Draft initial identity/schema migration; do not apply
- [x] TASK-018 Draft destination/location/cost/media schema
- [x] TASK-019 Draft traveler/trip/favorite/share/comparison schema
- [x] TASK-087 Draft agency/membership schema and ownership policies (moved forward)
- [x] TASK-126 Draft plan/version/subscription/change-request schema
- [x] TASK-127 Draft package/revision/price/itinerary/availability schema
- [x] TASK-128 Draft inquiry/promotion/event/audit schema
- [x] TASK-020 Draft indexes, constraints and transactional tenant/state integrity
- [x] TASK-017 Draft RLS/grants/protected fields alongside all schema drafts
- [ ] TASK-021 Isolated development fixture/seed system
- [ ] TASK-129 Review bundle, obtain permission and apply only to designated local/test database
- [ ] TASK-130 Generate database types and run live database/RLS/constraint tests
- [ ] TASK-022 Verified destination dataset with source/license evidence; no fake agency inventory

016/018/019/087/126-128 are one design bundle with 017/020. Their completion marks **local authoring/static validation only**. No SQL is applied or live RLS certified. Owner review/application approval remains TASK-129, followed by generated types and actual database tests in TASK-130. Development seed/import tooling and real destination data remain unfinished.

### Phase C - Identity and access

- [ ] TASK-055 Supabase Auth and session-refresh proxy wiring
- [ ] TASK-056 Sign-up
- [ ] TASK-057 Login
- [ ] TASK-058 Logout
- [ ] TASK-059 Callback/reset
- [ ] TASK-060 Traveler profile/controlled role grants
- [ ] TASK-061 Server-protected routes
- [ ] TASK-077 Admin authorization (moved ahead of operations)
- [ ] TASK-131 Agency membership guards and cross-tenant access tests

### Phase D - Content operations and marketplace supply

- [ ] TASK-078 Admin dashboard
- [ ] TASK-079 Destination CRUD
- [ ] TASK-080 Attraction CRUD
- [ ] TASK-081 Activity CRUD
- [ ] TASK-082 Transport CRUD
- [ ] TASK-083 Cost data CRUD
- [ ] TASK-084 Seasonality CRUD
- [ ] TASK-085 Destination publishing
- [ ] TASK-086 Freshness view
- [ ] TASK-088 Agency onboarding
- [ ] TASK-089 Owned company profile editor
- [ ] TASK-132 Agency approval/suspension and audit history
- [ ] TASK-133 Admin plan/subscription controls and agency entitlement/change-request view
- [ ] TASK-091 Owned package draft/revision CRUD
- [ ] TASK-092 Multi-destination/origin/interest associations and itinerary
- [ ] TASK-134 Review/publication/quota/expiry transitions
- [ ] TASK-135 Group-price rule/fee/quote service and tests
- [ ] TASK-136 Availability management and date compatibility tests

### Phase E - Public discovery, offers and inquiries

- [ ] TASK-023 Homepage shell for three core experiences
- [ ] TASK-027 Destination card before its directory consumer
- [ ] TASK-024 Destination directory
- [ ] TASK-025 Destination search
- [ ] TASK-026 Destination filters
- [ ] TASK-028 Destination details
- [ ] TASK-029 Attractions
- [ ] TASK-030 Activities
- [ ] TASK-031 Transport
- [ ] TASK-032 Budget section (computed totals depend on Phase F engine)
- [ ] TASK-033 Season/best time
- [ ] TASK-034 Packing/travel notes
- [ ] TASK-035 Map/location abstraction without paid provisioning
- [ ] TASK-090 Public approved agency profile
- [ ] TASK-137 Eligible public package directory/detail and package comparison
- [ ] TASK-094 External booking/website action
- [ ] TASK-095 WhatsApp/contact action
- [ ] TASK-096 Inquiry form
- [ ] TASK-097 Inquiry validation/consent/deduplication/durable spam controls
- [ ] TASK-098 Secure storage with quote snapshot and derived tenant
- [ ] TASK-099 Agency inquiry inbox
- [ ] TASK-100 Inquiry workflow/status

Inquiry form/storage/abuse controls release together. Public pages may show sourced estimate data before the engine; computed totals depend on Phase F. Search is not release-complete until automatic matching in Phase F.

### Phase F - Budget engine and automatic matching

- [ ] TASK-048 Transport calculation with units/capacity
- [ ] TASK-049 Accommodation/occupancy/nights
- [ ] TASK-050 Food
- [ ] TASK-051 Activities/permits
- [ ] TASK-052 Contingency
- [ ] TASK-053 Estimate ranges/assumptions
- [ ] TASK-054 Budget regression tests
- [ ] TASK-036 Finder form
- [ ] TASK-037 Input normalization/validation including group budget
- [ ] TASK-038 Budget compatibility using tested estimate/quote services
- [ ] TASK-039 Duration matching
- [ ] TASK-040 Season/month/date matching
- [ ] TASK-041 Interest matching
- [ ] TASK-042 Origin/transport matching
- [ ] TASK-043 Destination scoring
- [ ] TASK-044 Match explanations
- [ ] TASK-138 Shared public package eligibility/matching/ranking
- [ ] TASK-139 Unified destination/package search integration
- [ ] TASK-093 Automatic packages on destination pages
- [ ] TASK-045 Finder results with destinations and agency offers
- [ ] TASK-046 Labeled alternatives/no-inventory/self-plan fallback
- [ ] TASK-047 Matching regression unit tests
- [ ] TASK-140 Admin featured placements/allowances and Sponsored labels
- [ ] TASK-144 Public cache expiry/invalidation across marketplace state changes

Pricing/matching tests are implemented with their services; regression tasks do not defer correctness checks. No public search release before 138/139/093 integrate automatic matching.

### Phase G - Saved plans and plan/package comparison

- [ ] TASK-062 Favorite destination
- [ ] TASK-063 Remove favorite
- [ ] TASK-064 Saved destinations
- [ ] TASK-065 Ownership/RLS regression tests
- [ ] TASK-066 Create trip from recommendation/destination
- [ ] TASK-067 Trip overview
- [ ] TASK-068 Day-by-day itinerary
- [ ] TASK-069 Add/edit/remove item
- [ ] TASK-070 Reorder items
- [ ] TASK-071 Estimated budget integration
- [ ] TASK-072 Save trip
- [ ] TASK-073 Owned trip deletion feature (implementation does not authorize deleting current data)
- [ ] TASK-074 My Trips
- [ ] TASK-075 Revocable unlisted share
- [ ] TASK-141 Self-plan/saved-trip comparison against current package quotes
- [ ] TASK-076 Planner E2E

### Phase H - Analytics and discoverability

- [ ] TASK-109 Privacy-conscious first-party analytics, no paid provider assumed
- [ ] TASK-110 Finder completion events
- [ ] TASK-111 Recommendation/package selection events
- [ ] TASK-112 Trip create/save/share events
- [ ] TASK-113 Website/WhatsApp events
- [ ] TASK-114 Inquiry events
- [ ] TASK-101 Basic inquiry analytics after event dependencies
- [ ] TASK-143 Plan-gated agency analytics and admin oversight with organic/sponsored attribution
- [ ] TASK-102 Destination/agency/package metadata
- [ ] TASK-103 Sitemap
- [ ] TASK-104 robots.txt
- [ ] TASK-105 Open Graph
- [ ] TASK-106 Breadcrumbs
- [ ] TASK-107 Truthful structured data
- [ ] TASK-108 Internal linking audit

### Phase I - Acceptance and approved launch

- [ ] TASK-142 Cross-role marketplace integration/E2E acceptance
- [ ] TASK-145 Verify real launch agencies/consent/terms/inventory, or explicitly use honest empty inventory
- [ ] TASK-115 Responsive audit
- [ ] TASK-116 Accessibility audit
- [ ] TASK-117 Security/authorization/privacy audit
- [ ] TASK-118 Performance audit
- [ ] TASK-119 SEO audit
- [ ] TASK-120 Full E2E regression
- [ ] TASK-121 Approved production environment/migration verification
- [ ] TASK-122 Explicitly authorized deployment only
- [ ] TASK-123 Post-deployment smoke test

## 14. Current resumption instruction

TASK-015 and the provisional V1 policy baseline are complete. The Phase B SQL/RLS/constraint bundle and automated static/deferred integration tests are authored. Stop before executing migrations, tests that write to a database or destructive changes. Next is owner review of DATABASE_IMPLEMENTATION_REVIEW.md and explicit authorization of a designated test target before TASK-129/130. Do not automatically apply SQL, generate pretend database types, provision services, build future marketplace UI or deploy.

## 15. Future ideas and final product rule

Later candidates: natural-language AI assistance, live road/weather integrations, verified reviews, staff/multi-owner workspaces, age/room pricing, localization, collaboration, expense splitting and offline itineraries. Booking/payment/commissions require separate approval.

Ask whether a feature helps a traveler discover a destination, compare a trustworthy offer or plan a trip, and whether agencies/admin can maintain accurate supporting data. Better destination/agency data -> useful matching/comparison -> travelers/plans -> qualified inquiries -> healthier agency supply -> better discovery.
