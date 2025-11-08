# Documentación Técnica: Migración Formulario EnergiaMtto (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8.1+), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos**: PostgreSQL 13+, toda la lógica de negocio en stored procedures.
- **Patrón API**: eRequest/eResponse, todas las operaciones pasan por un solo endpoint.

## Flujo de Operación
1. **Carga de Catálogos**: Al cargar la página, el frontend solicita los catálogos de recaudadoras, secciones y tipos de consumo.
2. **Búsqueda de Local**: El usuario ingresa los datos del local y solicita la búsqueda. El backend verifica que el local exista y no tenga energía registrada.
3. **Alta de Energía**: Si el local es válido, el usuario llena los datos de energía y envía el alta. El backend:
   - Inserta en `ta_11_energia`.
   - Inserta en `ta_11_energia_hist`.
   - Genera los adeudos correspondientes en `ta_11_adeudo_energ` desde la fecha de alta hasta la fecha actual.

## Seguridad
- El endpoint `/api/execute` requiere autenticación JWT o session.
- El ID de usuario se obtiene del contexto de autenticación.
- Validaciones de permisos y datos en el backend y en los SP.

## Validaciones
- No se permite alta si el local ya tiene energía registrada.
- La vigencia debe ser 'A' o 'E'.
- La cantidad debe ser mayor a cero.
- El local debe existir y pertenecer a la recaudadora del usuario (si aplica).

## Estructura de la API
- **POST /api/execute**
  - Entrada: `{ eRequest: { action: '...', params: {...} } }`
  - Salida: `{ eResponse: { success: bool, data: ..., message: ... } }`

## Stored Procedures
- Toda la lógica de negocio y validación reside en SPs de PostgreSQL.
- El controlador Laravel solo enruta la petición y retorna la respuesta.

## Frontend
- Cada formulario es una página Vue.js independiente.
- No se usan tabs ni componentes tabulares.
- Navegación por rutas y breadcrumbs.
- Validación de formularios en frontend y backend.

## Manejo de Errores
- Los errores de validación y de base de datos se retornan en el campo `message` de la respuesta.
- El frontend muestra los mensajes de error al usuario.

## Ejemplo de eRequest/eResponse
```json
{
  "eRequest": {
    "action": "alta_energia_mtto",
    "params": {
      "id_local": 123,
      "cve_consumo": "F",
      "descripcion": "Local 12",
      "cantidad": 100.0,
      "vigencia": "A",
      "fecha_alta": "2024-06-01",
      "axo": 2024,
      "numero": "OF-123",
      "user_id": 1,
      "oficina": 1,
      "num_mercado": 34,
      "categoria": 1,
      "seccion": "SS"
    }
  }
}
```

## Ejemplo de respuesta
```json
{
  "eResponse": {
    "success": true,
    "data": [ { "result": "OK" } ],
    "message": ""
  }
}
```

# Tablas Relacionadas
- ta_11_locales
- ta_11_energia
- ta_11_energia_hist
- ta_11_adeudo_energ
- ta_11_mercados
- ta_12_recaudadoras
- ta_11_secciones

# Notas
- El frontend debe obtener el user_id del contexto de autenticación.
- Los SPs pueden ser extendidos para manejo de auditoría y logs.
