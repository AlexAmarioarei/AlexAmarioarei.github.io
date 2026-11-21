// Post-render hook for the English (default) project.
// After a FULL render of the English site (`quarto render`), this
// renders the Romanian project in ro/ into _site/ro/.
// It runs with the Deno runtime bundled with Quarto: nothing to install.
// Partial renders (a single file, or live preview updates) skip it.

const SECOND_LANGUAGE_DIR = "ro";

if (Deno.env.get("QUARTO_PROJECT_RENDER_ALL") === "1") {
  const sep = Deno.build.os === "windows" ? "\\" : "/";
  const binDir = Deno.env.get("QUARTO_BIN_PATH");
  const candidates = binDir
    ? (Deno.build.os === "windows"
        ? [binDir + sep + "quarto.exe", binDir + sep + "quarto.cmd"]
        : [binDir + sep + "quarto"])
    : [];
  let quarto = "quarto";
  for (const c of candidates) {
    try {
      Deno.statSync(c);
      quarto = c;
      break;
    } catch (_) { /* try next */ }
  }

  // Do not leak the parent project's variables into the child render.
  const env: Record<string, string> = {};
  for (const [k, v] of Object.entries(Deno.env.toObject())) {
    if (!k.startsWith("QUARTO_PROJECT")) env[k] = v;
  }

  console.log(`\nRendering the Romanian site (${SECOND_LANGUAGE_DIR}/) ...`);
  const cmd = new Deno.Command(quarto, {
    args: ["render", SECOND_LANGUAGE_DIR],
    env,
    clearEnv: true,
    stdout: "inherit",
    stderr: "inherit",
  });
  const result = await cmd.output();
  if (!result.success) {
    console.error("Romanian site failed to render.");
    Deno.exit(1);
  }
}
