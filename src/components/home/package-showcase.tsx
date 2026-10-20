"use client";

import Image from "next/image";
import { useState } from "react";
import type { JourneyPreview } from "@/features/home/content";
import { filterJourneyPreviews } from "@/features/home/planning";
import { EmptyState } from "@/components/ui/feedback";
import { SectionHeading } from "./section-heading";
import { Icon } from "./icon";

const regions = [
  ["all", "All Regions"],
  ["annapurna", "Annapurna"],
  ["mustang", "Mustang & Dolpo"],
  ["everest", "Everest & Khumbu"],
  ["terai", "Chitwan & Bardia"],
] as const;

export function PackageShowcase({
  items,
}: {
  items: readonly JourneyPreview[];
}) {
  const [region, setRegion] = useState("all");
  const [duration, setDuration] = useState("all");
  const [cultural, setCultural] = useState(false);
  const visible = filterJourneyPreviews(items, region, duration, cultural);
  function resetFilters() {
    setRegion("all");
    setDuration("all");
    setCultural(false);
  }
  return (
    <section
      id="featured-packages"
      aria-labelledby="packages-title"
      className="bg-home-inset py-10"
    >
      <div className="home-container">
        <div className="mb-6 flex flex-col justify-between gap-4 md:flex-row md:items-end">
          <SectionHeading
            id="packages-title"
            eyebrow="Ideas for your next journey"
            title="Journeys worth taking."
            description="Explore the kind of journeys Ghumne is being built for. These itinerary previews are inspiration, not agency offers."
          />
          <p className="flex shrink-0 items-center gap-2 text-sm text-muted">
            <Icon name="compass" />
            Itinerary previews
          </p>
        </div>
        <p className="mb-5 rounded-lg border border-border bg-white px-4 py-3 text-sm text-muted">
          No live agency packages are published here. Preview itineraries have
          no quoted price, confirmed inclusions, or availability.
        </p>
        <div
          className="mb-6 flex flex-wrap items-center gap-2"
          aria-label="Filter itinerary previews"
        >
          {regions.map(([value, label]) => (
            <button
              key={value}
              type="button"
              aria-pressed={region === value}
              onClick={() => setRegion(value)}
              className={`home-filter ${region === value ? "bg-primary text-white" : "bg-white text-foreground"}`}
            >
              {label}
            </button>
          ))}
          <span
            aria-hidden="true"
            className="mx-1 hidden h-5 w-px bg-border md:block"
          />
          {[
            ["short", "Under 7 Days"],
            ["long", "8–14 Days"],
          ].map(([value, label]) => (
            <button
              key={value}
              type="button"
              aria-pressed={duration === value}
              onClick={() => setDuration(duration === value ? "all" : value!)}
              className={`home-filter ${duration === value ? "bg-primary text-white" : "bg-white text-foreground"}`}
            >
              {label}
            </button>
          ))}
          <button
            type="button"
            aria-pressed={cultural}
            onClick={() => setCultural(!cultural)}
            className={`home-filter ${cultural ? "bg-primary text-white" : "bg-white text-foreground"}`}
          >
            Cultural & Wildlife
          </button>
        </div>
        <p role="status" className="sr-only">
          {visible.length} itinerary previews shown.
        </p>
        {visible.length === 0 ? (
          <EmptyState
            headingAs="h3"
            title="No preview matches these filters"
            description="Try another region or duration. These filters browse editorial ideas, not live agency inventory."
            action={
              <button
                type="button"
                onClick={resetFilters}
                className="home-action bg-primary text-white"
              >
                Clear filters
              </button>
            }
          />
        ) : (
          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
            {visible.map((item) => (
              <article
                key={item.id}
                className="flex flex-col overflow-hidden rounded-lg bg-white shadow-sm"
                data-journey-preview
              >
                <div className="relative h-56 overflow-hidden">
                  <Image
                    src={item.image}
                    alt={item.alt}
                    fill
                    sizes="(max-width: 767px) 100vw, (max-width: 1023px) 50vw, 33vw"
                    placeholder="blur"
                    className="object-cover"
                  />
                  <p className="absolute top-3 left-3 rounded-control bg-white/95 px-2.5 py-1 text-xs font-semibold text-primary">
                    {item.place}
                  </p>
                  <p className="absolute right-3 bottom-3 rounded bg-primary/95 px-2 py-1 text-xs text-white">
                    Example · {item.days} {item.days === 1 ? "day" : "days"}
                  </p>
                </div>
                <div className="flex flex-1 flex-col p-4">
                  <p className="mb-2 flex items-center gap-1.5 text-xs text-muted">
                    <Icon name="compass" className="size-4" />
                    Illustrative itinerary · No agency listing
                  </p>
                  <h3 className="font-display text-xl leading-[1.35] font-semibold">
                    {item.title}
                  </h3>
                  <p className="mt-3 flex items-center gap-2 text-sm text-primary">
                    <Icon name="mountain" className="size-4" />
                    {item.style}
                  </p>
                  <p className="mt-2 text-sm leading-relaxed text-muted">
                    {item.description}
                  </p>
                  <ul
                    className="mt-4 mb-5 flex flex-wrap gap-1.5"
                    aria-label="Travel interests"
                  >
                    {item.interests.map((interest) => (
                      <li
                        key={interest}
                        className="rounded bg-home-inset px-2 py-1 text-xs text-muted"
                      >
                        {interest}
                      </li>
                    ))}
                  </ul>
                  <div className="mt-auto flex flex-wrap items-center justify-between gap-3 border-t border-border pt-4">
                    <div className="text-xs text-muted">
                      Price & availability
                      <span className="mt-1 block text-sm font-semibold text-primary">
                        Not published
                      </span>
                    </div>
                    <a
                      href={`/?q=${encodeURIComponent(item.place)}#trip-finder`}
                      className="home-action bg-primary px-4 py-2 text-sm text-white hover:bg-primary-hover"
                    >
                      Plan a similar trip
                    </a>
                  </div>
                </div>
              </article>
            ))}
          </div>
        )}
        <p className="mt-6 text-center font-display text-sm text-muted italic">
          A little inspiration today. Eligible agency offers and transparent
          group quotes will follow when the marketplace is ready.
        </p>
      </div>
    </section>
  );
}
