"use client";

import { Button } from "@/components/ui/button";
import { ErrorState } from "@/components/ui/feedback";
import { ButtonLink } from "@/components/ui/link";

import "./globals.css";

export default function GlobalError({
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <html lang="en">
      <body>
        <main
          id="main-content"
          tabIndex={-1}
          className="mx-auto max-w-page px-gutter py-12"
        >
          <ErrorState
            headingAs="h1"
            title="Something went wrong"
            description="Ghumne couldn't load. Please try again or return to the home page."
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
      </body>
    </html>
  );
}
