"use client";

import { useState } from "react";

import { Button } from "@/components/ui/button";
import { ButtonLink, TextLink } from "@/components/ui/link";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { Checkbox, Radio } from "@/components/ui/choice";
import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

export function UiPreview() {
  const [clicks, setClicks] = useState(0);
  const [submissions, setSubmissions] = useState(0);
  const [formResult, setFormResult] = useState("");

  return (
    <div className="space-y-12">
      <section aria-labelledby="cards-title" className="space-y-6">
        <h2 id="cards-title">Cards and badges</h2>
        <div className="grid gap-6 md:grid-cols-2">
          <Card aria-labelledby="example-card-title">
            <CardHeader>
              <Badge tone="primary">Example category</Badge>
              <h3 id="example-card-title">Room for a clear decision</h3>
            </CardHeader>
            <CardContent>
              <p className="text-muted">
                A reusable surface for concise information, supporting details,
                and an explicit action.
              </p>
            </CardContent>
            <CardFooter>
              <ButtonLink href="/" variant="secondary">
                View home
              </ButtonLink>
            </CardFooter>
          </Card>
          <Card aria-labelledby="example-status-title">
            <CardHeader>
              <h3 id="example-status-title">Status examples</h3>
            </CardHeader>
            <CardContent>
              <div className="flex flex-wrap gap-2">
                <Badge>Neutral</Badge>
                <Badge tone="success">Success</Badge>
                <Badge tone="warning">Needs attention</Badge>
                <Badge tone="danger">Error</Badge>
                <Badge tone="info">Information</Badge>
              </div>
              <p className="text-muted">
                Status text gives the meaning; color is supporting feedback.
              </p>
            </CardContent>
          </Card>
        </div>
      </section>
      <section aria-labelledby="buttons-title" className="space-y-6">
        <h2 id="buttons-title">Buttons and links</h2>
        <form
          className="flex flex-wrap items-center gap-4"
          onSubmit={(event) => {
            event.preventDefault();
            setSubmissions((value) => value + 1);
          }}
        >
          <Button onClick={() => setClicks((value) => value + 1)}>
            Primary action
          </Button>
          <Button variant="secondary" type="submit">
            Submit form
          </Button>
          <Button variant="ghost">Ghost action</Button>
          <Button variant="danger">Delete example</Button>
          <Button disabled>Disabled action</Button>
          <Button isLoading loadingLabel="Saving…">
            Save example
          </Button>
          <ButtonLink href="/">Back to home</ButtonLink>
          <TextLink href="/" target="_blank" rel="external">
            Open home in a new tab
          </TextLink>
        </form>
        <p role="status">
          Clicks: {clicks}. Submissions: {submissions}.
        </p>
      </section>
      <section aria-labelledby="fields-title" className="space-y-6">
        <h2 id="fields-title">Form controls</h2>
        <form
          aria-label="Example fields"
          className="grid max-w-3xl gap-6 sm:grid-cols-2"
          onSubmit={(event) => {
            event.preventDefault();
            const data = new FormData(event.currentTarget);
            setFormResult(
              `Valid fields: ${data.get("email")}, ${data.get("days")} days, ${data.get("transport")}.`,
            );
          }}
        >
          <Input
            id="example-email"
            name="email"
            label="Email"
            type="email"
            required
            autoComplete="email"
            hint="Use an email address you can access."
          />
          <Input
            id="example-days"
            name="days"
            label="Days"
            type="number"
            required
            min={1}
            max={30}
            defaultValue={3}
          />
          <Select
            id="example-transport"
            name="transport"
            label="Transport"
            defaultValue="bus"
            required
          >
            <option value="bus">Bus</option>
            <option value="bike">Bike</option>
          </Select>
          <Input
            id="example-error"
            label="Error example"
            hint="This field demonstrates an error state."
            error="Enter a value within the allowed range."
            aria-describedby="example-extra-description"
          />
          <p id="example-extra-description" className="sr-only">
            An additional description is preserved.
          </p>
          <Input
            id="example-disabled"
            label="Disabled field"
            disabled
            defaultValue="Unavailable"
          />
          <Textarea
            id="example-notes"
            name="notes"
            label="Notes"
            hint="Optional planning notes."
          />
          <Checkbox
            id="example-interest"
            name="nature"
            label="Nature interest"
          />
          <fieldset className="space-y-2">
            <legend className="font-medium">Travel pace</legend>
            <Radio
              id="example-relaxed"
              name="pace"
              label="Relaxed"
              value="relaxed"
              defaultChecked
            />
            <Radio
              id="example-active"
              name="pace"
              label="Active"
              value="active"
            />
          </fieldset>
          <Button type="submit">Validate fields</Button>
        </form>
        <p role="status" aria-label="Field validation result">
          {formResult}
        </p>
      </section>
    </div>
  );
}
