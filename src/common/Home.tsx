import { faPlus } from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { Button } from '@shlinkio/shlink-frontend-kit';
import { clsx } from 'clsx';
import type { FC } from 'react';
import { useEffect } from 'react';
import { useNavigate } from 'react-router';
import { withoutSelectedServer } from '../servers/helpers/withoutSelectedServer';
import { useServers } from '../servers/reducers/servers';
import { ServersListGroup } from '../servers/ServersListGroup';
import { DhiarlinkLogo } from './img/DhiarlinkLogo';

export const Home: FC = withoutSelectedServer(() => {
  const navigate = useNavigate();
  const { servers } = useServers();
  const serversList = Object.values(servers);
  const hasServers = serversList.length > 0;

  useEffect(() => {
    // Try to redirect to the first server marked as auto-connect
    const autoConnectServer = serversList.find(({ autoConnect }) => autoConnect);
    if (autoConnectServer) {
      navigate(`/server/${autoConnectServer.id}`);
    }
  }, [serversList, navigate]);

  return (
    <div className="px-3 w-full">
      <div className="mx-auto max-w-[720px] overflow-hidden rounded-xl border border-dh-border bg-dh-card shadow-2xl shadow-black/40">
        <div className="flex flex-col md:flex-row">
          <div className="p-6 hidden md:flex items-center w-[40%]">
            <div className="w-full">
              <DhiarlinkLogo className="w-full max-w-[180px] mx-auto" />
            </div>
          </div>

          <div className="md:border-l border-dh-border flex-grow">
            <h1
              className={clsx(
                'p-4 text-center border-dh-border text-dh-text font-mono',
                { 'border-b': !hasServers },
              )}
            >
              <span className="text-dh-accent">&gt;</span> Welcome to Dhiarlink
            </h1>
            {hasServers ? <ServersListGroup servers={serversList} /> : (
              <div className="p-6 text-center flex flex-col gap-12 text-xl">
                <p className="text-dh-muted">This application will help you manage your Dhiarlink servers.</p>
                <p>
                  <Button to="/server/create" size="lg" inline>
                    <FontAwesomeIcon icon={faPlus} widthAuto /> Add a server
                  </Button>
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
});
