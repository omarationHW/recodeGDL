# Documentación Técnica: Trámite de Baja de Anuncio

## Descripción General
Este módulo permite tramitar la baja administrativa de un anuncio publicitario, asegurando que:
- El anuncio esté vigente.
- No existan adeudos pendientes (o se permita baja por error/tiempo según permisos).
- Se registre la baja en la bitácora (tabla lic_cancel).
- Se recalculen los saldos de la licencia asociada.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.

## Flujo de Proceso
1. **Búsqueda de Anuncio:**
   - El usuario ingresa el número de anuncio.
   - El sistema consulta datos del anuncio, saldos y licencia asociada.
2. **Validación:**
   - Si el anuncio no existe o ya está cancelado, se muestra error.
   - Si hay adeudos, se bloquea la baja salvo permisos especiales.
3. **Trámite de Baja:**
   - Se actualiza el estado del anuncio a cancelado.
   - Se cancelan los adeudos pendientes (cvepago=999999).
   - Se recalcula el saldo de la licencia (SP `calc_sdosl`).
   - Se registra la baja en la tabla `lic_cancel` (folios).

## API (Laravel Controller)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "tramitarBaja",
    "params": {
      "anuncio": 12345,
      "motivo": "Motivo de la baja",
      "usuario": "usuario_actual",
      "axo_baja": 2024,
      "folio_baja": 1
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "message": "Baja tramitada correctamente"
  }
  ```

## Frontend (Vue.js)
- Página independiente, sin tabs.
- Permite búsqueda, visualización y trámite de baja.
- Muestra mensajes de error y éxito.

## Seguridad y Permisos
- El backend debe validar que el usuario tenga permisos para tramitar bajas por error o fuera de tiempo.
- Todas las acciones quedan registradas con usuario y fecha.

## Integración con PostgreSQL
- Toda la lógica de negocio crítica (cancelación, recalculo, bitácora) está en stored procedures.
- El backend sólo orquesta y valida.

## Consideraciones
- El endpoint es genérico y puede ser extendido para otros trámites.
- El frontend puede ser adaptado para otros formularios similares.

