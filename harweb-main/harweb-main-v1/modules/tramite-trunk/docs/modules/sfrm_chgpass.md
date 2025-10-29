# Documentación Técnica: Migración de Formulario Cambio de Clave (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo implementa el formulario de cambio de clave de usuario, migrado desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). Toda la lógica de validación y actualización de clave se realiza mediante stored procedures y un endpoint API unificado.

## 2. Arquitectura
- **Frontend**: Componente Vue.js independiente, página completa, sin tabs.
- **Backend**: Laravel Controller con endpoint único `/api/execute` que recibe `eRequest` y `params`.
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.

## 3. Flujo de Cambio de Clave
1. **Usuario ingresa usuario y clave actual** → Validación vía API (`chgpass.validate_current`).
2. **Usuario ingresa nueva clave** → Validación de reglas vía API (`chgpass.validate_new`).
3. **Usuario confirma nueva clave** → Actualización vía API (`chgpass.update`).

## 4. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "eRequest": "chgpass.validate_current|chgpass.validate_new|chgpass.update",
    "params": { ... }
  }
  ```
- **Respuesta**:
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": null
    }
  }
  ```

## 5. Stored Procedures
- **sp_chgpass_validate_current**: Valida si la clave actual es correcta.
- **sp_chgpass_validate_new**: Valida reglas de la nueva clave (longitud, letras/números, diferente a la actual, 3 primeros caracteres distintos).
- **sp_chgpass_update**: Realiza el cambio de clave si todo es válido.

## 6. Seguridad
- Las contraseñas se almacenan usando hash seguro (bcrypt/Blowfish vía `crypt` en PostgreSQL).
- Todas las validaciones se hacen en backend y base de datos.
- No se exponen detalles de errores técnicos al usuario final.

## 7. Frontend (Vue.js)
- Página completa, navegación por pasos (clave actual → nueva → confirmación).
- Mensajes de error y éxito claros.
- Navegación breadcrumb.
- Botón cancelar limpia el formulario.

## 8. Consideraciones
- El usuario debe estar autenticado o proveer su usuario.
- El endpoint es extensible para otros formularios/procesos.
- El frontend puede integrarse en cualquier SPA Vue.js.

## 9. Requisitos de la Tabla `users`
- Debe existir la columna `username` (TEXT, único) y `password_hash` (TEXT).
- El hash debe ser generado con `crypt` y un salt seguro.

---
