import type { ComponentProps } from "react";

import { cn } from "@/lib/utils/cn";

import {
  Field,
  fieldControlStyles,
  fieldDescription,
  type FieldProps,
} from "./field";

type SelectProps = Omit<ComponentProps<"select">, "id"> & FieldProps;

export function Select({
  id,
  label,
  hint,
  error,
  required,
  className,
  children,
  "aria-describedby": describedBy,
  "aria-invalid": invalid,
  ...props
}: SelectProps) {
  return (
    <Field id={id} label={label} hint={hint} error={error} required={required}>
      <select
        {...props}
        id={id}
        required={required}
        aria-invalid={error ? true : invalid}
        aria-describedby={fieldDescription({ id, hint, error }, describedBy)}
        className={cn(fieldControlStyles, "pr-8", className)}
      >
        {children}
      </select>
    </Field>
  );
}
