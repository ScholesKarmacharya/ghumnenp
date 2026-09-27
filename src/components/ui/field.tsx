import type { ReactNode } from "react";

import { cn } from "@/lib/utils/cn";

export type FieldProps = {
  id: string;
  label: string;
  hint?: string;
  error?: string;
};

export const fieldControlStyles =
  "w-full min-w-0 min-h-control rounded-control border border-border-strong bg-surface px-3 py-2 text-body placeholder:text-muted disabled:cursor-not-allowed disabled:bg-surface-muted disabled:text-muted aria-invalid:border-danger aria-invalid:outline-danger";

export function fieldDescription(
  { id, hint, error }: Pick<FieldProps, "id" | "hint" | "error">,
  existing?: string,
) {
  return (
    cn(existing, hint && `${id}-hint`, error && `${id}-error`) || undefined
  );
}

export function FieldFeedback({ id, hint, error }: Omit<FieldProps, "label">) {
  return (
    <>
      {hint && (
        <p id={`${id}-hint`} className="text-caption text-muted">
          {hint}
        </p>
      )}
      {error && (
        <p id={`${id}-error`} role="alert" className="text-caption text-danger">
          {error}
        </p>
      )}
    </>
  );
}

export function Field({
  id,
  label,
  hint,
  error,
  required,
  children,
}: FieldProps & { required?: boolean; children: ReactNode }) {
  return (
    <div className="min-w-0 space-y-2">
      <label htmlFor={id} className="block font-medium">
        {label}
        {required && <span aria-hidden="true"> *</span>}
      </label>
      {children}
      <FieldFeedback id={id} hint={hint} error={error} />
    </div>
  );
}
