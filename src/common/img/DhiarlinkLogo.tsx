export interface DhiarlinkLogoProps {
  color?: string;
  className?: string;
}

/**
 * Dhiarlink logo — a terminal/hacker-aesthetic mark.
 * Combines a `>_` prompt motif with a link/chain element,
 * rendered as clean geometric paths.
 */
export const DhiarlinkLogo = ({ color = '#4a9a8e', className }: DhiarlinkLogoProps) => (
  <svg className={className} viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
    {/* Terminal prompt bracket ">" */}
    <path
      d="M80 128L224 256L80 384"
      fill="none"
      stroke={color}
      strokeWidth="38"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
    {/* Cursor underscore "_" */}
    <rect
      x="248"
      y="348"
      width="120"
      height="36"
      rx="8"
      fill={color}
      opacity="0.7"
    />
    {/* Link chain arc — top right */}
    <path
      d="M300 148C300 148 340 108 400 108C460 108 480 148 480 208C480 268 440 308 440 308"
      fill="none"
      stroke={color}
      strokeWidth="32"
      strokeLinecap="round"
    />
    {/* Link chain arc — bottom connecting */}
    <path
      d="M280 240L360 240"
      fill="none"
      stroke={color}
      strokeWidth="32"
      strokeLinecap="round"
    />
    {/* Dot accent — blinking cursor feel */}
    <circle
      cx="408"
      cy="352"
      r="18"
      fill={color}
      opacity="0.5"
    />
  </svg>
);
