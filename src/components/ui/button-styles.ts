import { cn } from "@/lib/utils/cn";

const variants = {
  primary:
    "border-transparent bg-primary text-on-primary hover:bg-primary-hover",
  secondary:
    "border-border-strong bg-surface text-foreground hover:bg-surface-muted",
  ghost: "border-transparent text-primary hover:bg-surface-muted",
  danger: "border-transparent bg-danger text-on-primary hover:brightness-90",
};

export type ButtonVariant = keyof typeof variants;

export function buttonStyles(
  variant: ButtonVariant = "primary",
  className?: string,
) {
  return cn(
    "inline-flex min-h-control min-w-control items-center justify-center gap-2 rounded-control border px-5 py-2.5 text-body font-semibold text-center transition-colors disabled:cursor-not-allowed disabled:opacity-60",
    variants[variant],
    className,
  );
}
