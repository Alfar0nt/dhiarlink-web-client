import type { FC, PropsWithChildren } from 'react';

export type ErrorLayoutProps = PropsWithChildren<{
  title: string;
}>;

export const ErrorLayout: FC<ErrorLayoutProps> = ({ children, title }) => (
  <div className="pt-4">
    <div className="rounded-xl border border-dh-border bg-dh-card shadow-lg shadow-black/30 p-6 w-full lg:w-[65%] m-auto">
      <h2 className="text-dh-text text-xl font-medium mb-4">{title}</h2>
      <div className="text-dh-muted">{children}</div>
    </div>
  </div>
);
