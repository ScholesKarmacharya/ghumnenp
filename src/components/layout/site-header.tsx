import { BrandLink } from "./brand-link";
import { primaryNavigation, type NavigationItem } from "./navigation";
import { SiteNavigation } from "./site-navigation";

export function SiteHeader({
  items = primaryNavigation,
}: {
  items?: readonly NavigationItem[];
}) {
  return (
    <header className="relative z-20 border-b border-border bg-surface">
      <a
        href="#main-content"
        className="sr-only focus:not-sr-only focus:absolute focus:top-3 focus:left-4 focus:z-50 focus:rounded-control focus:bg-surface focus:px-4 focus:py-3 focus:text-primary"
      >
        Skip to content
      </a>
      <div className="mx-auto flex min-h-20 max-w-page flex-wrap items-center justify-between gap-4 px-gutter py-3">
        <BrandLink />
        <SiteNavigation items={items} />
      </div>
    </header>
  );
}
