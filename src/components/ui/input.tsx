import type { ComponentProps } from "react";

import { cn } from "@/lib/utils/cn";

import {
  Field,
  fieldControlStyles,
  fieldDescription,
  type FieldProps,
} from "./field";

type InputProps = Omit<ComponentProps<"input">, "id" | "type"> &
  FieldProps & {
    type?:
      | "text"
      | "email"
      | "password"
      | "number"
      | "tel"
      | "url"
      | "search"
      | "date"
      | "month"
      | "time"
      | "datetime-local";
  };

export function Input({
  id,
  label,
  hint,
  error,
  required,
  type = "text",
  className,
  "aria-describedby": describedBy,
  "aria-invalid": invalid,
  ...props
}: InputProps) {
  return (
    <Field id={id} label={label} hint={hint} error={error} required={required}>
      <input
        {...props}
        id={id}
        type={type}
        required={required}
        aria-invalid={error ? true : invalid}
        aria-describedby={fieldDescription({ id, hint, error }, describedBy)}
        className={cn(fieldControlStyles, className)}
      />
    </Field>
  );
}
