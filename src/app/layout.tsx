import type { Metadata } from "next";
import type { ReactNode } from "react";
import localFont from "next/font/local";

import "./globals.css";

const jakarta = localFont({
  src: "./fonts/plus-jakarta-sans.woff2",
  variable: "--font-jakarta",
  display: "swap",
  weight: "300 800",
});
const editorial = localFont({
  src: [
    {
      path: "./fonts/playfair-display.woff2",
      weight: "400 900",
      style: "normal",
    },
    {
      path: "./fonts/playfair-display-italic.woff2",
      weight: "400 900",
      style: "italic",
    },
  ],
  variable: "--font-editorial",
  display: "swap",
});

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
    <html lang="en" className={`${jakarta.variable} ${editorial.variable}`}>
      <body>{children}</body>
    </html>
  );
}
