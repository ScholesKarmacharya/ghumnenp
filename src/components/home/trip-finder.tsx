"use client";

import { useState, type FormEvent, type ReactNode } from "react";
import {
  buildTripBrief,
  hubs,
  seasons,
  type HomeSearch,
} from "@/features/home/planning";
import { Icon } from "./icon";
import { SectionHeading } from "./section-heading";

function Step({
  number,
  title,
  children,
}: {
  number: string;
  title: string;
  children: ReactNode;
}) {
  return (
    <fieldset className="min-w-0">
      <legend className="mb-2 text-sm font-semibold">
        <span className="mr-2 font-mono text-primary">{number}</span>
        {title}
      </legend>
      {children}
    </fieldset>
  );
}

function RadioChoices({
  name,
  options,
  initial,
}: {
  name: string;
  options: readonly (readonly [string, string])[];
  initial: string;
}) {
  return (
    <div className="grid grid-cols-1 gap-2 min-[380px]:grid-cols-2 sm:grid-cols-4">
      {options.map(([value, detail]) => (
        <label key={value} className="home-choice">
          <span className="min-w-0">
            <span className="block text-sm font-semibold">{value}</span>
            {detail && (
              <span className="mt-1 block text-xs leading-relaxed">
                {detail}
              </span>
            )}
          </span>
          <input
            type="radio"
            name={name}
            value={value}
            defaultChecked={initial === value}
            className="size-4 shrink-0 accent-primary"
          />
        </label>
      ))}
    </div>
  );
}

export function TripFinder({ search }: { search: HomeSearch }) {
  const [brief, setBrief] = useState("");
  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setBrief(buildTripBrief(new FormData(event.currentTarget)));
  }
  return (
    <section
      id="trip-finder"
      aria-labelledby="finder-title"
      className="home-container py-10"
    >
      <div className="rounded-2xl bg-white p-5 shadow-[0_8px_32px_rgb(38_52_47/0.08)] sm:p-6 lg:p-10">
        <div className="mb-6">
          <SectionHeading
            id="finder-title"
            eyebrow="Tailored journey studio"
            title="Not sure where to go?"
            description="Tell us your timing, pace, and passions. Start with a personal trip brief, ready for your next journey."
          />
          <p className="mt-3 text-sm text-muted">
            Planning preview: your choices stay in this browser tab. Live agency
            matching and account saving are in preparation.
          </p>
        </div>
        <form
          onSubmit={submit}
          onChange={() => setBrief("")}
          className="space-y-6"
          aria-label="Smart Trip Finder"
        >
          <Step number="01" title="Where will you start?">
            <RadioChoices
              name="hub"
              initial={search.hub}
              options={hubs.map((hub) => [hub, ""] as const)}
            />
            <div className="mt-3 grid gap-3 sm:grid-cols-2">
              <label
                className="text-sm font-medium"
                htmlFor="finder-destination"
              >
                Destination idea{" "}
                <span className="font-normal text-muted">(optional)</span>
                <input
                  id="finder-destination"
                  name="destination"
                  type="text"
                  maxLength={100}
                  defaultValue={search.q}
                  placeholder="Open to ideas"
                  className="home-planning-input"
                />
              </label>
              <label className="text-sm font-medium" htmlFor="finder-season">
                Preferred season
                <select
                  id="finder-season"
                  name="season"
                  defaultValue={search.season}
                  className="home-planning-input"
                >
                  {seasons.map((season) => (
                    <option key={season}>{season}</option>
                  ))}
                </select>
              </label>
            </div>
          </Step>
          <Step number="02" title="Trip duration">
            <RadioChoices
              name="duration"
              initial="6–9 days"
              options={[
                ["3–5 days", "Quick hill escapes & nature"],
                ["6–9 days", "Short walks & heritage circuits"],
                ["10–14 days", "Longer trails & exploration"],
                ["15+ days", "Time for a deeper journey"],
              ]}
            />
          </Step>
          <Step number="03" title="Total group budget preference (NPR)">
            <RadioChoices
              name="budget"
              initial="NPR 50,000–100,000"
              options={[
                ["NPR 30,000–50,000", ""],
                ["NPR 50,000–100,000", ""],
                ["NPR 100,000–200,000", ""],
                ["NPR 200,000+", ""],
              ]}
            />
            <p className="mt-2 text-xs text-muted">
              A preference for your whole group, not a package price or cost
              estimate.
            </p>
          </Step>
          <Step number="04" title="Who is traveling?">
            <label
              htmlFor="finder-travelers"
              className="block max-w-xs text-sm font-medium"
            >
              Number of travelers
              <input
                id="finder-travelers"
                name="travelers"
                type="number"
                min={1}
                max={10000}
                required
                defaultValue={search.travelers}
                className="home-planning-input"
              />
            </label>
          </Step>
          <Step
            number="05"
            title="Travel passions & pace (select all that apply)"
          >
            <div className="flex flex-wrap gap-2">
              {[
                ["Trekking", "High-altitude trekking"],
                ["Wildlife", "Wildlife & jungles"],
                ["Monasteries", "Spirituality & monasteries"],
                ["Heritage", "Heritage architecture"],
                ["Wellness", "Lodges & wellness"],
                ["Rivers", "Adventure & rivers"],
              ].map(([value, label]) => (
                <label
                  key={value}
                  className="home-choice justify-start gap-2 px-3.5 py-2"
                >
                  <input
                    name="interests"
                    type="checkbox"
                    value={value}
                    defaultChecked={
                      value === "Trekking" || value === "Wildlife"
                    }
                    className="size-4 shrink-0 accent-primary"
                  />
                  <span className="text-sm">{label}</span>
                </label>
              ))}
            </div>
          </Step>
          <div className="flex flex-col items-start justify-between gap-4 border-t border-border pt-6 sm:flex-row sm:items-center">
            <p className="flex max-w-lg items-start gap-2 text-sm text-muted">
              <Icon name="compass" className="mt-0.5 shrink-0 text-primary" />
              Build a planning brief. No booking, quote, or live package match
              is created.
            </p>
            <button
              type="submit"
              className="home-action w-full bg-primary text-white hover:bg-primary-hover sm:w-auto"
            >
              Create my trip brief
              <Icon name="arrow" />
            </button>
          </div>
          {brief && (
            <div
              className="rounded-lg border border-border bg-home-inset p-5"
              role="status"
            >
              <h3 className="font-display text-xl font-semibold">
                Your journey, taking shape.
              </h3>
              <p className="mt-2 text-sm text-muted">
                Your planning brief is ready. It has not been sent to an agency
                or saved to an account.
              </p>
              <pre className="mt-4 font-sans text-sm leading-relaxed whitespace-pre-wrap break-words">
                {brief}
              </pre>
              <a
                href={`data:text/plain;charset=utf-8,${encodeURIComponent(brief)}`}
                download="ghumne-trip-brief.txt"
                className="home-text-link mt-4"
              >
                <Icon name="download" />
                Download your trip brief
              </a>
            </div>
          )}
        </form>
      </div>
    </section>
  );
}
