import { describe, expect, it } from "vitest";
import {
  buildTripBrief,
  filterJourneyPreviews,
  matchesDestination,
  normalizeHomeSearch,
} from "@/features/home/planning";

describe("homepage preview search and planning boundaries", () => {
  it("normalizes public query preferences without trusting unknown selections", () => {
    expect(
      normalizeHomeSearch({
        q: "  Pokhara  ",
        hub: "Pokhara",
        season: "Winter",
        travelers: "4",
      }),
    ).toEqual({ q: "Pokhara", hub: "Pokhara", season: "Winter", travelers: 4 });
    expect(
      normalizeHomeSearch({
        q: ["Mustang", "Rara"],
        hub: "unknown",
        season: "unknown",
        travelers: "2.5",
      }),
    ).toEqual({ q: "", hub: "Kathmandu", season: "Spring", travelers: 2 });
  });
  it.each(["0", "-1", "10001", "Infinity", "NaN"])(
    "rejects unsupported traveler input %s",
    (travelers) => {
      expect(normalizeHomeSearch({ travelers }).travelers).toBe(2);
    },
  );
  it("bounds query length and accepts the platform traveler boundary", () => {
    expect(
      normalizeHomeSearch({ q: "x".repeat(200), travelers: "10000" }).q,
    ).toHaveLength(100);
    expect(normalizeHomeSearch({ travelers: "10000" }).travelers).toBe(10000);
  });
  it("matches only the editorial destination fields, case-insensitively", () => {
    const destination = {
      name: "Pokhara Valley",
      region: "Lakeside",
      description: "Quiet mountain views",
    };
    expect(matchesDestination(destination, "POKHARA")).toBe(true);
    expect(matchesDestination(destination, "lakeside")).toBe(true);
    expect(matchesDestination(destination, "guaranteed price")).toBe(false);
  });
  it("combines filters without changing or inventing preview inventory", () => {
    const items = [
      { region: "mustang", days: 10, category: "culture" },
      { region: "annapurna", days: 12, category: "trek" },
      { region: "terai", days: 4, category: "wildlife" },
    ];
    expect(filterJourneyPreviews(items, "all", "short", false)).toEqual([
      items[2],
    ]);
    expect(filterJourneyPreviews(items, "mustang", "long", true)).toEqual([
      items[0],
    ]);
    expect(filterJourneyPreviews(items, "annapurna", "short", false)).toEqual(
      [],
    );
    expect(items).toHaveLength(3);
  });
  it("creates a downloadable preference brief, never a quote or claimed match", () => {
    const data = new FormData();
    for (const [key, value] of Object.entries({
      destination: "Mustang",
      hub: "Pokhara",
      season: "Autumn",
      travelers: "4",
      duration: "10–14 days",
      budget: "NPR 100,000–200,000",
    }))
      data.set(key, value);
    data.append("interests", "Heritage");
    data.append("interests", "invented interest");
    const brief = buildTripBrief(data);
    expect(brief).toContain("Starting hub: Pokhara");
    expect(brief).toContain("Travelers: 4");
    expect(brief).toContain(
      "Total group budget preference: NPR 100,000–200,000",
    );
    expect(brief).toContain("Interests: Heritage");
    expect(brief).not.toContain("invented interest");
    expect(brief).toContain(
      "not a quote, booking, reservation, or confirmed itinerary",
    );
    expect(brief).toContain(
      "Live agency matching and saving trips to an account are not available yet",
    );
  });
});
