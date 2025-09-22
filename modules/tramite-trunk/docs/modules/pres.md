# Documentación Técnica: Migración Formulario Prescripción (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, lógica de negocio crítica en stored procedures.
- **Patrón API:** eRequest/eResponse, todos los métodos usan el mismo endpoint.

## 2. API Backend
- **Controlador:** `PrescripcionController`
- **Ruta:** POST `/api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "search|save|list|update|delete",
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
- **Acciones soportadas:**
  - `search`: Buscar saldos a prescribir
  - `save`: Registrar prescripción y actualizar saldos
  - `list`: Listar prescripciones de una cuenta
  - `update`/`delete`: No implementado (placeholder)

## 3. Lógica de Negocio
- **Búsqueda:**
  - Consulta la tabla `detsaldos` para obtener los saldos a prescribir según rango de años/bimestres y cuenta.
- **Prescripción:**
  - Inserta registro en `prescripcion`.
  - Actualiza los registros de `detsaldos` afectados (marca como prescrito, pone exento='P', etc).
  - Llama al stored procedure `calc_sdos` para recalcular los saldos globales.
  - Actualiza la tabla `catastro` con el movimiento correspondiente (53 o 12).
  - Si el movimiento es 12, inserta registro en `abstencion`.

## 4. Frontend Vue.js
- **Página independiente:** `/prescripcion`
- **Flujo:**
  1. Usuario ingresa cuenta, año/bimestre inicial y final.
  2. Hace clic en "Buscar" → muestra tabla de saldos a prescribir.
  3. Ingresa observaciones y usuario, hace clic en "Prescribir".
  4. Muestra mensaje de éxito/error.
- **Validaciones:**
  - Todos los campos requeridos deben estar completos.
  - El usuario debe estar autenticado (en producción, usar JWT o similar).

## 5. Stored Procedures
- Toda la lógica de recálculo de saldos debe estar en el SP `calc_sdos`.
- El SP debe ser idempotente y seguro para concurrencia.

## 6. Seguridad
- El endpoint debe validar autenticación (no incluido aquí por simplicidad).
- Validar que el usuario tenga permisos para prescribir.

## 7. Pruebas
- Usar los casos de uso y pruebas proporcionados para validar la migración.

## 8. Consideraciones
- El endpoint es genérico y puede ser extendido para otros formularios.
- El frontend puede ser adaptado fácilmente a otros módulos siguiendo el mismo patrón.
