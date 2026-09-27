import type { ComponentProps } from "react";

import { buttonStyles, type ButtonVariant } from "./button-styles";

type ButtonProps = ComponentProps<"button"> & {
  variant?: ButtonVariant;
  isLoading?: boolean;
  loadingLabel?: string;
};

export function Button({
  type = "button",
  variant = "primary",
  isLoading = false,
  loadingLabel = "Working…",
  disabled,
  className,
  children,
  ...props
}: ButtonProps) {
  return (
    <button
      {...props}
      type={type}
      disabled={disabled || isLoading}
      aria-busy={isLoading || undefined}
      className={buttonStyles(variant, className)}
    >
      {isLoading && (
        <span
          aria-hidden="true"
          className="size-4 shrink-0 rounded-full border-2 border-current border-r-transparent motion-safe:animate-spin"
        />
      )}
      {isLoading ? loadingLabel : children}
    </button>
  );
}
