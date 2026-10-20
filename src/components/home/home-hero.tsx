import Image from "next/image";
import { heroImage } from "@/features/home/content";
import { hubs, seasons, type HomeSearch } from "@/features/home/planning";
import { Icon } from "./icon";

export function HomeHero({ search }: { search: HomeSearch }) {
  return (
    <section
      aria-labelledby="hero-title"
      className="relative flex min-h-[760px] flex-col justify-between bg-primary text-white lg:min-h-[862px]"
    >
      <div className="absolute inset-0 overflow-hidden">
        <Image
          src={heroImage}
          alt="The Himalayan skyline above mist-filled valleys at dawn"
          fill
          sizes="100vw"
          fetchPriority="high"
          loading="eager"
          placeholder="blur"
          className="object-cover object-center"
        />
        <div className="absolute inset-0 bg-[linear-gradient(0deg,rgba(0,39,35,1),rgba(0,39,35,0.6)_55%,rgba(0,39,35,0.4)),linear-gradient(90deg,rgba(0,39,35,0.8),transparent,rgba(0,39,35,0.4))]" />
      </div>
      <div className="relative mx-auto flex w-full max-w-home flex-1 items-center px-5 py-20 lg:px-12 lg:pt-32 lg:pb-20">
        <div className="max-w-3xl space-y-4">
          <p className="inline-flex items-center gap-2 rounded-control bg-white/15 px-3 py-2 text-xs font-semibold tracking-wider uppercase">
            <span className="size-1.5 rounded-full bg-terracotta" />
            Discover · Compare · Plan
          </p>
          <h1
            id="hero-title"
            className="font-display text-[clamp(2.25rem,5vw,3.5rem)] leading-[1.08] font-semibold tracking-[-0.02em]"
          >
            Your next story starts in{" "}
            <span className="font-normal text-sand italic">Nepal.</span>
          </h1>
          <p className="max-w-2xl text-lg leading-[1.65] text-white/90">
            Discover extraordinary places, explore journey ideas, and craft a
            trip around your time, budget, and interests across the roof of the
            world.
          </p>
          <div className="flex flex-wrap gap-4 pt-2">
            <a
              href="#featured-packages"
              className="home-action bg-white text-primary hover:bg-sand focus-visible:outline-sand"
            >
              Explore Packages
              <Icon name="diagonal" />
            </a>
            <a
              href="#trip-finder"
              className="home-action border border-white/30 bg-white/10 text-white hover:bg-white/20 focus-visible:outline-sand"
            >
              <Icon name="tune" />
              Find My Trip
            </a>
          </div>
        </div>
      </div>
      <div className="relative z-10 mx-auto -mb-12 w-full max-w-home px-5 lg:px-12">
        <form
          action="/#destinations"
          method="get"
          aria-label="Explore destination previews"
          className="rounded-lg bg-white p-3 text-foreground shadow-xl lg:p-4"
        >
          <div className="grid items-end gap-2 md:grid-cols-2 lg:grid-cols-[2fr_1.15fr_1.15fr_1fr_auto]">
            <div className="home-search-field">
              <label htmlFor="home-destination">Destination</label>
              <div>
                <Icon name="pin" />
                <input
                  id="home-destination"
                  name="q"
                  type="search"
                  maxLength={100}
                  defaultValue={search.q}
                  placeholder="Where to? e.g. Mustang, Pokhara…"
                />
              </div>
            </div>
            <div className="home-search-field">
              <label htmlFor="home-hub">Starting hub</label>
              <div>
                <Icon name="compass" />
                <select id="home-hub" name="hub" defaultValue={search.hub}>
                  {hubs.map((hub) => (
                    <option key={hub}>{hub}</option>
                  ))}
                </select>
              </div>
            </div>
            <div className="home-search-field">
              <label htmlFor="home-season">Season preference</label>
              <div>
                <Icon name="calendar" />
                <select
                  id="home-season"
                  name="season"
                  defaultValue={search.season}
                >
                  {seasons.map((season) => (
                    <option key={season}>{season}</option>
                  ))}
                </select>
              </div>
            </div>
            <div className="home-search-field">
              <label htmlFor="home-travelers">Travelers</label>
              <div>
                <Icon name="people" />
                <input
                  id="home-travelers"
                  name="travelers"
                  type="number"
                  min={1}
                  max={10000}
                  required
                  defaultValue={search.travelers}
                />
              </div>
            </div>
            <button
              type="submit"
              className="home-action w-full bg-primary text-white hover:bg-primary-hover"
            >
              <Icon name="search" />
              Search
            </button>
          </div>
          <p className="mt-2 px-2 text-xs leading-relaxed text-muted">
            Search editorial destination previews. Hub, season, and group size
            carry into your planning brief.
          </p>
        </form>
      </div>
    </section>
  );
}
