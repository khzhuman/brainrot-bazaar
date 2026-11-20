// BRAINROT BAZAAR — hand-in program for the roblox-brainrot-01 entry.
//
// What this does, start to finish: it takes the finished game sitting beside
// this file — the binary place (game.rbxl), the Luau sources under src/, the
// screenshots/ folder and the PLAY.json link file — copies the lot into the
// output directory, and finishes by writing dossier.json there, the summary
// of the place that the kit's vendored library (vendor/makefun-roblox.ts)
// builds from those very files. The grader rebuilds that dossier with the
// same library and compares byte for byte, so the options handed to
// buildDossier below are part of the entry and stay exactly as they are.
//
// Two house rules shape the copying:
//   * Nothing under the output may carry a name outside letters, digits and
//     . _ - , and no name may start with a dot — a stray .gitkeep or
//     .DS_Store fails the entry before it is judged. The copy filter drops
//     every dotted name, at any depth, on the way over.
//   * PLAY.json must name the published place — Brainrot Bazaar, place
//     71774662795438 in universe 10777948004 — or the link check refuses
//     the entry before anything else runs.
//
// On a developer machine, MAKEFUN_OUTPUT_DIR points the output somewhere
// harmless instead of /output:
//   mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
// (Node 22, standard library only — nothing is installed before this runs.)

import { copyFileSync, cpSync, existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

// The folder this file lives in is the repository root: every input is
// read from beside it, never from the caller's working directory.
const repoRoot = fileURLToPath(new URL('.', import.meta.url));
const outputDir = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

// cpSync filter with one job: keep any file or folder whose name does not
// begin with a dot, so hidden leftovers never reach the output.
function isVisibleName(sourcePath: string): boolean {
  return !basename(sourcePath).startsWith('.');
}

console.log('Brainrot Bazaar: copying the game into the output and writing its dossier.');

// The place itself and the link file that names it on Roblox.
copyFileSync(join(repoRoot, 'game.rbxl'), join(outputDir, 'game.rbxl'));
copyFileSync(join(repoRoot, 'PLAY.json'), join(outputDir, 'PLAY.json'));

// Every Luau source, laid out as Rojo keeps them.
cpSync(join(repoRoot, 'src'), join(outputDir, 'src'), { recursive: true, filter: isVisibleName });

// The screenshots, first by name first: that one is the cover.
mkdirSync(join(outputDir, 'screenshots'), { recursive: true });
const shotsDir = join(repoRoot, 'screenshots');
if (existsSync(shotsDir)) {
  cpSync(shotsDir, join(outputDir, 'screenshots'), { recursive: true, filter: isVisibleName });
}

// Last, the dossier — written from the output folder itself, so it
// describes exactly what was handed in. The caps mirror the scorer's own:
// dossier text cut at 65536 bytes, at most 4 screenshots of at most
// 262144 bytes each, a place of at most 500000 instances whose scripts
// hold at most 8388608 bytes of source along at most 1048576 characters
// of instance paths.
const dossierText = buildDossier(outputDir, {
  text_max_bytes: 65536,
  screenshots: { max: 4, max_bytes: 262144 },
  max_instances: 500000,
  scripts_max_source_bytes: 8388608,
  scripts_max_path_chars: 1048576,
});
writeFileSync(join(outputDir, 'dossier.json'), dossierText);
