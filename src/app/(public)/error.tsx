"use client";

import { Button } from "@/components/ui/button";
import { ErrorState } from "@/components/ui/feedback";
import { ButtonLink } from "@/components/ui/link";

export default function PublicError({
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <main
      id="main-content"
      tabIndex={-1}
      className="mx-auto max-w-page px-gutter py-12"
    >
      <ErrorState
        headingAs="h1"
        title="We couldn't load this page"
        description="Please try again. You can also return home and choose another page."
        action={
          <>
            <Button onClick={reset}>Try again</Button>
            <ButtonLink href="/" variant="secondary">
              Return home
            </ButtonLink>
          </>
        }
      />
    </main>
  );
}
