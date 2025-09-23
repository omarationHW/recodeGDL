# Documentación Técnica: Migración de Formulario Constancia (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de datos**: PostgreSQL, lógica de negocio en stored procedures.
- **Patrón de integración**: eRequest/eResponse (entrada/salida JSON).

## Flujo de Datos
1. **Frontend** envía una petición POST a `/api/execute` con un objeto `eRequest` que indica la acción (`list`, `create`, `update`, `cancel`, `print`, etc.) y los datos necesarios.
2. **Laravel Controller** recibe la petición, interpreta la acción y llama a los stored procedures correspondientes en PostgreSQL.
3. **Stored Procedures** ejecutan la lógica de negocio y devuelven los datos requeridos.
4. **Laravel Controller** empaqueta la respuesta en un objeto `eResponse` y la retorna al frontend.
5. **Frontend** muestra los datos, formularios, errores o PDFs según corresponda.

## Endpoints
- **POST /api/execute**
  - Entrada: `{ eRequest: { action: '...', data: {...} } }`
  - Salida: `{ eResponse: { success: bool, data: ..., error: ... } }`

## Acciones soportadas
- `list` / `listado`: Listar todas las constancias
- `search`: Buscar constancias por criterios
- `create`: Crear nueva constancia
- `update`: Modificar constancia existente
- `cancel`: Cancelar constancia (cambia estado a 'C')
- `print`: Generar PDF de constancia (retorna URL/base64)

## Validaciones
- Todos los campos requeridos se validan en backend (Laravel) antes de llamar al SP.
- Los stored procedures también validan la integridad de los datos.

## Seguridad
- El endpoint debe estar protegido por autenticación JWT o session según la política de la API.
- El campo `capturista` debe ser validado contra el usuario autenticado.

## Integración con PDF
- El SP `print_constancia` debe integrarse con un generador de PDFs (puede ser una función dummy que retorna una URL, o integración real con un microservicio de PDFs).

## Migración de lógica Delphi
- Todas las operaciones de inserción, edición, cancelación y listado se migran a SPs.
- La lógica de folio se maneja en el SP de creación.
- El frontend Vue.js replica la experiencia de usuario del formulario Delphi, pero como página independiente.

## Consideraciones
- El frontend no usa tabs ni componentes tabulares: cada formulario es una página.
- El backend es desacoplado y puede ser consumido por cualquier cliente.
- El API es unificado y extensible para otros formularios.

# Estructura de la Tabla `constancias`
- axo (integer)
- folio (integer)
- id_licencia (integer, nullable)
- solicita (varchar)
- partidapago (varchar)
- observacion (varchar)
- domicilio (varchar)
- tipo (smallint)
- vigente (varchar, 'V' o 'C')
- feccap (date)
- capturista (varchar)

# Ejemplo de eRequest/eResponse
```json
{
  "eRequest": {
    "action": "create",
    "data": {
      "tipo": 0,
      "solicita": "Juan Perez",
      "partidapago": "12345",
      "observacion": "",
      "domicilio": "Av. Juarez 123",
      "id_licencia": 1001,
      "capturista": "usuario1"
    }
  }
}
```

# Manejo de errores
- Si ocurre un error de validación o SQL, el campo `error` de `eResponse` contendrá el mensaje.

# Pruebas y despliegue
- Los SPs deben ser probados individualmente desde psql o PgAdmin.
- El endpoint `/api/execute` debe ser probado con Postman y desde el frontend.
- El frontend Vue.js debe ser probado en navegadores modernos.

# Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones y formularios sin cambiar la estructura del API.
