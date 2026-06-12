import { faCogs as cogsIcon } from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { NavBar } from '@shlinkio/shlink-frontend-kit';
import type { FC } from 'react';
import { Link, useLocation } from 'react-router';
import { ServersDropdown } from '../servers/ServersDropdown';
import { DhiarlinkLogo } from './img/DhiarlinkLogo';

export const MainHeader: FC = () => {
  const { pathname } = useLocation();

  const settingsPath = '/settings';

  return (
    <NavBar
      className="[&]:fixed top-0 z-900"
      brand={(
        <Link to="/" className="[&]:text-dh-text no-underline flex items-center gap-2">
          <DhiarlinkLogo className="w-7" color="#4a9a8e" /> <small className="font-normal tracking-wide">Dhiarlink</small>
        </Link>
      )}
    >
      <NavBar.MenuItem
        to={settingsPath}
        active={pathname.startsWith(settingsPath)}
        className="flex items-center gap-1.5"
      >
        <FontAwesomeIcon icon={cogsIcon} /> Settings
      </NavBar.MenuItem>
      <ServersDropdown />
    </NavBar>
  );
};
