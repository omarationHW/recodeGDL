# Documentación: BloqueoLicencia

## Análisis Técnico

# Documentación Técnica: Bloqueo/Desbloqueo de Licencias para Requerir

## Descripción General
Este módulo permite bloquear y desbloquear licencias para requerimientos fiscales, así como consultar el estado, historial y generar reportes de bloqueos/desbloqueos. La migración Delphi → Laravel + Vue.js + PostgreSQL se implementa usando un endpoint API único `/api/execute` con patrón eRequest/eResponse.

## Arquitectura
- **Backend:** Laravel Controller (BloqueoLicenciaController)
- **Frontend:** Vue.js (componente de página independiente)
- **Base de datos:** PostgreSQL (Stored Procedures)
- **API:** Único endpoint `/api/execute`

## Operaciones soportadas
- Buscar licencia y estado de bloqueo
- Bloquear licencia (motivo, fecha, usuario)
- Desbloquear licencia (motivo, fecha, usuario)
- Listar bloqueadas/desbloqueadas por fecha
- Historial de bloqueos/desbloqueos
- Actualizar fecha/motivo de bloqueo
- Reporte de bloqueos/desbloqueos

## Esquema de tablas relevantes
- `licencias (id_licencia, licencia, propietario, ubicacion, ...)`
- `norequeriblelic (id_control, id_licencia, feccap, capturista, fecbaja, user_baja, observacion, tipo_bloq, ... )`

## API: /api/execute
- **Método:** POST
- **Entrada:**
  - `eRequest.operation`: string (ver operaciones)
  - Otros parámetros según operación
- **Salida:**
  - `eResponse.success`: bool
  - `eResponse.message`: string
  - `eResponse.data`: array/obj según operación

## Stored Procedures
- Todas las operaciones SQL se encapsulan en funciones/procedimientos PostgreSQL.
- Se usan funciones para CRUD y reportes, y procedimientos para procesos.

## Seguridad
- El usuario autenticado se obtiene de `$request->user()->username` y se registra en los movimientos.
- Validaciones de datos en backend y frontend.

## Frontend (Vue.js)
- Página independiente, sin tabs.
- Permite buscar, bloquear, desbloquear, ver historial y reportes.
- Navegación y feedback de errores.

## Backend (Laravel)
- Controlador centralizado con switch por operación.
- Llama a los stored procedures según la operación.
- Manejo de errores y validaciones.

## Ejemplo de llamada API
```json
{
  "eRequest": {
    "operation": "block",
    "licencia": 12345,
    "motivo": "Incumplimiento de requisitos",
    "fecha_bloqueo": "2024-06-01"
  }
}
```

## Ejemplo de respuesta
```json
{
  "eResponse": {
    "success": true,
    "message": "",
    "data": [ { "result": "Licencia bloqueada correctamente" } ]
  }
}
```

## Validaciones
- No se puede bloquear una licencia ya bloqueada.
- No se puede desbloquear una licencia no bloqueada.
- Fechas requeridas.
- Motivo requerido.

## Notas
- El historial muestra todos los bloqueos/desbloqueos de la licencia.
- Los reportes pueden filtrarse por fecha y tipo (bloqueadas/desbloqueadas).

## Casos de Uso

> ⚠️ Pendiente de documentar

## Casos de Prueba

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

