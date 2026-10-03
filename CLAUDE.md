# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Qué es este repo

Banco de pruebas de empaquetado y despliegue de plugins vía catálogos de marketplace. La raíz del repo es
el **catálogo** (`jovazcode-marketplace`, publicado en `github.com/jovazcode/MARKETPLACE`) y cada plugin vive
en `plugins/<nombre>/`. Debe seguir siendo importable a la vez en **ChatGPT Business / Codex** y en
**Claude Code**; no hay código ejecutable, solo manifiestos JSON y Markdown.

## Arquitectura de manifiestos

Cada cliente lee un archivo distinto; los cinco describen lo mismo y deben coincidir en `name` y `version`:

| Archivo | Quién lo lee |
|---|---|
| `.agents/plugins/marketplace.json` | Importador de ChatGPT Business y `codex plugin marketplace add` |
| `.claude-plugin/marketplace.json` | `/plugin marketplace add` de Claude Code |
| `plugins/<p>/plugin.json` | Manifiesto portable Agent Plugins 1.0 (ChatGPT/Codex). Sin `extensions.com.openai`: si se añade, **sustituye** por completo al overlay de `.codex-plugin/` en vez de fusionarse |
| `plugins/<p>/.codex-plugin/plugin.json` | Overlay Codex: bloque `interface` (displayName, categoría, `defaultPrompt`) y `skills` |
| `plugins/<p>/.claude-plugin/plugin.json` | Claude Code. `commands/` y `skills/` se descubren solos; no se declaran |

- `skills/<skill>/SKILL.md` es el **único componente portable** entre clientes. `commands/*.md` solo lo ve
  Claude Code (se expone como `/<plugin>:<comando>`). Todo lo que deba funcionar en ChatGPT va en una skill.
- Los archivos de apoyo de una skill van en `skills/<skill>/references/` y se enlazan desde `SKILL.md` por ruta
  relativa (convención común a OpenAI y Claude Code; se cargan bajo demanda al activar la skill). Cada archivo
  lleva una firma arbitraria (`🥐 [ref:fr-01]`) que la skill debe reproducir: si aparece en la respuesta, el
  archivo se leyó; si falta, el modelo contestó de memoria.
- Subir de versión implica tocar las cinco ubicaciones. En Claude Code, la `version` de
  `.claude-plugin/plugin.json` pisa a la del catálogo.
- Las entradas del catálogo Codex llevan `policy.installation` / `policy.authentication` y `category` porque
  el formato los exige, pero el importador de ChatGPT **los ignora**: la política la fija el admin tras importar.

## Comandos

No hay CLI `claude` ni `codex` en el PATH de esta máquina; la validación local es por sintaxis y consistencia:

```bash
# Parsear los 5 manifiestos y comprobar que name/version coinciden
node -e '
const fs=require("fs");const r=f=>JSON.parse(fs.readFileSync(f,"utf8"));
const p=["plugins/hello-world/plugin.json","plugins/hello-world/.codex-plugin/plugin.json","plugins/hello-world/.claude-plugin/plugin.json"].map(r);
const cc=r(".claude-plugin/marketplace.json"),cx=r(".agents/plugins/marketplace.json");
const vs=new Set([...p.map(x=>x.version),cc.plugins[0].version]);
console.log(vs.size===1?"OK version "+[...vs][0]:"VERSION MISMATCH "+[...vs]);
console.log(cc.name===cx.name?"OK marketplace name":"MARKETPLACE NAME MISMATCH");'
```

Con los CLIs instalados:

```bash
claude plugin validate .                              # catálogo
claude plugin validate ./plugins/hello-world          # plugin
claude --plugin-dir ./plugins/hello-world             # cargar el plugin solo en esta sesión
claude plugin marketplace add .                       # registrar el catálogo local
claude plugin install hello-world@jovazcode-marketplace
codex plugin marketplace add ./                       # idem para Codex
```

Dentro de una sesión de Claude Code: `/plugin marketplace add <ruta-o-owner/repo>`, `/plugin install
hello-world@jovazcode-marketplace`, `/reload-plugins`, `/hello-world:hello`.

Despliegue: `git push` a `main`. ChatGPT sincroniza a diario; para verlo al momento, el admin pulsa
**Sync now** en Workspace settings › Plugins y prueba en un **chat nuevo** (los chats abiertos conservan el
catálogo antiguo).

Estado verificado el 2026-10-03: en ChatGPT la skill de un plugin importado desde GitHub **solo se ejecuta en el
ámbito Work** (runtime Codex; responde "ejecutándose desde Codex"). En el ámbito Chat el plugin aparece con `@`
pero el modelo no encuentra la skill. Es un fallo conocido de la plataforma, no del empaquetado
(github.com/mitjasiska/agentic-workflows/issues/5 y community.openai.com hilos 1380754 y 1400659); no
reescribir manifiestos para "arreglarlo". Para validar un plugin nuevo, probar en Work o en Codex CLI.

## Añadir un plugin nuevo

1. Crear `plugins/<nombre>/` con los tres manifiestos (`plugin.json`, `.codex-plugin/plugin.json`,
   `.claude-plugin/plugin.json`) y al menos `skills/<skill>/SKILL.md`. Copiar `hello-world` como plantilla. Si la skill necesita
   archivos de apoyo, van en `skills/<skill>/references/` enlazados por ruta relativa desde `SKILL.md`.
2. Añadir la entrada en **ambos** catálogos: `.agents/plugins/marketplace.json` (con `source.path`,
   `policy`, `category`) y `.claude-plugin/marketplace.json` (con `source` relativo).
3. Nombres en kebab-case; no pueden empezar por `claude-`, `anthropic-` ni `cc-plugin-`.
4. Documentar la instalación en `README.md` y pasar la validación de arriba.
