// Every project shown on sparshlabs.com. Adding a project is one entry here, plus a Worker route
// for its site (see README.md, "Adding a project").
export interface Project {
  /** Path segment on sparshlabs.com, also the CSS hook for the project's mark. */
  slug: 'sparsh' | 'ownci'
  name: string
  tagline: string
  pitch: string
  points: string[]
  status: string
  /** One copy-pasteable command, shown on the card. */
  install: string
  /** Where the project says what it does not do. */
  limits: { label: string; href: string }
  license: string
  site: string
  repo: string
}

export const projects: Project[] = [
  {
    slug: 'sparsh',
    name: 'sparsh',
    tagline: 'Trustworthy touch',
    pitch:
      'Stops a tap from activating the wrong thing when the interface changes under the finger: a new message slides in, a row shifts, a button changes meaning mid-press.',
    points: [
      'Checks age, continuity, semantics and double fire on every activation',
      'React, Vue and plain DOM bindings on npm as @sparshlabs/*',
      'Enforce or report mode, with a reason for every block',
    ],
    status: 'v0.1 · npm',
    install: 'npm install @sparshlabs/react',
    limits: {
      label: 'Known limitations',
      href: 'https://github.com/ashfaqc137/sparsh/blob/master/LIMITATIONS.md',
    },
    license: 'MIT',
    site: '/sparsh/',
    repo: 'https://github.com/ashfaqc137/sparsh',
  },
  {
    slug: 'ownci',
    name: 'OwnCI',
    tagline: 'Your PR. Your Compute.',
    pitch:
      'Turns your Linux machine into a GitHub Actions runner for your repository, with one command each to set it up, start it, stop it and remove it.',
    points: [
      'Supervises the official actions/runner; GitHub keeps the PR check',
      'Every job runs inside a Docker container, wiped after each run',
      'One install script for Linux and WSL2, amd64 and arm64',
    ],
    status: 'v0.1.0 · MVP',
    install: 'curl -fsSL https://github.com/ashfaqc137/ownci/releases/latest/download/install.sh | sh',
    limits: { label: 'What it doesn’t protect against', href: '/ownci/security/' },
    license: 'MIT',
    site: '/ownci/',
    repo: 'https://github.com/ashfaqc137/ownci',
  },
]
