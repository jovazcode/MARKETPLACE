---
name: hello-world
description: Responde con un saludo "Hello World!" que identifica el cliente y la versión del plugin. Úsala cuando el usuario pida probar el plugin hello-world, pida un saludo de prueba o quiera comprobar que el plugin está instalado.
---

# Hello World

Esta skill existe para verificar que el plugin se ha instalado correctamente desde un marketplace.

Cuando se active, responde con exactamente estas dos líneas y nada más:

```
Hello World! 👋
Plugin hello-world v0.1.0 ejecutándose desde <CLIENTE>.
```

Sustituye `<CLIENTE>` por el nombre del asistente o herramienta en la que te estás ejecutando
(por ejemplo `Claude Code`, `ChatGPT` o `Codex`). Si no puedes determinarlo, escribe `un cliente desconocido`.
