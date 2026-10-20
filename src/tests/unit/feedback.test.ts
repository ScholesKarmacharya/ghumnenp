import { createElement } from "react";
import { renderToStaticMarkup } from "react-dom/server";
import { describe, expect, it, vi } from "vitest";

import PublicError from "@/app/(public)/error";
import PublicLoading from "@/app/(public)/loading";
import GlobalError from "@/app/global-error";
import {
  EmptyState,
  ErrorState,
  SuccessMessage,
} from "@/components/ui/feedback";
import { LoadingState } from "@/components/ui/loading-state";

describe("feedback contracts", () => {
  it("names the loading status and hides all skeleton content", () => {
    const html = renderToStaticMarkup(
      createElement(LoadingState, { label: "Finding trips…" }),
    );
    expect(html).toContain('role="status"');
    expect(html).toContain("Finding trips…");
    expect(html.match(/aria-hidden="true"/g)).toHaveLength(4);
    expect(html).toContain("motion-safe:animate-pulse");
  });

  it("supports the page heading level and a real empty-state recovery link", () => {
    const html = renderToStaticMarkup(
      createElement(EmptyState, {
        headingAs: "h1",
        title: "No trips yet",
        description: "Create a plan to get started.",
        action: createElement("a", { href: "/" }, "Explore"),
      }),
    );
    expect(html).toContain("<h1>No trips yet</h1>");
    expect(html).toContain('aria-label="No trips yet"');
    expect(html).toContain('href="/"');
    expect(html).not.toContain('role="alert"');
  });

  it("announces errors and success with meaningful text", () => {
    expect(
      renderToStaticMarkup(
        createElement(ErrorState, {
          title: "Try again",
          description: "We could not load your trip.",
        }),
      ),
    ).toContain('role="alert"');
    expect(
      renderToStaticMarkup(
        createElement(SuccessMessage, null, "Your plan was saved."),
      ),
    ).toContain('role="status"');
  });

  it.each([PublicError, GlobalError])(
    "keeps internal error details private and wires the actual reset callback",
    (Boundary) => {
      const reset = vi.fn();
      const error = Object.assign(new Error("PRIVATE_DATABASE_TOKEN_123"), {
        digest: "PRIVATE_DIGEST_123",
      });
      const element = Boundary({ error, reset });
      const html = renderToStaticMarkup(element);
      expect(html).not.toContain("PRIVATE_");
      expect(html).toContain('id="main-content"');
      expect(html).toContain('href="/"');
      // The server boundary adapter must hand Next's reset to its real button.
      const main =
        element.type === "html"
          ? element.props.children.props.children
          : element;
      const actions = main.props.children.props.action.props.children;
      actions[0].props.onClick();
      expect(reset).toHaveBeenCalledOnce();
    },
  );

  it("supplies a document shell only for the global boundary", () => {
    const html = renderToStaticMarkup(
      createElement(GlobalError, {
        error: new Error("private"),
        reset: vi.fn(),
      }),
    );
    expect(html).toContain('<html lang="en">');
    expect(html).toContain("<body>");
    expect(html).toContain("<h1");
    const loading = renderToStaticMarkup(createElement(PublicLoading));
    expect(loading).toContain('id="main-content"');
    expect(loading).toContain('role="status"');
  });
});
