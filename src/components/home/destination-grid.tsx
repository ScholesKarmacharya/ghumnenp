import Image from "next/image";
import Link from "next/link";
import { destinations } from "@/features/home/content";
import { matchesDestination, type HomeSearch } from "@/features/home/planning";
import { EmptyState } from "@/components/ui/feedback";
import { Icon } from "./icon";
import { SectionHeading } from "./section-heading";

export function DestinationGrid({ search }: { search: HomeSearch }) {
  const visible = destinations.filter((destination) =>
    matchesDestination(destination, search.q),
  );
  return (
    <section
      id="destinations"
      aria-labelledby="destinations-title"
      className="home-container pt-28 pb-10 lg:pt-32"
    >
      <div className="mb-10 flex flex-col justify-between gap-5 md:flex-row md:items-end">
        <SectionHeading
          id="destinations-title"
          eyebrow="Topography & regions"
          title="Where will Nepal take you?"
          description="From high Himalayan landscapes to subtropical jungles and ancient Newari streets. A little inspiration for your next chapter."
        />
        <a href="#trip-finder" className="home-text-link shrink-0">
          Build your trip brief
          <Icon name="arrow" />
        </a>
      </div>
      {search.q && (
        <p role="status" className="mb-5 text-sm text-muted">
          {visible.length} destination{" "}
          {visible.length === 1 ? "preview" : "previews"} for “{search.q}”.{" "}
          <Link href="/#destinations" className="underline underline-offset-4">
            Clear search
          </Link>
        </p>
      )}
      {visible.length === 0 ? (
        <EmptyState
          headingAs="h3"
          title="A new direction awaits"
          description="No editorial destination preview matches that search. Try Mustang, Pokhara, Chitwan, Rara, or Bandipur."
          action={
            <Link href="/#destinations" className="home-text-link">
              Explore all previews
              <Icon name="arrow" />
            </Link>
          }
        />
      ) : (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-12">
          {visible.map((destination, index) => {
            const query = new URLSearchParams({
              q: destination.name,
              hub: search.hub,
              season: search.season,
              travelers: String(search.travelers),
            });
            return (
              <article
                key={destination.name}
                className={`relative flex min-h-80 flex-col justify-end overflow-hidden rounded-lg bg-primary p-6 text-white ${destination.wide ? `md:min-h-[380px] lg:min-h-[440px] ${index === 0 ? "lg:col-span-7" : "lg:col-span-5"}` : "lg:col-span-4"}`}
              >
                <Image
                  src={destination.image}
                  alt={destination.alt}
                  fill
                  sizes={
                    destination.wide
                      ? "(max-width: 767px) 100vw, (max-width: 1023px) 50vw, 60vw"
                      : "(max-width: 767px) 100vw, (max-width: 1023px) 50vw, 33vw"
                  }
                  placeholder="blur"
                  className="object-cover"
                />
                <div className="absolute inset-0 bg-[linear-gradient(0deg,rgba(0,39,35,0.97),rgba(0,39,35,0.55)_45%,transparent)]" />
                <div className="relative space-y-2">
                  <p className="text-xs font-semibold tracking-wider text-white/90 uppercase">
                    {destination.region}
                  </p>
                  <h3
                    className={`font-display font-semibold ${destination.wide ? "text-[1.75rem]" : "text-xl"}`}
                  >
                    {destination.name}
                  </h3>
                  <p className="max-w-md text-sm leading-relaxed text-white/90">
                    {destination.description}
                  </p>
                  <Link
                    href={`/?${query.toString()}#trip-finder`}
                    className="inline-flex min-h-control max-w-full flex-wrap items-center gap-2 text-sm font-semibold text-sand underline-offset-4 hover:underline"
                  >
                    Plan a {destination.name} trip
                    <Icon name="arrow" className="size-4" />
                  </Link>
                </div>
              </article>
            );
          })}
        </div>
      )}
      <p className="mt-4 text-xs text-muted">
        Editorial destination previews with imagery from the approved design.
        Live package counts are not available.
      </p>
    </section>
  );
}
