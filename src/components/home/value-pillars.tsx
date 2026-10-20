import { Icon, type IconName } from "./icon";
import { SectionHeading } from "./section-heading";

const pillars: readonly {
  title: string;
  label: string;
  description: string;
  icon: IconName;
}[] = [
  {
    title: "Discover Across Nepal",
    label: "Unbiased exploration",
    description:
      "Start with the places, landscapes, and travel experiences that speak to you.",
    icon: "map",
  },
  {
    title: "Compare with Context",
    label: "A considered marketplace",
    description:
      "The marketplace is being built to bring eligible agency offers together with clear inclusions and group quotes.",
    icon: "compare",
  },
  {
    title: "Plan Around Your Budget",
    label: "Clarity before commitment",
    description:
      "Keep your whole group, time, and priorities in view. Unavailable prices are never treated as zero.",
    icon: "wallet",
  },
  {
    title: "Your Journey, Your Way",
    label: "Personal planning",
    description:
      "Shape a trip brief that reflects your interests, then take the next step when agency offers become available.",
    icon: "chat",
  },
];

export function ValuePillars() {
  return (
    <section
      aria-labelledby="principles-title"
      className="home-container py-10"
    >
      <div className="mx-auto mb-10 max-w-4xl text-center">
        <SectionHeading
          className="max-w-none"
          id="principles-title"
          eyebrow="Clear principles"
          title="Built with intention for Nepal travelers."
          description="A clearer way to discover places, consider journeys, and plan around what matters to you."
        />
      </div>
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {pillars.map((pillar, index) => (
          <article key={pillar.title} className="rounded-lg bg-home-inset p-6">
            <div className="mb-4 flex size-12 items-center justify-center rounded bg-white text-primary shadow-sm">
              <Icon name={pillar.icon} className="size-6" />
            </div>
            <p className="mb-2 font-mono text-xs leading-relaxed text-muted uppercase">
              0{index + 1} / {pillar.label}
            </p>
            <h3 className="font-display text-xl leading-[1.35] font-semibold">
              {pillar.title}
            </h3>
            <p className="mt-3 text-sm leading-relaxed text-muted">
              {pillar.description}
            </p>
          </article>
        ))}
      </div>
    </section>
  );
}
