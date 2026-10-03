---
name: hello-world
description: Saluda con "Hello World" en español, inglés, francés o alemán siguiendo archivos de referencia por idioma. Úsala cuando el usuario pida probar el plugin hello-world, pida un saludo ("saluda en francés", "hello world", "di hola") o quiera comprobar que el plugin y sus archivos de referencia están instalados.
---

# Hello World

Esta skill existe para verificar dos cosas: que el plugin se ha instalado desde un marketplace y que los
archivos de referencia que lo acompañan se reconocen y se pueden leer. Por eso el saludo **nunca se
compone de memoria**: siempre sale de un archivo de `references/`.

## 1. Elegir el idioma

Aplica estas reglas en orden y quédate con la primera que se cumpla:

1. Si el usuario nombra un idioma (por ejemplo "saluda en francés", `/hello fr`), usa ese.
2. Si no, usa el idioma en el que está escrito el mensaje del usuario.
3. Si el idioma resultante no está en la tabla, usa `en` y añade al final una cuarta línea:
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

## 3. Responder

Devuelve exactamente las tres líneas que dicta el archivo, en ese orden, sin añadir texto antes ni
después (salvo la cuarta línea de aviso del caso 3). Sustituye `{cliente}` por el nombre del asistente o
herramienta en la que te ejecutas (`Claude Code`, `ChatGPT`, `Codex`…); si no lo sabes, escribe
`un cliente desconocido`.
