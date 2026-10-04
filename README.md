# jovazcode-marketplace

Banco de pruebas para empaquetar y desplegar plugins a través de catálogos de marketplace.
Un único repositorio sirve de catálogo para **ChatGPT Business / Codex** y para **Claude Code**,
siguiendo el patrón de repos como [AvdLee/SwiftUI-Agent-Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill).

Primer plugin: `hello-world`, un saludo mínimo que confirma que la instalación funciona. Desde la 0.3.0 saluda
por nombre: el nombre lo devuelve la tool `getUserName` de un MCP Server propio escrito en Dart, declarado
dentro del plugin.

## Estructura

```
.agents/plugins/marketplace.json     # catálogo que lee ChatGPT Business / Codex
.claude-plugin/marketplace.json      # catálogo que lee Claude Code
plugins/
└── hello-world/
    ├── plugin.json                  # manifiesto portable (Agent Plugins 1.0)
    ├── .codex-plugin/plugin.json    # overlay Codex: nombre visible, categoría, prompts sugeridos
    ├── .claude-plugin/plugin.json   # manifiesto Claude Code (incluye mcpServers)
    ├── mcp.json                     # MCP Servers del plugin para ChatGPT / Codex
    ├── skills/hello-world/
    │   ├── SKILL.md                 # la skill, común a todos los clientes
    │   └── references/{es,en,fr,de}.md  # reglas de saludo por idioma (archivos adjuntos a la skill)
    └── commands/hello.md            # slash command, solo Claude Code
mcp/servers/
└── auth/                            # MCP Server en Dart (mcp_dart): tool getUserName, sin autenticación
```

## MCP Server

El plugin apunta a `https://io.loanoor.com/mcp`. Ese endpoint es un proxy de Apache hacia el servidor Dart de
[mcp/servers/auth/](mcp/servers/auth/), que corre en un desktop: **solo responde mientras el servidor está
arrancado**. Cómo arrancarlo, publicarlo y probarlo está en su [README](mcp/servers/auth/README.md).

Cada cliente lee la declaración de un sitio distinto: ChatGPT / Codex de `mcp.json` y Claude Code de
`mcpServers` en `.claude-plugin/plugin.json`. En Claude Code, `/mcp` debe mostrar el servidor `auth` del plugin
conectado, con la tool `getUserName`. En ChatGPT Business, un plugin que declara MCP Servers queda marcado
como **Desktop only**.

## Instalación

### ChatGPT Business (lo hace un admin del workspace)

1. **Workspace settings › Plugins › Add › Import marketplace**.
2. URL del repositorio: `https://github.com/jovazcode/MARKETPLACE` (sin rama ni subcarpeta).
3. Autoriza el acceso a GitHub y revisa el resultado de la importación.
4. Configura la política de instalación del plugin `Hello World` (la importación no la aplica por sí sola).
5. Abre un **chat nuevo** y pide: *"Saluda con el plugin Hello World"* o *"Saluda en francés con Hello World"*.

La sincronización con el repo es diaria; tras un push puedes forzarla con **Sync now**.

> **Aviso (2026-10-03):** la skill solo responde en el ámbito **Work** de ChatGPT (runtime Codex). En el ámbito
> Chat el plugin se puede seleccionar con `@` pero la skill no está disponible; es un problema conocido de la
> plataforma, no del plugin. Prueba siempre desde Work o desde Codex CLI.

### Codex CLI

```bash
codex plugin marketplace add jovazcode/MARKETPLACE
```

Luego `/plugins` dentro de Codex para instalar `Hello World`.

### Claude Code

```
/plugin marketplace add jovazcode/MARKETPLACE
/plugin install hello-world@jovazcode-marketplace
```

Prueba con `/hello-world:hello` o `/hello-world:hello fr`. Para un equipo, en `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "jovazcode-marketplace": {
      "source": { "source": "github", "repo": "jovazcode/MARKETPLACE" }
    }
  },
  "enabledPlugins": {
    "hello-world@jovazcode-marketplace": true
  }
}
```

## Resultado esperado

La skill elige idioma (el pedido explícitamente; si no, el del mensaje; si no hay archivo, `en.md` con aviso),
lee `references/<idioma>.md`, pide el nombre a `getUserName` y devuelve exactamente lo que dicta ese archivo.
Por ejemplo, "Saluda en francés" con el servidor devolviendo `jovaz`:

```
Bonjour, jovaz ! 👋
Plugin hello-world v0.3.0 exécuté depuis <Claude Code | ChatGPT | Codex>.
🥐 [ref:fr-01]
```

Si el MCP Server no está conectado, el nombre no se inventa: sale el saludo anónimo con un aviso.

```
Bonjour, le Monde ! 👋
Plugin hello-world v0.3.0 exécuté depuis <Claude Code | ChatGPT | Codex>.
🥐 [ref:fr-01]
(getUserName no disponible; saludo anónimo.)
```

La tercera línea es la **firma** del archivo (`🌞 [ref:es-01]`, `🫖 [ref:en-01]`, `🥐 [ref:fr-01]`,
`🥨 [ref:de-01]`): es arbitraria, así que si aparece es que el archivo se ha leído de verdad. Si la skill
responde `No he podido leer references/...`, los archivos no se han empaquetado o el runtime no da acceso.

## Licencia

MIT.
