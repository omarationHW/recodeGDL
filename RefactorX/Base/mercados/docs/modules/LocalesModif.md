# Documentación Técnica: Migración Formulario LocalesModif (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel (PHP 8+), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (NO tabs)
- **Base de Datos**: PostgreSQL, lógica de negocio crítica en stored procedures
- **Seguridad**: Autenticación Laravel Sanctum/JWT, validación de parámetros en backend

## Flujo de Trabajo
1. **Carga de Catálogos**: Al cargar la página, el frontend solicita catálogos (zonas, cuotas, sectores, movimientos, bloqueos) vía `/api/execute`.
2. **Búsqueda de Local**: El usuario ingresa criterios y envía el formulario. El frontend llama a `/api/execute` con `action: 'buscar_local'` y los parámetros. El backend ejecuta el SP `sp_localesmodif_buscar_local` y retorna los datos del local.
3. **Modificación**: El usuario edita los campos permitidos y envía el formulario. El frontend llama a `/api/execute` con `action: 'modificar_local'` y los datos. El backend ejecuta el SP `sp_localesmodif_modificar_local`, que:
   - Registra el movimiento en `ta_11_movimientos`
   - Actualiza el registro en `ta_11_locales`
   - Si aplica, inserta/actualiza en `ta_11_bloqueo`
   - Si aplica, recalcula adeudos (puede llamar a otro SP)

## API Unificada (eRequest/eResponse)
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "action": "buscar_local|modificar_local|catalogos|movimientos|bloqueos",
    "params": { ... }
  }
  ```
- **Response**:
  ```json
  {
    "success": true|false,
    "message": "...",
    "data": { ... }
  }
  ```

## Validaciones
- Todas las validaciones de negocio y formato se realizan en el backend (Laravel y SPs)
- El frontend realiza validaciones mínimas de requeridos y formato

## Stored Procedures
- Toda la lógica de modificación, movimientos, bloqueos y recalculo de adeudos está en SPs PostgreSQL
- Los SPs devuelven errores mediante excepciones o mensajes en el campo `result`

## Seguridad
- El endpoint requiere autenticación (token)
- El ID de usuario se obtiene del contexto de sesión y se pasa a los SPs

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint
- Los catálogos pueden ser cacheados en frontend

## Despliegue
- El controlador debe estar registrado en `routes/api.php`:
  ```php
  Route::post('/execute', [LocalesModifController::class, 'execute']);
  ```
- El componente Vue debe estar registrado en el router como página independiente

# Notas de Migración
- El formulario Delphi tenía lógica de habilitación/deshabilitación de campos según el tipo de movimiento; esto se implementa en Vue.js con lógica reactiva.
- Los combos de zona, cuota, sector, movimiento y bloqueo se llenan desde catálogos vía API.
- El SP de modificación debe ser atómico y manejar transacciones.
- Los mensajes de error del SP se devuelven al frontend para mostrar al usuario.

# Consideraciones de Pruebas
- Pruebas de concurrencia: dos usuarios modificando el mismo local
- Pruebas de integridad: no permitir movimientos inválidos según reglas de negocio
- Pruebas de seguridad: sólo usuarios autenticados pueden modificar
