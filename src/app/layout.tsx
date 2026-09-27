import type { Metadata } from "next";
import type { ReactNode } from "react";

export const metadata: Metadata = {
  title: {
    default: "Ghumne — Discover Nepal. Plan your trip.",
    template: "%s | Ghumne",
  },
  description:
    "Discover Nepal and plan a trip around your budget, available days, and interests.",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
