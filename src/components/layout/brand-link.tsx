import Link from "next/link";

export function BrandLink() {
  return (
    <Link
      href="/"
      aria-label="Ghumne home"
      className="inline-flex min-h-control items-baseline rounded-sm font-display text-[1.75rem] font-semibold tracking-tight text-primary"
    >
      ghumne
      <span aria-hidden="true" className="text-accent">
        .
      </span>
    </Link>
  );
}
