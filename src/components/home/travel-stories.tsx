import Image from "next/image";
import { storyPreviews } from "@/features/home/content";
import { SectionHeading } from "./section-heading";

export function TravelStories() {
  const [lead, ...stories] = storyPreviews;
  return (
    <section
      id="travel-guides"
      aria-labelledby="stories-title"
      className="bg-home-inset py-10"
    >
      <div className="home-container">
        <div className="mb-6 flex flex-col justify-between gap-4 md:flex-row md:items-end">
          <SectionHeading
            id="stories-title"
            eyebrow="The Himalayan dispatch"
            title="Travel stories & field guides."
            description="A first look at the stories and practical guides planned for Ghumne. Editorial previews; full guides are in preparation."
          />
          <span className="text-sm font-medium text-muted">
            The journey behind the journey
          </span>
        </div>
        <div className="grid grid-cols-1 gap-6 lg:grid-cols-12">
          <article className="overflow-hidden rounded-lg bg-white shadow-sm lg:col-span-7">
            <div className="relative h-80 lg:h-96">
              <Image
                src={lead.image}
                alt={lead.alt}
                fill
                sizes="(max-width: 1023px) 100vw, 60vw"
                placeholder="blur"
                className="object-cover"
              />
              <span className="absolute top-4 left-4 rounded-control bg-white/95 px-3 py-1 text-xs font-semibold text-primary">
                {lead.category}
              </span>
            </div>
            <div className="space-y-3 p-6">
              <p className="text-xs text-muted">
                Editorial preview · In preparation
              </p>
              <h3 className="font-display text-[1.75rem] leading-[1.3] font-semibold">
                {lead.title}: Landscapes, Communities & Old Trading Trails
              </h3>
              <p className="leading-relaxed text-muted">{lead.description}</p>
              <details className="home-story-preview">
                <summary>
                  Read story preview <span aria-hidden="true">→</span>
                </summary>
                <p className="mt-3 text-sm leading-relaxed text-muted">
                  This planned feature explores how historic journeys connect
                  people and places in western Nepal. The complete article and
                  its source review are still to come.
                </p>
              </details>
            </div>
          </article>
          <div className="flex flex-col gap-4 lg:col-span-5">
            {stories.map((story) => (
              <article
                key={story.title}
                className="flex flex-wrap items-start gap-4 rounded-lg bg-white p-4 shadow-sm"
              >
                <div className="relative size-20 shrink-0 overflow-hidden rounded sm:size-28">
                  <Image
                    src={story.image}
                    alt={story.alt}
                    fill
                    sizes="112px"
                    placeholder="blur"
                    className="object-cover"
                  />
                </div>
                <div className="min-w-0 flex-1 basis-40 space-y-2">
                  <p className="text-xs text-muted">
                    {story.category} · Preview
                  </p>
                  <h3 className="font-display text-[1.05rem] leading-snug font-semibold">
                    {story.title}
                  </h3>
                  <p className="text-sm leading-relaxed text-muted">
                    {story.description}
                  </p>
                  <details className="home-story-preview">
                    <summary>
                      Read preview <span aria-hidden="true">→</span>
                    </summary>
                    <p className="mt-2 text-sm text-muted">
                      This guide is being prepared. A complete, sourced article
                      will be available when the editorial collection launches.
                    </p>
                  </details>
                </div>
              </article>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
