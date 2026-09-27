import Link from "next/link";

export function BrandLink() {
  return (
    <Link
      href="/"
      aria-label="Ghumne home"
      className="inline-flex min-h-control items-center rounded-sm text-2xl font-semibold tracking-tight text-primary"
    >
      Ghumne
      <span aria-hidden="true" className="text-accent">
        .
      </span>
    </Link>
  );
}
