# ENVIRONMENT

Note that environment variables must have a value set to be detected. For example, run export HOMEBREW_NO_INSECURE_REDIRECT=1 rather than just export HOMEBREW_NO_INSECURE_REDIRECT.

HOMEBREW_* environment variables can also be set in Homebrew’s environment files:

- /etc/homebrew/brew.env (system-wide)

- ${HOMEBREW_PREFIX}/etc/homebrew/brew.env (prefix-specific)

- $XDG_CONFIG_HOME/homebrew/brew.env if $XDG_CONFIG_HOME is set or ~/.homebrew/brew.env otherwise (user-specific)
