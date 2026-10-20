import { LoadingState } from "@/components/ui/loading-state";

export default function PublicLoading() {
  return (
    <main
      id="main-content"
      tabIndex={-1}
      className="mx-auto max-w-page px-gutter py-12"
    >
      <LoadingState label="Loading your page…" />
    </main>
  );
}
