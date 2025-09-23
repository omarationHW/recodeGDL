# Documentación Técnica: Catálogo de Tipos de Aseo (ABC_Tipos_Aseo)

## 1. Descripción General
Este módulo permite la administración del catálogo de Tipos de Aseo, incluyendo altas, bajas, cambios y consulta. La funcionalidad está migrada de Delphi a Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos y lógica de negocio).

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "tipos_aseo.create|update|delete|list|get",
      "params": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": [ ... ]
    }
  }
  ```

## 4. Stored Procedures
- Toda la lógica de negocio (validaciones, reglas de negocio, restricciones) está en stored procedures de PostgreSQL.
- Los procedimientos devuelven un registro con `success` y `msg`.

## 5. Seguridad
- El usuario debe autenticarse (no incluido en este ejemplo, pero el campo `usuario` debe ser llenado correctamente).
- Validaciones de unicidad y restricciones de integridad se hacen en los SP.

## 6. Frontend
- Página independiente para Tipos de Aseo.
- Tabla con selección de fila.
- Botones para Alta, Edición, Baja, Refrescar.
- Modal para formulario de alta/edición/baja.
- Mensajes de éxito/error.

## 7. Backend
- Controlador Laravel único (`ExecuteController`) que enruta la acción a los SP correspondientes.
- Todas las acciones usan el endpoint `/api/execute`.

## 8. Base de Datos
- Tabla principal: `ta_16_tipo_aseo`
- Tabla de referencia: `ta_16_ctas_aplicacion` (para validar cta_aplicacion)
- Restricción: No se puede borrar un tipo de aseo si tiene contratos asociados.

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los SP pueden ser versionados y auditados.

## 10. Pruebas
- Casos de uso y pruebas incluidas para asegurar la funcionalidad.

---
