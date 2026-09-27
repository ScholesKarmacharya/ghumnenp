// No application schema has been created yet. Keep table/RPC access unavailable
// until Phase 3 replaces this boundary with types generated from its migrations.
export type Database = {
  public: {
    Tables: Record<never, never>;
    Views: Record<never, never>;
    Functions: Record<never, never>;
    Enums: Record<never, never>;
    CompositeTypes: Record<never, never>;
  };
};
