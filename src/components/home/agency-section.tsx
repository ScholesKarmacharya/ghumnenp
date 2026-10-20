import { Icon } from "./icon";

export function AgencySection() {
  return (
    <section
      id="for-agencies"
      aria-labelledby="agencies-title"
      className="relative overflow-hidden bg-primary py-10 text-white"
    >
      <div
        aria-hidden="true"
        className="pointer-events-none absolute inset-y-0 right-0 w-1/2 opacity-5"
      >
        <svg className="size-full" fill="none" viewBox="0 0 600 600">
          <path
            d="M0 300C150 200 250 400 400 300C550 200 600 350 600 350V600H0V300Z"
            fill="currentColor"
          />
          <path
            d="M0 200C120 150 200 300 350 220C500 140 580 250 600 250V600H0V200ZM0 100C180 80 280 220 420 120C520 60 580 150 600 150"
            stroke="currentColor"
            strokeWidth="2"
          />
        </svg>
      </div>
      <div className="home-container relative grid grid-cols-1 items-center gap-10 lg:grid-cols-12">
        <div className="space-y-4 lg:col-span-7">
          <p className="inline-flex rounded-control bg-white/10 px-3 py-2 text-xs font-semibold tracking-wider uppercase">
            For Nepal travel providers
          </p>
          <h2
            id="agencies-title"
            className="font-display text-[clamp(1.75rem,3vw,2.5rem)] leading-tight font-semibold tracking-tight"
          >
            Take your travel business further with Ghumne.
          </h2>
          <p className="max-w-xl text-lg leading-relaxed text-white/90">
            A dedicated home for Nepal’s travel experiences. Ghumne is being
            built to connect destination discovery, eligible agency packages,
            and thoughtful trip planning.
          </p>
          <div className="grid gap-5 pt-2 sm:grid-cols-3">
            {[
              ["Discover", "Destination-led exploration"],
              ["Connect", "Agency package discovery"],
              ["Plan", "Personal travel preferences"],
            ].map(([title, caption]) => (
              <p key={title}>
                <span className="block font-display text-[1.75rem] font-semibold text-sand">
                  {title}
                </span>
                <span className="text-sm text-white/90">{caption}</span>
              </p>
            ))}
          </div>
          <div className="flex flex-wrap gap-4 pt-2">
            <a
              href="#agency-process"
              className="home-action bg-white text-primary hover:bg-sand"
            >
              Our publishing approach
              <Icon name="arrow" />
            </a>
            <a
              href="#trip-finder"
              className="home-action border border-white/30 bg-white/10 text-white"
            >
              Explore trip planning
              <Icon name="compass" />
            </a>
          </div>
        </div>
        <article
          id="agency-process"
          className="rounded-2xl bg-white p-6 text-foreground shadow-xl lg:col-span-5"
        >
          <div className="mb-4 flex flex-wrap items-center justify-between gap-4 border-b border-border pb-3">
            <div>
              <p className="text-xs tracking-wider text-muted uppercase">
                In preparation
              </p>
              <h3 className="mt-1 font-display text-xl font-semibold text-primary">
                A considered publishing process
              </h3>
            </div>
            <Icon name="compass" className="size-8 shrink-0 text-primary" />
          </div>
          <ul className="space-y-3 text-sm leading-relaxed text-muted">
            {[
              "Agency details and supporting documents reviewed before approval.",
              "Publishing access tied to an active agency subscription.",
              "Packages reviewed before they enter public discovery.",
              "Group quotes designed to explain inclusions and required charges.",
            ].map((text) => (
              <li key={text} className="flex items-start gap-2.5">
                <Icon
                  name="check"
                  className="mt-0.5 size-4 shrink-0 text-primary"
                />
                <span>{text}</span>
              </li>
            ))}
          </ul>
          <p className="mt-5 rounded-lg bg-home-inset p-3 text-sm leading-relaxed text-muted">
            Agency onboarding is not open yet. Booking, payment collection,
            escrow, and traveler protection services are not available through
            this site.
          </p>
        </article>
      </div>
    </section>
  );
}
