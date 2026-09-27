import { TextLink } from "@/components/ui/link";

import { BrandLink } from "./brand-link";
import { primaryNavigation } from "./navigation";

export function SiteFooter() {
  return (
    <footer className="border-t border-border bg-surface">
      <div className="mx-auto grid max-w-page gap-8 px-gutter py-10 sm:grid-cols-2">
        <div className="space-y-2">
          <BrandLink />
          <p className="max-w-reading text-muted">
            Discover Nepal. Plan your trip.
          </p>
          <small className="block text-muted">
            © {new Date().getFullYear()} Ghumne
          </small>
        </div>
        <nav aria-label="Footer" className="sm:justify-self-end">
          <ul className="flex flex-wrap gap-x-6 gap-y-2">
            {primaryNavigation.map(({ href, label }) => (
              <li key={href}>
                <TextLink
                  href={href}
                  className="inline-flex min-h-control items-center"
                >
                  {label}
                </TextLink>
              </li>
            ))}
          </ul>
        </nav>
      </div>
    </footer>
  );
}
