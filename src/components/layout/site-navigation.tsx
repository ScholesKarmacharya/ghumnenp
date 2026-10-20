"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useId, useRef, useState } from "react";

import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils/cn";

import type { NavigationItem } from "./navigation";

type NavigationProps = { items: readonly NavigationItem[] };

function ResponsiveNavigation({
  items,
  pathname,
}: NavigationProps & { pathname: string }) {
  const [open, setOpen] = useState(false);
  const panelId = useId();
  const trigger = useRef<HTMLButtonElement>(null);
  const mobile = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!open) return;
    function onKeyDown(event: KeyboardEvent) {
      if (event.key === "Escape") {
        setOpen(false);
        trigger.current?.focus();
      }
    }
    function onPointerDown(event: PointerEvent) {
      if (
        event.target instanceof Node &&
        !mobile.current?.contains(event.target)
      )
        setOpen(false);
    }
    function onViewportChange(event: MediaQueryListEvent) {
      if (event.matches) setOpen(false);
    }
    const desktop = window.matchMedia("(min-width: 64rem)");
    document.addEventListener("keydown", onKeyDown);
    document.addEventListener("pointerdown", onPointerDown);
    desktop.addEventListener("change", onViewportChange);
    return () => {
      document.removeEventListener("keydown", onKeyDown);
      document.removeEventListener("pointerdown", onPointerDown);
      desktop.removeEventListener("change", onViewportChange);
    };
  }, [open]);

  function links() {
    return items.map(({ href, label }) => (
      <li
        key={href}
        className={
          href === "/" || href === "/#for-agencies" ? "lg:hidden" : undefined
        }
      >
        <Link
          href={href}
          onClick={() => setOpen(false)}
          aria-current={pathname === href ? "page" : undefined}
          className={cn(
            "flex min-h-control items-center rounded px-2 py-2 text-sm font-medium hover:bg-home-inset hover:text-primary",
            pathname === href
              ? "bg-surface-muted text-primary"
              : "text-foreground",
          )}
        >
          {label}
        </Link>
      </li>
    ));
  }

  return (
    <>
      <nav aria-label="Primary" className="hidden min-w-0 lg:block">
        <ul className="flex flex-wrap gap-2">{links()}</ul>
      </nav>
      <div
        ref={mobile}
        className="lg:hidden"
        onBlur={(event) => {
          if (!event.currentTarget.contains(event.relatedTarget))
            setOpen(false);
        }}
      >
        <Button
          ref={trigger}
          variant="secondary"
          aria-expanded={open}
          aria-controls={panelId}
          aria-label={open ? "Close navigation" : "Open navigation"}
          onClick={() => setOpen((value) => !value)}
        >
          {open ? "Close" : "Menu"}
        </Button>
        <nav
          id={panelId}
          aria-label="Mobile"
          hidden={!open}
          className="absolute inset-x-0 top-full border-b border-border bg-surface px-gutter py-4 shadow-card"
        >
          <ul className="space-y-2">{links()}</ul>
        </nav>
      </div>
    </>
  );
}

export function SiteNavigation(props: NavigationProps) {
  const pathname = usePathname();
  // A route change remounts the menu in its closed state.
  return <ResponsiveNavigation key={pathname} {...props} pathname={pathname} />;
}
