import type { ComponentProps } from "react";

import { cn } from "@/lib/utils/cn";

import { FieldFeedback, fieldDescription, type FieldProps } from "./field";

type ChoiceProps = Omit<ComponentProps<"input">, "id" | "type"> & FieldProps;

function Choice({
  id,
  label,
  hint,
  error,
  type,
  disabled,
  className,
  "aria-describedby": describedBy,
  "aria-invalid": invalid,
  ...props
}: ChoiceProps & { type: "checkbox" | "radio" }) {
  return (
    <div className="min-w-0 space-y-1">
      <label
        htmlFor={id}
        className={cn(
          "flex min-h-control cursor-pointer items-center gap-3 rounded-control py-2",
          disabled && "cursor-not-allowed text-muted",
        )}
      >
        <input
          {...props}
          id={id}
          type={type}
          disabled={disabled}
          aria-invalid={error ? true : invalid}
          aria-describedby={fieldDescription({ id, hint, error }, describedBy)}
          className={cn(
            "size-5 shrink-0 accent-primary disabled:cursor-not-allowed",
            className,
          )}
        />
        <span>{label}</span>
      </label>
      <FieldFeedback id={id} hint={hint} error={error} />
    </div>
  );
}

export function Checkbox(props: ChoiceProps) {
  return <Choice {...props} type="checkbox" />;
}

export function Radio(props: ChoiceProps & { name: string }) {
  return <Choice {...props} type="radio" />;
}
