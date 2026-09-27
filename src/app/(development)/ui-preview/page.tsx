import type { Metadata } from "next";
import { notFound } from "next/navigation";

import { UiPreview } from "@/components/dev/ui-preview";

export const metadata: Metadata = {
  title: "Component preview",
  robots: { index: false, follow: false },
};

export default function UiPreviewPage() {
  if (process.env.NODE_ENV !== "development") notFound();

  return (
    <main className="mx-auto max-w-page space-y-10 px-gutter py-12">
      <header className="space-y-3">
        <h1>Component preview</h1>
        <p className="text-muted">
          Development checks for shared Ghumne controls.
        </p>
      </header>
      <UiPreview />
    </main>
  );
}
