# Documentación Técnica: Migración Formulario EnergiaModif (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón API:** eRequest/eResponse, todas las operaciones pasan por un solo endpoint.

## Flujo de Trabajo
1. **Frontend** solicita catálogos (`catalogos`), muestra combos.
2. Usuario ingresa datos de búsqueda y ejecuta "Buscar".
3. Frontend envía eRequest con acción `buscar` y datos del local.
4. Backend ejecuta `sp_energia_modif_buscar` y retorna datos de energía.
5. Usuario edita/modifica datos y ejecuta "Modificar".
6. Frontend envía eRequest con acción `modificar` y datos completos.
7. Backend ejecuta `sp_energia_modif_modificar`, que:
   - Valida reglas de negocio.
   - Inserta en historial.
   - Actualiza registro principal.
   - Borra/actualiza/crea adeudos según movimiento.
8. Backend responde con mensaje de éxito o error.

## Endpoint API
- **URL:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "buscar|modificar|catalogos",
      "data": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... }
    }
  }
  ```

## Validaciones Clave
- No se permite modificar si la cantidad es cero o vacía.
- Movimiento y vigencia deben ser coherentes.
- Si es baja, debe capturarse periodo de baja.
- Todas las operaciones de modificación son transaccionales.

## Seguridad
- El usuario debe estar autenticado (no implementado en ejemplo, pero debe usarse Auth en producción).
- Los IDs de usuario se pasan explícitamente.
- Todas las entradas se validan en backend y frontend.

## Stored Procedures
- Toda la lógica de negocio y reglas reside en los SPs de PostgreSQL.
- El controlador Laravel solo orquesta y valida.

## Frontend
- Página Vue.js independiente, sin tabs.
- Navegación y breadcrumbs opcionales.
- Validaciones en tiempo real.
- Mensajes de error y éxito claros.

## Extensibilidad
- Se pueden agregar más acciones al endpoint único.
- Los catálogos se pueden cachear en frontend.

# Estructura de la Base de Datos
- `ta_11_locales`: Locales de mercado.
- `ta_11_energia`: Datos de energía por local.
- `ta_11_energia_hist`: Historial de cambios.
- `ta_11_adeudo_energ`: Adeudos de energía.
- `ta_12_recaudadoras`: Catálogo de recaudadoras.
- `ta_11_secciones`: Catálogo de secciones.

# Seguridad y Transacciones
- Todas las operaciones de modificación usan transacciones.
- Los SPs devuelven mensajes claros de error.

# Pruebas y Auditoría
- El historial de cambios se almacena en `ta_11_energia_hist`.
- Los cambios de adeudos se reflejan automáticamente según reglas.

# Consideraciones
- El frontend debe manejar correctamente los estados de error y éxito.
- El backend debe validar exhaustivamente los datos recibidos.
- Los SPs deben ser revisados y optimizados para concurrencia y performance.
