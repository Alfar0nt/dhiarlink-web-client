import { faSyncAlt as reloadIcon } from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { Button, CloseButton, useToggle } from '@shlinkio/shlink-frontend-kit';
import { clsx } from 'clsx';
import type { FC } from 'react';
import { useCallback } from 'react';

interface AppUpdateBannerProps {
  isOpen: boolean;
  onClose: () => void;
  forceUpdate: () => void;
}

export const AppUpdateBanner: FC<AppUpdateBannerProps> = ({ isOpen, onClose, forceUpdate }) => {
  const { flag: isUpdating, setToTrue: setUpdating } = useToggle();
  const update = useCallback(() => {
    setUpdating();
    forceUpdate();
  }, [forceUpdate, setUpdating]);

  if (!isOpen) {
    return null;
  }

  return (
    <div
      role="alert"
      className={clsx(
        'w-[700px] max-w-[calc(100%-30px)]',
        'fixed top-[35px] left-[50%] translate-x-[-50%] z-[1040]',
        'rounded-xl border border-dh-accent/30 bg-dh-card shadow-2xl shadow-black/50',
      )}
    >
      <div className="flex items-center justify-between px-5 py-3 border-b border-dh-border">
        <h5 className="text-dh-text font-medium">This app has just been updated!</h5>
        <CloseButton onClick={onClose} />
      </div>
      <div className="flex gap-4 items-center justify-between px-5 py-4 max-md:flex-col">
        <span className="text-dh-muted">Restart it to enjoy the new features.</span>
        <Button disabled={isUpdating} variant="secondary" solid onClick={update}>
          {!isUpdating && <>Restart now <FontAwesomeIcon icon={reloadIcon} /></>}
          {isUpdating && <>Restarting...</>}
        </Button>
      </div>
    </div>
  );
};
