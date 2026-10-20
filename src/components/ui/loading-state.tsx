import { cn } from "@/lib/utils/cn";

export function Skeleton({ className = "h-4 w-full" }: { className?: string }) {
  return (
    <div
      aria-hidden="true"
      className={cn(
        "rounded-control bg-surface-muted motion-safe:animate-pulse",
        className,
      )}
    />
  );
}

export function LoadingState({ label = "Loading…" }: { label?: string }) {
  return (
    <div className="w-full max-w-reading space-y-6 py-8">
      <p role="status" className="font-medium text-muted">
        {label}
      </p>
      <div aria-hidden="true" className="space-y-3">
        <Skeleton className="h-8 w-2/3" />
        <Skeleton />
        <Skeleton className="h-4 w-4/5" />
      </div>
    </div>
  );
}
