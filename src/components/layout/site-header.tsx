import { BrandLink } from "./brand-link";
import Link from "next/link";
import { primaryNavigation, type NavigationItem } from "./navigation";
import { SiteNavigation } from "./site-navigation";

export function SiteHeader({
  items = primaryNavigation,
}: {
  items?: readonly NavigationItem[];
}) {
  return (
    <header className="sticky top-0 z-50 bg-background/95 shadow-[0_1px_8px_rgb(0_0_0/0.04)] backdrop-blur-xl">
      <a
        href="#main-content"
        className="sr-only focus:not-sr-only focus:absolute focus:top-3 focus:left-4 focus:z-50 focus:rounded-control focus:bg-surface focus:px-4 focus:py-3 focus:text-primary"
      >
        Skip to content
      </a>
      <div className="mx-auto flex min-h-20 max-w-home flex-wrap items-center justify-between gap-3 px-5 py-3 lg:px-12">
        <BrandLink />
        <SiteNavigation items={items} />
        <Link
          href="/#for-agencies"
          className="hidden min-h-control shrink-0 items-center rounded-control bg-primary px-5 py-2 text-sm font-semibold text-white hover:bg-primary-hover lg:inline-flex"
        >
          For agencies
        </Link>
      </div>
    </header>
  );
}
