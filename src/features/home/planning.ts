export const hubs = [
  "Kathmandu",
  "Pokhara",
  "Biratnagar",
  "Custom route",
] as const;
export const seasons = ["Spring", "Autumn", "Winter", "Summer"] as const;
export type HomeSearch = {
  q: string;
  hub: string;
  season: string;
  travelers: number;
};
export type SearchInput = Record<string, string | string[] | undefined>;

export function normalizeHomeSearch(input: SearchInput): HomeSearch {
  const value = (key: string) =>
    typeof input[key] === "string" ? input[key] : "";
  const count = Number(value("travelers"));
  return {
    q: value("q").trim().slice(0, 100),
    hub: hubs.find((hub) => hub === value("hub")) ?? hubs[0],
    season: seasons.find((season) => season === value("season")) ?? seasons[0],
    travelers:
      Number.isInteger(count) && count >= 1 && count <= 10000 ? count : 2,
  };
}

export function matchesDestination(
  destination: { name: string; region: string; description: string },
  query: string,
) {
  return `${destination.name} ${destination.region} ${destination.description}`
    .toLocaleLowerCase("en")
    .includes(query.toLocaleLowerCase("en"));
}

export function filterJourneyPreviews<
  T extends { region: string; days: number; category: string },
>(
  items: readonly T[],
  region: string,
  duration: string,
  cultural: boolean,
): T[] {
  return items.filter(
    (item) =>
      (region === "all" || item.region === region) &&
      (duration === "all" ||
        (duration === "short"
          ? item.days < 7
          : item.days >= 8 && item.days <= 14)) &&
      (!cultural ||
        item.category === "culture" ||
        item.category === "wildlife"),
  );
}

export function buildTripBrief(data: FormData) {
  const preferences = normalizeHomeSearch({
    q: String(data.get("destination") ?? ""),
    hub: String(data.get("hub") ?? ""),
    season: String(data.get("season") ?? ""),
    travelers: String(data.get("travelers") ?? ""),
  });
  const durations = ["3–5 days", "6–9 days", "10–14 days", "15+ days"];
  const budgets = [
    "NPR 30,000–50,000",
    "NPR 50,000–100,000",
    "NPR 100,000–200,000",
    "NPR 200,000+",
  ];
  const interests = data
    .getAll("interests")
    .map(String)
    .filter((item) =>
      [
        "Trekking",
        "Wildlife",
        "Monasteries",
        "Heritage",
        "Wellness",
        "Rivers",
      ].includes(item),
    );
  return [
    "GHUMNE · PERSONAL TRIP BRIEF",
    `Destination idea: ${preferences.q || "Open to ideas"}`,
    `Starting hub: ${preferences.hub}`,
    `Season preference: ${preferences.season}`,
    `Travelers: ${preferences.travelers}`,
    `Duration preference: ${durations.find((value) => value === data.get("duration")) ?? durations[1]}`,
    `Total group budget preference: ${budgets.find((value) => value === data.get("budget")) ?? budgets[1]}`,
    `Interests: ${interests.join(", ") || "Open to suggestions"}`,
    "",
    "This is your planning brief, not a quote, booking, reservation, or confirmed itinerary.",
    "Live agency matching and saving trips to an account are not available yet.",
  ].join("\n");
}
