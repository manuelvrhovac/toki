### Authentication: `COLGEN_TOKEN`

Colgen needs access to the **storage repo**, which is private by default. To enable this, follow these steps:

1. Grab a personal access token over at [GitHub](https://github.com/settings/tokens) and make sure it has access `repo` at least.
2. Open your ZSHRC or BSHRC file
3. Add the token somewhere in the file: `export COLGEN_TOKEN=...
4. Restart Terminal to load token into the session