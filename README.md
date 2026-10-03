# jovazcode-marketplace

Banco de pruebas para empaquetar y desplegar plugins a través de catálogos de marketplace.
Un único repositorio sirve de catálogo para **ChatGPT Business / Codex** y para **Claude Code**,
siguiendo el patrón de repos como [AvdLee/SwiftUI-Agent-Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill).

Primer plugin: `hello-world`, un saludo mínimo que confirma que la instalación funciona.

## Estructura

```
.agents/plugins/marketplace.json     # catálogo que lee ChatGPT Business / Codex
.claude-plugin/marketplace.json      # catálogo que lee Claude Code
plugins/
└── hello-world/
    ├── plugin.json                  # manifiesto portable (Agent Plugins 1.0)
    ├── .codex-plugin/plugin.json    # overlay Codex: nombre visible, categoría, prompts sugeridos
    ├── .claude-plugin/plugin.json   # manifiesto Claude Code
    ├── skills/hello-world/SKILL.md  # la skill, común a todos los clientes
    └── commands/hello.md            # slash command, solo Claude Code
```

## Instalación

### ChatGPT Business (lo hace un admin del workspace)

1. **Workspace settings › Plugins › Add › Import marketplace**.
2. URL del repositorio: `https://github.com/jovazcode/MARKETPLACE` (sin rama ni subcarpeta).
3. Autoriza el acceso a GitHub y revisa el resultado de la importación.
4. Configura la política de instalación del plugin `Hello World` (la importación no la aplica por sí sola).
5. Abre un **chat nuevo** y pide: *"Saluda con el plugin Hello World"*.

La sincronización con el repo es diaria; tras un push puedes forzarla con **Sync now**.

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

Prueba con `/hello-world:hello`. Para un equipo, en `.claude/settings.json`:

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

```
Hello World! 👋
Plugin hello-world v0.1.0 ejecutándose desde <Claude Code | ChatGPT | Codex>.
```

## Licencia

MIT.
