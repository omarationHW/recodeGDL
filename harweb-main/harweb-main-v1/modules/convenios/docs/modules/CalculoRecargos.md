# Documentación Técnica: Migración de Formulario CalculoRecargos (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` para todas las operaciones (patrón eRequest/eResponse).
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (no tabs), navegación por rutas.
- **Base de Datos:** PostgreSQL 13+, lógica de negocio crítica en stored procedures.

## Flujo de la Página CalculoRecargos
1. El usuario ingresa el ID del convenio/contrato.
2. El frontend solicita los datos del contrato vía `/api/execute` con acción `getContrato`.
3. El frontend solicita los requerimientos (apremios) asociados vía acción `getRequerimientos`.
4. El frontend calcula las fechas relevantes y solicita el porcentaje de recargos vía acción `getRecargos`.
5. El usuario selecciona si aplica pago inicial y/o parcialidades, y cuántas parcialidades pagará.
6. Al presionar "Calcular Recargos", el frontend envía todos los datos a la acción `calcularRecargos`.
7. El backend ejecuta la lógica de cálculo (idéntica a Delphi) y retorna el importe a pagar, importe de recargos y porcentaje aplicado.

## API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "data": { ... },
    "message": "..."
  }
  ```

## Stored Procedures
- Toda la lógica SQL y de negocio crítica reside en stored procedures de PostgreSQL.
- El backend Laravel invoca los SP mediante DB::select o DB::statement.
- Los SP devuelven datos en formato tabla o valores escalares según corresponda.

## Seguridad
- Validación de parámetros en backend y frontend.
- Manejo de errores y mensajes claros para el usuario.
- El endpoint `/api/execute` puede protegerse con middleware de autenticación si se requiere.

## Vue.js
- El componente es una página completa, no usa tabs.
- Breadcrumb para navegación.
- Manejo reactivo de errores y resultados.
- Lógica desacoplada del backend, solo consume el API.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los SP pueden evolucionar sin afectar el frontend si mantienen la interfaz.

## Pruebas
- Casos de uso y pruebas unitarias cubren los escenarios principales y de error.

# Esquema de Base de Datos (Tablas Relevantes)
- ta_17_convenios (contratos/convenios)
- ta_15_apremios (requerimientos/apremios)
- ta_13_recargosrcm (catálogo de recargos por mes/año)

# Notas de Migración
- El cálculo de recargos replica fielmente la lógica Delphi, incluyendo los límites de porcentaje (100%, 250%).
- El frontend es responsivo y usable en desktop y móvil.
- El API es desacoplado y puede ser consumido por otros sistemas.
