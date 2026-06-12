import { ExternalLink } from 'react-external-link';
import type { SelectedServer } from '../servers/data';
import { isReachableServer } from '../servers/data';
import { versionToPrintable, versionToSemVer } from '../utils/helpers/version';

const DHIALINK_WEB_CLIENT_VERSION = '%_VERSION_%';
const normalizeVersion = (version: string) => versionToPrintable(versionToSemVer(version));

export interface ShlinkVersionsProps {
  selectedServer: SelectedServer;
  clientVersion?: string;
}

const VersionLink = ({ project, version }: { project: string; version: string }) => (
  <ExternalLink href={`https://github.com/dhiarlink/${project}/releases/${version}`} className="text-dh-muted hover:text-dh-accent">
    <b>{version}</b>
  </ExternalLink>
);

export const ShlinkVersions = ({ selectedServer, clientVersion = DHIALINK_WEB_CLIENT_VERSION }: ShlinkVersionsProps) => {
  const normalizedClientVersion = normalizeVersion(clientVersion);

  return (
    <small className="text-dh-muted font-mono text-xs">
      {isReachableServer(selectedServer) && (
        <>Server: <VersionLink project="dhiarlink" version={selectedServer.printableVersion} /> — </>
      )}
      Client: <VersionLink project="dhiarlink-web-client" version={normalizedClientVersion} />
    </small>
  );
};
