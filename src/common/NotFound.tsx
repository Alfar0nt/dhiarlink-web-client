import { Button } from '@shlinkio/shlink-frontend-kit';
import type { FC, PropsWithChildren } from 'react';
import { ErrorLayout } from './ErrorLayout';

type NotFoundProps = PropsWithChildren<{ to?: string }>;

export const NotFound: FC<NotFoundProps> = ({ to = '/', children = 'Home' }) => (
  <ErrorLayout title="> 404: Route not found">
    <p>
      Use your browser&apos;s back button to navigate to the page you have previously come from, or just press this
      button.
    </p>
    <br />
    <Button inline to={to} size="lg">{children}</Button>
  </ErrorLayout>
);
