"use client";

import { useState } from "react";

import { Button } from "@/components/ui/button";
import { ButtonLink, TextLink } from "@/components/ui/link";

export function UiPreview() {
  const [clicks, setClicks] = useState(0);
  const [submissions, setSubmissions] = useState(0);

  return (
    <div className="space-y-12">
      <section aria-labelledby="buttons-title" className="space-y-6">
        <h2 id="buttons-title">Buttons and links</h2>
        <form
          className="flex flex-wrap items-center gap-4"
          onSubmit={(event) => {
            event.preventDefault();
            setSubmissions((value) => value + 1);
          }}
        >
          <Button onClick={() => setClicks((value) => value + 1)}>
            Primary action
          </Button>
          <Button variant="secondary" type="submit">
            Submit form
          </Button>
          <Button variant="ghost">Ghost action</Button>
          <Button variant="danger">Delete example</Button>
          <Button disabled>Disabled action</Button>
          <Button isLoading loadingLabel="Saving…">
            Save example
          </Button>
          <ButtonLink href="/">Back to home</ButtonLink>
          <TextLink href="/" target="_blank" rel="external">
            Open home in a new tab
          </TextLink>
        </form>
        <p role="status">
          Clicks: {clicks}. Submissions: {submissions}.
        </p>
      </section>
    </div>
  );
}
