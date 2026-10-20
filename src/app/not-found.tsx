import type { Metadata } from "next";

import { SiteFooter } from "@/components/layout/site-footer";
import { SiteHeader } from "@/components/layout/site-header";
import { EmptyState } from "@/components/ui/feedback";
import { ButtonLink } from "@/components/ui/link";

export const metadata: Metadata = {
  title: "Page not found",
  robots: { index: false, follow: false },
};

export default function NotFound() {
  return (
    <div className="flex min-h-svh flex-col">
      <SiteHeader />
      <main
        id="main-content"
        tabIndex={-1}
        className="mx-auto w-full max-w-page flex-1 px-gutter py-12"
      >
        <EmptyState
          headingAs="h1"
          title="We couldn't find that page"
          description="The link may have changed. Return home to continue exploring."
          action={<ButtonLink href="/">Return home</ButtonLink>}
        />
      </main>
      <SiteFooter />
    </div>
  );
}
