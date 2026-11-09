# Testfoss Atomify status

## Pins and scope

- Atomify: `7a23b7b35530758656308560a63c0e2959c3184e`, branch `testfoss-demo`.
- Companion lammps.js: `c6e5499716c87ba688d60e9b90edbc49d5fb748c`, package version 1.6.2.
- Browser host: `lmctl-ai/lmwebtest@2920befd355eacc654697820d690db074e94dce3`.
- LMS runner: `@lmctl-ai/lmctl@0.2.454`.
- Emscripten used by the separate engine evidence: 4.0.18 (`emsdk` repository `1693ce7359fc9694f198694f902a2cc061239b86`).
- LAMMPS source selected by the pinned build script: `stable_30Sep2026_update1`, observed at `098ffdefa525cabc82272925de02e9884f58c657`.

Only additive Testfoss files are in scope. Registry package manifests and lockfiles are intentional upstream inputs, not generated demo state.

## CI commands

The source job runs `npm ci`, `npm run typecheck`, `npm run test:run`, and `npm run build`. The browser job independently installs the same locked registry dependencies, builds production, installs Chromium, runs `npm run e2e:smoke`, and runs:

```sh
testfoss/scripts/install-browser-tools.sh
testfoss/scripts/run-production-browser.sh
```

The second command executes `testfoss/browser/production.lms` with `lmscript`; its lmcode program invokes `lmwebtest playwright`. The production scenario uses the 100-step `testfoss/fixtures/in.smoke-lj` and checks the viewport, completion metadata, Loop time, and a second completed run. The separate 20,000-step fixture remains available for manual runs; a headless 20,000-step completion attempt exceeded five minutes and is not the CI gate. No notebook site is built, so the upstream notebook smoke case is expected to skip.

## Separate genuine-engine local evidence

The companion isolated molecular lab recorded a successful source build and browser run at the same Atomify and lammps.js commits. Its engine commands were:

```sh
npm ci
EMSDK_PATH=<emsdk-4.0.18> MAKE_JOBS=2 npm test
EMSDK_PATH=<emsdk-4.0.18> MAKE_JOBS=2 npm run test:atomify-serial
EMSDK_PATH=<emsdk-4.0.18> MAKE_JOBS=2 npm run build:kokkos
EMSDK_PATH=<emsdk-4.0.18> MAKE_JOBS=2 npm run build:atomify
npx vitest run
npm run verify:pack
```

It recorded 161 passing engine tests with 3 intentional guards skipped, a verified package containing four non-stub Wasm modules, and byte-for-byte installation of that package in Atomify. Atomify then passed typecheck, two serial LJ examples, production build, four production smoke tests with the notebook test skipped, advancing coordinates and timesteps, normal 20,000-step completion, pause/resume through the app action, Stop, and a fresh run.

That lab-only build used a local `MAKE_JOBS=2` patch to `cpp/build.py`. The patch and local tarball are not carried into either public fork, and `MAKE_JOBS` is not a supported input of the pinned pristine build script. This Atomify workflow uses registry `lammps.js@1.6.2` and must not be presented as reproducing the fresh-engine evidence.

## Known limitations

- `testfoss/browser/read-engine.js` requires the development server's source module and is excluded from production checks.
- The lab observed that Space-key pause did not invoke `setPaused`; its direct app pause/resume action worked. The new production scenario verifies completion and replay, not keyboard pause or cancellation. A separate long-run Stop diagnostic left the stop control present after two minutes, and a short second run could complete before Stop; neither behavior is presented as a cancellation pass.
- Completed lab logs contained post-run `spcpu`/`cpuremain` query lines after normal Loop time and Completed status; browser console errors remained zero.
- Upstream dependency audit findings, Vite chunk warnings, and WebGL readback performance warnings were not broadly patched.
- No deployment, package publication, or secret access is configured.

## Remote verification

GitHub Actions run 42649080722 passed typecheck, unit tests, production builds, upstream production smoke, and the corrected lmwebtest completion/replay scenario using the registry engine.
