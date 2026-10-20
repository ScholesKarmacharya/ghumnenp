import type { ComponentProps } from "react";

import { cn } from "@/lib/utils/cn";

const tones = {
  neutral: "bg-surface-muted text-foreground",
  primary: "bg-surface-muted text-primary",
  success: "bg-success-surface text-success",
  warning: "bg-warning-surface text-warning",
  danger: "bg-danger-surface text-danger",
  info: "bg-info-surface text-info",
};

type BadgeProps = Omit<ComponentProps<"span">, "children"> & {
  children: string;
  tone?: keyof typeof tones;
};

export function Badge({ tone = "neutral", className, ...props }: BadgeProps) {
  return (
    <span
      {...props}
      className={cn(
        "inline-flex max-w-full items-center rounded-pill px-3 py-1 text-caption font-medium",
        tones[tone],
        className,
      )}
    />
  );
}
