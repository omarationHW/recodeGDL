# Documentación Técnica SGCv2 - Migración Delphi a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente (NO tabs).
- **Base de Datos**: PostgreSQL, toda la lógica de negocio SQL en stored procedures (SPs).
- **Comunicación**: Patrón eRequest/eResponse, todos los requests van a `/api/execute` con `{ eRequest: { action, params } }`.

## Flujo de Datos
1. **Frontend**: El usuario navega a una página (ej. Alta de Licencia), llena el formulario y envía.
2. **Vue.js**: El componente construye un `eRequest` con la acción y los parámetros y lo envía vía POST a `/api/execute`.
3. **Laravel Controller**: Recibe el request, despacha según la acción, llama el SP correspondiente y retorna el resultado como `eResponse`.
4. **PostgreSQL**: Ejecuta el SP, realiza la lógica, retorna el resultado (JSON o tabla).
5. **Frontend**: Recibe el `eResponse` y muestra el resultado.

## Ejemplo de Request/Response
**Request:**
```json
{
  "eRequest": {
    "action": "altaTramiteLicencia",
    "params": {
      "tipo_tramite": 1,
      "id_giro": 123,
      "propietario": "Juan Perez",
      "rfc": "PEJJ800101XXX",
      ...
    }
  }
}
```
**Response:**
```json
{
  "eResponse": {
    "id_tramite": 456,
    "status": "ok"
  }
}
```

## Seguridad
- Autenticación JWT recomendada (no incluida en este ejemplo).
- Validación de parámetros en el frontend y backend.
- Todos los accesos a datos pasan por SPs, no hay SQL directo en el backend.

## Estructura de SPs
- Todos los SPs devuelven JSON o TABLE.
- Los SPs de proceso (alta, baja, bloqueo) devuelven `{ status, id, ... }`.
- Los SPs de consulta devuelven JSON con los datos solicitados.

## Frontend
- Cada formulario es un componente Vue independiente.
- Navegación por rutas (`/licencia/alta`, `/licencia/consulta`, etc.).
- No hay tabs, cada formulario es una página.
- Breadcrumbs opcionales.
- Validación de campos en el frontend.
- Llamadas a `/api/execute` con la acción y parámetros.

## Backend
- Un solo controlador (`SGCv2Controller`) maneja todas las acciones.
- Cada acción llama un SP específico.
- Manejo de errores centralizado.

## Base de Datos
- Todas las operaciones de negocio están en SPs.
- No se permite acceso directo a tablas desde el backend.
- Los SPs pueden recibir parámetros simples o JSON.

## Extensibilidad
- Para agregar una nueva acción, crear el SP y agregar el case en el controlador.
- Para agregar una nueva página, crear el componente Vue y la ruta.

## Ejemplo de Extensión
- Para agregar "Reactivar Licencia":
  - Crear `sp_reactivar_licencia` en PostgreSQL.
  - Agregar método `reactivarLicencia` en el controlador.
  - Crear página Vue `ReactivarLicencia.vue`.

## Pruebas
- Todos los casos de uso y pruebas deben ejecutarse vía `/api/execute`.

## Notas
- El sistema es desacoplado: el frontend no conoce la estructura de la base de datos.
- El backend sólo despacha acciones y valida parámetros.
- La lógica de negocio y reglas están en los SPs.
