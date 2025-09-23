# Documentación Técnica: Migración Formulario observaTransmfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la gestión de observaciones (bloqueos/desbloqueos) sobre transmisiones patrimoniales. Incluye:
- Listado de observaciones por folio
- Alta, edición, baja (lógica) de observaciones
- Bloqueo/desbloqueo de transmisiones
- Registro de auditoría (usuario, fecha de alta/baja)

## 2. Arquitectura
- **Backend**: Laravel Controller (API REST, endpoint único `/api/execute`)
- **Frontend**: Vue.js SPA (componente de página independiente)
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures
- **API Pattern**: eRequest/eResponse (entrada/salida JSON)

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "list|show|create|update|delete|lock|unlock",
      "params": { ... }
    }
  }
  ```
- **Salida**:
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... }
    }
  }
  ```

## 4. Stored Procedures
- Toda la lógica de inserción, actualización, baja, bloqueo y desbloqueo se realiza vía SPs.
- Los SPs devuelven siempre un registro con id, status y mensaje.

## 5. Seguridad
- El usuario que realiza la acción debe ser enviado en cada petición (`usuario`)
- El backend valida los parámetros y retorna mensajes claros de error

## 6. Frontend (Vue.js)
- Página independiente, sin tabs
- Listado de observaciones por folio
- Formulario para alta/edición
- Acciones de bloquear/desbloquear
- Mensajes de éxito/error
- Navegación breadcrumb

## 7. Backend (Laravel)
- Controlador único con método `execute`
- Cada acción (`list`, `create`, etc.) mapea a un método privado
- Uso de validaciones Laravel
- Llamadas a SPs vía DB::select

## 8. Base de Datos
- Tabla principal: `observa_transm`
  - id SERIAL PRIMARY KEY
  - nocontrol INTEGER
  - cvecuenta INTEGER
  - folio INTEGER
  - observacion TEXT
  - status CHAR(1) -- 'B' (bloqueada), 'D' (desbloqueada)
  - capturista_alta VARCHAR
  - fecha_alta TIMESTAMP
  - capturista_baja VARCHAR
  - fecha_baja TIMESTAMP

## 9. Consideraciones
- El folio 0 se usa para transmisiones no dadas de alta
- El campo `status` indica si la transmisión está bloqueada ('B') o desbloqueada ('D')
- El historial de altas/bajas se conserva

## 10. Pruebas
- Casos de uso y pruebas incluidas al final de este documento
