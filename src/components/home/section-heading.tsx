export function SectionHeading({
  eyebrow,
  title,
  description,
  id,
  className = "max-w-2xl",
}: {
  eyebrow: string;
  title: string;
  description: string;
  id: string;
  className?: string;
}) {
  return (
    <div className={className}>
      <p className="mb-1 text-xs font-semibold tracking-[0.16em] text-muted uppercase">
        {eyebrow}
      </p>
      <h2
        id={id}
        className="font-display text-[clamp(1.75rem,3vw,2.5rem)] leading-[1.2] font-semibold tracking-[-0.01em]"
      >
        {title}
      </h2>
      <p className="mt-2 leading-relaxed text-muted">{description}</p>
    </div>
  );
}
