# Testfoss fork instructions

## Source boundary

- Atomify is pinned at `7a23b7b35530758656308560a63c0e2959c3184e` on branch `testfoss-demo`.
- The companion `lammps.js` source pin is `c6e5499716c87ba688d60e9b90edbc49d5fb748c`.
- Keep upstream source, package manifests and lockfiles, C++/LAMMPS build files, and existing workflows unchanged.
- Testfoss changes are limited to the appended README section, this file, `durable-memory/**`, `testfoss/**`, and `.github/workflows/testfoss.yml`.
- Do not commit tarballs, engine builds, `node_modules`, browser binaries, screenshots, or logs. `testfoss/.tools/` and `testfoss/results/` are disposable.
- The public demo is documentation and CI only: no deployment, credentials, or secrets.

## Reproduction

```sh
npm ci
npm run typecheck
npm run test:run
npm run build
npx playwright install --with-deps chromium
npm run e2e:smoke
testfoss/scripts/install-browser-tools.sh
testfoss/scripts/run-production-browser.sh
```

The browser tools are pinned to `@lmctl-ai/lmctl@0.2.454` and `lmctl-ai/lmwebtest@2920befd355eacc654697820d690db074e94dce3`. Every browser workflow must invoke `lmwebtest`; the `.lms` program binds `cli="lmwebtest playwright"`.

## Limitations

The committed dependency remains registry `lammps.js@1.6.2`; CI does not claim a fresh engine build. The separate local-engine evidence and its exact commands are recorded in `durable-memory/status.md`. The optional `read-engine.js` probe works only on the development server, not the production bundle. The production smoke skips its notebook case when JupyterLite was not built. Upstream Vite chunk warnings and WebGL readback performance warnings are not Testfoss failures.
