import type { Metadata } from "next";
import { HomeHero } from "@/components/home/home-hero";
import { DestinationGrid } from "@/components/home/destination-grid";
import { PackageShowcase } from "@/components/home/package-showcase";
import { TripFinder } from "@/components/home/trip-finder";
import { ValuePillars } from "@/components/home/value-pillars";
import { TravelStories } from "@/components/home/travel-stories";
import { AgencySection } from "@/components/home/agency-section";
import { journeyPreviews } from "@/features/home/content";
import {
  normalizeHomeSearch,
  type SearchInput,
} from "@/features/home/planning";

export const metadata: Metadata = {
  title: "Discover Nepal. Plan your journey.",
  description:
    "Discover Nepal’s landscapes, explore itinerary inspiration, and create a personal trip brief around your time, group, budget, and interests.",
  openGraph: {
    title: "Ghumne — Your next story starts in Nepal",
    description:
      "Discover places. Explore journey ideas. Shape your own trip to Nepal.",
    type: "website",
  },
};

export default async function HomePage({
  searchParams,
}: {
  searchParams: Promise<SearchInput>;
}) {
  const search = normalizeHomeSearch(await searchParams);
  return (
    <main id="main-content" tabIndex={-1}>
      <HomeHero search={search} />
      <DestinationGrid search={search} />
      <PackageShowcase items={journeyPreviews} />
      <TripFinder key={JSON.stringify(search)} search={search} />
      <ValuePillars />
      <TravelStories />
      <AgencySection />
    </main>
  );
}
