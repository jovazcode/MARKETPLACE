import 'dart:io';

import 'package:mcp_dart/mcp_dart.dart';

/// Dominio público desde el que Apache hace proxy hacia este servidor.
const publicHost = 'io.loanoor.com';

/// Sin autenticación el servidor no sabe quién llama: en esta alpha el nombre
/// es el configurado en MCP_USER_NAME o, en su defecto, el usuario del SO.
String userName() {
  final env = Platform.environment;
  return env['MCP_USER_NAME'] ?? env['USERNAME'] ?? env['USER'] ?? 'desconocido';
}

McpServer buildServer() {
  final server = McpServer(
    const Implementation(name: 'auth', version: '1.0.0-alpha'),
    options: const McpServerOptions(protocol: McpProtocol.stable),
  );

  server.registerTool(
    'getUserName',
    title: 'Get user name',
    description: 'Devuelve el nombre del usuario al que hay que saludar.',
    inputSchema: JsonSchema.object(properties: {}),
    annotations: const ToolAnnotations(
      readOnlyHint: true,
      destructiveHint: false,
      idempotentHint: true,
      openWorldHint: false,
    ),
    callback: (args, extra) async {
      final name = userName();
      stdout.writeln('${DateTime.now().toIso8601String()} getUserName -> $name');
      return CallToolResult.fromContent([TextContent(text: name)]);
    },
  );

  return server;
}

Future<void> main() async {
  final env = Platform.environment;
  final host = env['HOST'] ?? '127.0.0.1';
  final port = int.tryParse(env['PORT'] ?? '') ?? 3000;

  final server = StreamableMcpServer(
    serverFactory: (_) => buildServer(),
    host: host,
    port: port,
    path: '/mcp',
    // La protección DNS-rebinding rechaza con 403 cualquier Host que no esté
    // aquí. Apache puede reenviar el Host interno o el público.
    allowedHosts: {
      'localhost',
      '127.0.0.1',
      host,
      '$host:$port',
      publicHost,
    },
  );

  await server.start();
  stdout.writeln('MCP auth escuchando en http://$host:$port/mcp');
}
