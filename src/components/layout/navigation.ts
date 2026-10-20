export type NavigationItem = { href: string; label: string };

// Add routes when their feature tasks make them available.
export const primaryNavigation: readonly NavigationItem[] = [
  { href: "/", label: "Home" },
  { href: "/#destinations", label: "Explore Destinations" },
  { href: "/#featured-packages", label: "Travel Packages" },
  { href: "/#trip-finder", label: "Find My Trip" },
  { href: "/#travel-guides", label: "Travel Guides" },
  { href: "/#for-agencies", label: "For agencies" },
];
