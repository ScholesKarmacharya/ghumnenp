import type { ComponentProps } from "react";

import { cn } from "@/lib/utils/cn";

import {
  Field,
  fieldControlStyles,
  fieldDescription,
  type FieldProps,
} from "./field";

type TextareaProps = Omit<ComponentProps<"textarea">, "id"> & FieldProps;

export function Textarea({
  id,
  label,
  hint,
  error,
  required,
  className,
  rows = 4,
  "aria-describedby": describedBy,
  "aria-invalid": invalid,
  ...props
}: TextareaProps) {
  return (
    <Field id={id} label={label} hint={hint} error={error} required={required}>
      <textarea
        {...props}
        id={id}
        rows={rows}
        required={required}
        aria-invalid={error ? true : invalid}
        aria-describedby={fieldDescription({ id, hint, error }, describedBy)}
        className={cn(fieldControlStyles, "min-h-32 resize-y", className)}
      />
    </Field>
  );
}
