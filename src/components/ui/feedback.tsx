import type { ReactNode } from "react";

type FeedbackProps = {
  title: string;
  description: string;
  action?: ReactNode;
  headingAs?: "h1" | "h2" | "h3";
};

export function EmptyState({
  title,
  description,
  action,
  headingAs: Heading = "h2",
}: FeedbackProps) {
  return (
    <section aria-label={title} className="max-w-reading space-y-4 py-8">
      <Heading>{title}</Heading>
      <p className="text-muted">{description}</p>
      {action && <div className="flex flex-wrap gap-3 pt-2">{action}</div>}
    </section>
  );
}

export function ErrorState({
  title,
  description,
  action,
  headingAs: Heading = "h2",
}: FeedbackProps) {
  return (
    <section
      role="alert"
      aria-label={title}
      className="max-w-reading space-y-4 rounded-card border border-danger bg-danger-surface p-6"
    >
      <Heading className="text-danger">{title}</Heading>
      <p>{description}</p>
      {action && <div className="flex flex-wrap gap-3 pt-2">{action}</div>}
    </section>
  );
}

export function SuccessMessage({ children }: { children: string }) {
  return (
    <p
      role="status"
      className="rounded-control border border-success bg-success-surface px-4 py-3 text-success"
    >
      {children}
    </p>
  );
}
