import type { ComponentProps, HTMLAttributes } from "react";

import { cn } from "@/lib/utils/cn";

type CardProps = HTMLAttributes<HTMLElement> & {
  as?: "article" | "section" | "div";
};

export function Card({
  as: Element = "article",
  className,
  ...props
}: CardProps) {
  return (
    <Element
      {...props}
      className={cn(
        "min-w-0 rounded-card border border-border bg-surface shadow-card",
        className,
      )}
    />
  );
}

export function CardHeader({ className, ...props }: ComponentProps<"div">) {
  return <div {...props} className={cn("space-y-2 px-6 pt-6", className)} />;
}

export function CardContent({ className, ...props }: ComponentProps<"div">) {
  return <div {...props} className={cn("space-y-4 p-6", className)} />;
}

export function CardFooter({ className, ...props }: ComponentProps<"div">) {
  return (
    <div
      {...props}
      className={cn("flex flex-wrap items-center gap-3 px-6 pb-6", className)}
    />
  );
}
