/// <reference types="bun" />

import { syncTocVersion } from "./sync-toc-version";

const root = `${import.meta.dir}/..`;

const changeset = Bun.spawn(["changeset", "version"], {
  cwd: root,
  stdout: "inherit",
  stderr: "inherit",
  stdin: "inherit",
});

const exitCode = await changeset.exited;
if (exitCode !== 0) {
  process.exit(exitCode);
}

await syncTocVersion();
