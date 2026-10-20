import type { SVGProps } from "react";

const paths = {
  arrow: "M4 12h16m-6-6 6 6-6 6",
  diagonal: "M5 5l14 14M7 19h12V7",
  search: "M21 21l-5-5M10.5 18a7.5 7.5 0 1 0 0-15 7.5 7.5 0 0 0 0 15Z",
  pin: "M20 10c0 6-8 12-8 12S4 16 4 10a8 8 0 1 1 16 0ZM15 10a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z",
  mountain: "m2 20 7-14 5 9 3-5 5 10H2Zm4-8 3 2 2-2",
  calendar: "M5 5h14v16H5V5Zm3-3v6m8-6v6M5 11h14",
  people:
    "M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2M12 7a4 4 0 1 1-8 0 4 4 0 0 1 8 0Zm5 8a4 4 0 0 1 5 4v2M16 3a4 4 0 0 1 0 8",
  tune: "M4 7h16M4 17h16M9 4v6m6 4v6",
  map: "m3 6 6-3 6 3 6-3v15l-6 3-6-3-6 3V6Zm6-3v15m6-12v15",
  compare: "M12 3v18M5 6h14M4 7l-3 7h6L4 7Zm16 0-3 7h6l-3-7ZM7 21h10",
  wallet: "M20 7H5a2 2 0 0 1 0-4h13v4M3 5v14a2 2 0 0 0 2 2h15V7m0 5h-5v5h5",
  chat: "M21 12a9 9 0 0 1-9 9H3l2-5a9 9 0 1 1 16-4Z",
  check: "m5 12 4 4L19 6",
  download: "M12 3v12m-5-5 5 5 5-5M4 17v4h16v-4",
  compass: "M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-6-3-2 4-4 2 2-4 4-2Z",
};
export type IconName = keyof typeof paths;
export function Icon({
  name,
  ...props
}: SVGProps<SVGSVGElement> & { name: IconName }) {
  return (
    <svg
      aria-hidden="true"
      focusable="false"
      width="20"
      height="20"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.6"
      strokeLinecap="round"
      strokeLinejoin="round"
      {...props}
    >
      <path d={paths[name]} />
    </svg>
  );
}
