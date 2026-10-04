# MCP Server `auth` (v1-alpha)

Servidor MCP en Dart ([mcp_dart](https://pub.dev/packages/mcp_dart)) por Streamable HTTP y **sin
autenticación**. Expone una tool, `getUserName`, que usa el plugin `hello-world` para saludar por nombre.

Como no hay autenticación, el servidor no sabe quién llama: devuelve `MCP_USER_NAME` o, si no está
definida, el usuario del sistema operativo donde corre.

## Arrancar

```powershell
dart pub get
$env:HOST = '100.113.239.95'   # IP de Tailscale del desktop; sin HOST escucha en 127.0.0.1
dart run bin/server.dart
```

Variables: `HOST` (por defecto `127.0.0.1`), `PORT` (`3000`), `MCP_USER_NAME`.

El servidor solo acepta peticiones cuyo `Host` sea loopback, `HOST` o `io.loanoor.com` (protección
DNS-rebinding de `mcp_dart`); cualquier otro recibe 403. Si cambia el dominio público, hay que cambiar
`publicHost` en [bin/server.dart](bin/server.dart).

## Publicar en `https://io.loanoor.com/mcp`

El desktop y la VPS comparten red Tailscale, así que Apache hace proxy directo a la IP de Tailscale.

Desktop, una vez, PowerShell como administrador (deja entrar solo a la VPS):

```powershell
New-NetFirewallRule -DisplayName "MCP auth (Tailscale)" -Direction Inbound -Protocol TCP -LocalPort 3000 -RemoteAddress 100.119.32.82 -Action Allow
```

VPS, una vez: `sudo a2enmod proxy proxy_http headers` y en el vhost HTTPS de `io.loanoor.com`:

```apache
<Location /mcp>
    ProxyPass        http://100.113.239.95:3000/mcp flushpackets=on timeout=3600
    ProxyPassReverse http://100.113.239.95:3000/mcp
    SetEnv no-gzip 1
</Location>
```

`sudo apachectl configtest && sudo systemctl reload apache2`

## Probar

```bash
curl -i -X POST https://io.loanoor.com/mcp \
  -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"curl","version":"0"}}}'
```

- `200` con `"serverInfo":{"name":"auth",…}`: funciona de extremo a extremo.
- `403`: el `Host` que llega no está en `allowedHosts`.
- `503`: Apache no alcanza el desktop (servidor parado, firewall o Tailscale).

Cada llamada a la tool deja una línea `getUserName -> <nombre>` en la consola del servidor.
