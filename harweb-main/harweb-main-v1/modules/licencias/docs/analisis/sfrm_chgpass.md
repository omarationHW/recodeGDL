# Documentación Técnica: Cambio de Contraseña (sfrm_chgpass)

## Descripción General
Este módulo permite a los usuarios cambiar su contraseña de acceso al sistema. La migración Delphi → Laravel + Vue.js + PostgreSQL implementa la lógica de validación y actualización de contraseña, asegurando reglas de seguridad y auditabilidad.

## Arquitectura
- **Frontend:** Componente Vue.js independiente (página completa)
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Base de Datos:** PostgreSQL con stored procedures para validación y cambio de contraseña

## Flujo de Proceso
1. El usuario ingresa su contraseña actual, la nueva y la confirmación.
2. El frontend valida reglas básicas (longitud, coincidencia, etc).
3. Se envía un eRequest a `/api/execute` con la acción `changePassword`.
4. El backend ejecuta validaciones adicionales y llama al SP `sp_change_user_password`.
5. El SP valida la contraseña actual, reglas de negocio y actualiza la contraseña si es válido.
6. El resultado se retorna en eResponse y se muestra al usuario.

## Reglas de Negocio
- La nueva clave debe tener entre 6 y 8 caracteres.
- Debe contener al menos una letra y un número.
- No puede ser igual a la actual.
- Los tres primeros caracteres deben ser diferentes a la clave actual.
- No puede ser sólo letras ni sólo números.
- La confirmación debe coincidir con la nueva clave.

## Seguridad
- Las contraseñas se almacenan con hash seguro (bcrypt/crypt).
- El SP y el endpoint requieren autenticación previa (middleware Laravel).
- Todas las operaciones quedan auditadas en la tabla de usuarios (puede ampliarse con bitácora).

## API (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "changePassword",
      "username": "usuario",
      "current_password": "actual",
      "new_password": "nueva",
      "confirm_password": "nueva"
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "message": "Clave cambiada exitosamente",
    "data": null
  }
  ```

## Integración Vue.js
- El componente es una página completa, sin tabs.
- El usuario debe estar autenticado (se obtiene el username del contexto).
- El formulario es reactivo y muestra mensajes de error o éxito.

## Integración Laravel
- El controlador centraliza la lógica y delega a los SP de PostgreSQL.
- Todas las validaciones de negocio se hacen tanto en frontend como backend.

## Integración PostgreSQL
- Se usan funciones seguras para comparar y actualizar hashes de contraseña.
- Se pueden ampliar los SP para bitácora/auditoría si se requiere.

## Seguridad y Buenas Prácticas
- No se exponen mensajes técnicos al usuario final.
- No se retorna nunca la contraseña ni su hash.
- El endpoint debe estar protegido por autenticación JWT/session.

## Extensibilidad
- Se pueden agregar triggers para bitácora de cambios de contraseña.
- Se puede parametrizar la longitud mínima/máxima y reglas de complejidad.
