import Link from "next/link";
import type { ComponentProps } from "react";

import { cn } from "@/lib/utils/cn";

import { buttonStyles, type ButtonVariant } from "./button-styles";

type LinkProps = ComponentProps<typeof Link>;

function safeRel(target: LinkProps["target"], rel: LinkProps["rel"]) {
  return target === "_blank" ? cn(rel, "noopener noreferrer") : rel;
}

export function TextLink({ className, target, rel, ...props }: LinkProps) {
  return (
    <Link
      {...props}
      target={target}
      rel={safeRel(target, rel)}
      className={cn(
        "rounded-sm font-medium text-primary underline decoration-1 underline-offset-4 hover:text-primary-hover",
        className,
      )}
    />
  );
}

export function ButtonLink({
  variant = "primary",
  className,
  target,
  rel,
  ...props
}: LinkProps & { variant?: ButtonVariant }) {
  return (
    <Link
      {...props}
      target={target}
      rel={safeRel(target, rel)}
      className={buttonStyles(variant, className)}
    />
  );
}
