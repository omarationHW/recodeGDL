# Documentación Técnica: Dictamen de Uso de Suelo (constancias)

## Arquitectura General
- **Backend:** Laravel (PHP) + PostgreSQL
- **Frontend:** Vue.js SPA (Single Page Application)
- **API:** Único endpoint `/api/execute` con patrón eRequest/eResponse
- **Base de datos:** PostgreSQL, toda la lógica SQL en stored procedures

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "list|search|create|update|cancel|print|listado",
      "data": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "error": "mensaje de error si aplica"
    }
  }
  ```

## Acciones soportadas
- `list`: Listado general de constancias
- `search`: Búsqueda avanzada por filtros
- `create`: Alta de constancia (dictamen)
- `update`: Modificación de constancia
- `cancel`: Cancelación (vigente = 'C')
- `print`: Generación de PDF (devuelve URL/base64)
- `listado`: Listado filtrado para impresión masiva

## Seguridad
- Autenticación por token Laravel (middleware `auth:api` sugerido)
- Validación de datos en el controlador antes de llamar SP
- Los stored procedures validan integridad de datos

## Integración Vue.js
- Cada formulario es una página independiente
- Navegación por rutas (ej: `/dictamenusodesuelo`)
- No se usan tabs, cada formulario es una vista
- El componente consume `/api/execute` para todas las operaciones
- Mensajes de error y éxito se muestran en la UI

## Base de Datos
- Tabla principal: `constancias`
- Tabla de parámetros: `parametros` (para folio)
- Relación con licencias: `id_licencia` (FK)

## Generación de PDF
- El SP `dictamenusodesuelo_print` debe integrarse con un microservicio o proceso batch que genere el PDF y lo almacene en `/storage/constancias/`.
- El frontend abre la URL devuelta en una nueva ventana.

## Validaciones
- No se puede cancelar una constancia ya cancelada
- No se puede imprimir una constancia cancelada
- El folio se incrementa automáticamente en el alta

## Ejemplo de flujo
1. Usuario entra a `/dictamenusodesuelo`
2. Ve listado de constancias
3. Da clic en "Nueva Constancia"
4. Llena formulario y guarda (POST `create`)
5. El backend incrementa folio y guarda
6. Puede imprimir o cancelar desde el listado

## Consideraciones
- El frontend debe manejar loading y errores de red
- El backend debe registrar usuario/capturista
- El SP de impresión puede devolver base64 si no hay microservicio de PDF
