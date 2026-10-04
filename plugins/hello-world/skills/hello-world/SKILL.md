---
name: hello-world
description: Saluda al usuario por su nombre (obtenido de la tool getUserName del MCP Server del plugin) con "Hello World" en español, inglés, francés o alemán siguiendo archivos de referencia por idioma. Úsala cuando el usuario pida probar el plugin hello-world, pida un saludo ("saluda en francés", "hello world", "di hola") o quiera comprobar que el plugin, sus archivos de referencia y su MCP Server están instalados.
---

# Hello World

Esta skill existe para verificar tres cosas: que el plugin se ha instalado desde un marketplace, que los
archivos de referencia que lo acompañan se reconocen y se pueden leer, y que el MCP Server que declara
el plugin está conectado. Por eso el saludo **nunca se compone de memoria**: el texto siempre sale de un
archivo de `references/` y el nombre siempre sale de la tool `getUserName`.

## 1. Elegir el idioma

Aplica estas reglas en orden y quédate con la primera que se cumpla:

1. Si el usuario nombra un idioma (por ejemplo "saluda en francés", `/hello fr`), usa ese.
2. Si no, usa el idioma en el que está escrito el mensaje del usuario.
3. Si el idioma resultante no está en la tabla, usa `en` y añade al final una línea de aviso:
   `(No hay referencia para <idioma>; se ha usado en.md.)`

| Idioma   | Código | Archivo                |
|----------|--------|------------------------|
| Español  | `es`   | [references/es.md](references/es.md) |
| English  | `en`   | [references/en.md](references/en.md) |
| Français | `fr`   | [references/fr.md](references/fr.md) |
| Deutsch  | `de`   | [references/de.md](references/de.md) |

## 2. Leer el archivo de referencia

Abre `references/<código>.md` (ruta relativa a esta carpeta de la skill). Contiene tres bloques —
saludo, estado y firma — y unas reglas de estilo. La firma (emoji + `[ref:xx-01]`) es arbitraria a
propósito: solo puede obtenerse leyendo el archivo.

Si no puedes leer el archivo, responde únicamente con:

```
No he podido leer references/<código>.md
```

## 3. Obtener el nombre del usuario

Llama a la tool `getUserName` del MCP Server `auth` que declara este plugin. No recibe argumentos y
devuelve el nombre como texto. Según el cliente, la tool puede aparecer con un prefijo; en Claude Code
es `mcp__plugin_hello-world_auth__getUserName`.

El nombre **solo** puede salir de esa llamada: no lo deduzcas de la conversación, del sistema, de la
memoria ni del correo del usuario. Si la tool no existe, no está conectada o devuelve un error, usa el
saludo sin nombre del archivo y añade al final la línea de aviso:
`(getUserName no disponible; saludo anónimo.)`

## 4. Responder

Devuelve exactamente las tres líneas que dicta el archivo, en ese orden, sin añadir texto antes ni
después (salvo las líneas de aviso de los pasos 1 y 3). Sustituye `{usuario}` por el nombre que ha
devuelto `getUserName`, y `{cliente}` por el nombre del asistente o herramienta en la que te ejecutas
(`Claude Code`, `ChatGPT`, `Codex`…); si no lo sabes, escribe `un cliente desconocido`.
