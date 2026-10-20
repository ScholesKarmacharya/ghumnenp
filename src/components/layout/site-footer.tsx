import Link from "next/link";
import { BrandLink } from "./brand-link";

const columns = [
  {
    title: "Explore",
    links: [
      ["Pokhara Valley", "/?q=Pokhara#destinations"],
      ["Mustang", "/?q=Mustang#destinations"],
      ["Chitwan", "/?q=Chitwan#destinations"],
      ["Rara Lake", "/?q=Rara#destinations"],
      ["Bandipur Ridge", "/?q=Bandipur#destinations"],
    ],
  },
  {
    title: "Travel Packages",
    links: [
      ["Itinerary inspiration", "/#featured-packages"],
      ["Browse preview filters", "/#featured-packages"],
      ["Plan a similar journey", "/#trip-finder"],
    ],
  },
  {
    title: "For Agencies",
    links: [
      ["Publishing approach", "/#agency-process"],
      ["Ghumne for agencies", "/#for-agencies"],
    ],
  },
  {
    title: "Ghumne",
    links: [
      ["Home", "/"],
      ["Our principles", "/#principles-title"],
      ["Travel story previews", "/#travel-guides"],
      ["Personal trip brief", "/#trip-finder"],
    ],
  },
] as const;

export function SiteFooter() {
  return (
    <footer className="bg-home-inset pt-10 pb-6 text-muted">
      <div className="home-container">
        <div className="grid gap-6 pb-10 md:grid-cols-2 lg:grid-cols-5">
          <div className="space-y-4 lg:pr-4">
            <BrandLink />
            <p className="text-sm leading-relaxed">
              Travel discovery, agency package exploration, and personal trip
              planning for Nepal.
            </p>
            <p className="text-xs tracking-wider uppercase">
              A little time. A new place.
            </p>
          </div>
          <nav aria-label="Footer" className="contents">
            {columns.map((column) => (
              <div key={column.title}>
                <h2 className="mb-3 font-sans text-sm font-semibold tracking-wide text-foreground uppercase">
                  {column.title}
                </h2>
                <ul className="space-y-1">
                  {column.links.map(([label, href]) => (
                    <li key={label}>
                      <Link
                        href={href}
                        className="inline-flex min-h-control items-center rounded-sm text-sm hover:text-primary hover:underline"
                      >
                        {label}
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </nav>
        </div>
        <div className="flex flex-col justify-between gap-3 border-t border-border pt-6 text-xs md:flex-row">
          <p>
            © {new Date().getFullYear()} Ghumne. Made for journeys across Nepal.
          </p>
          <p>Editorial previews. No live bookings, quotes, or agency offers.</p>
        </div>
      </div>
    </footer>
  );
}
