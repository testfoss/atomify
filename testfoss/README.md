# Testfoss Atomify browser demo

This additive demo uses the public Atomify source at `7a23b7b35530758656308560a63c0e2959c3184e`. The committed npm manifests remain unchanged and resolve `lammps.js@1.6.2` from the registry.

The fixtures are portable Lennard-Jones inputs. `in.smoke-lj` runs 100 steps for the automated completion/replay check; `in.local-lj` completes 20,000 steps and `in.control-lj` runs 100,000 steps for longer manual experiments.

## Reproduce

Use Node.js 24, npm, Git, curl, and a platform supported by Playwright Chromium:

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

The last command starts the production preview on port 5201, runs `testfoss/browser/production.lms` through `lmscript` and `lmwebtest playwright`, and stops the server. It checks engine readiness, 108-atom setup, 100-step completion metadata, normal completion and `Loop time`, and a second completed run. Cancellation is not asserted: a long-run Stop diagnostic left the stop control present after two minutes. The screenshot and server log go to the ignored `testfoss/results/` directory. Set `ATOMIFY_PORT` or `ATOMIFY_URL` to override the preview location.

The tool bootstrap pins `@lmctl-ai/lmctl@0.2.454` and `lmctl-ai/lmwebtest@2920befd355eacc654697820d690db074e94dce3`. Tool checkouts, npm dependencies, and browsers are disposable and are never demo artifacts to commit.

`browser/read-engine.js` is the lab's optional development-server probe. It imports `/atomify/src/store/index.ts`, so it is deliberately not used by the production test. The production scenario relies only on the public UI.

## Engine evidence boundary

CI and the commands above exercise the upstream registry package, not a fresh LAMMPS compilation. A separate isolated molecular lab run built the pinned `lammps.js` source with Emscripten 4.0.18 and verified Atomify against that engine; see `durable-memory/status.md`. No engine tarball, `dist`, build directory, or `node_modules` belongs in this fork.
