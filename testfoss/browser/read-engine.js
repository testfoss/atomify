async (page) => {
  return page.evaluate(async () => {
    const storeModule = await import("/atomify/src/store/index.ts");
    const { engine } = storeModule;
    const state = storeModule.default.getState();
    const particles = engine.particles;
    return {
      capturedAt: new Date().toISOString(),
      crossOriginIsolated: self.crossOriginIsolated,
      engineVariant: engine.lammps?.variant ?? null,
      paused: engine.lammps?.isPaused() ?? null,
      currentStep: engine.lammps?.getTimesteps() ?? null,
      runStepsDone: engine.lammps?.getRunTimesteps() ?? null,
      runStepsTotal: engine.lammps?.getRunTotalTimesteps() ?? null,
      status: {
        timesteps: state.simulationStatus.timesteps,
        runTimesteps: state.simulationStatus.runTimesteps,
        runTotalTimesteps: state.simulationStatus.runTotalTimesteps,
        numAtoms: state.simulationStatus.numAtoms,
        numBonds: state.simulationStatus.numBonds,
        runType: state.simulationStatus.runType,
      },
      particleCount: particles?.count ?? 0,
      positions: particles
        ? Array.from(particles.positions.slice(0, Math.min(18, particles.count * 3)))
        : [],
      activeRun: state.projects.activeRun,
    };
  });
}
