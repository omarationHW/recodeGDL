# Documentación Técnica: sfrm_chgpass

## Análisis Técnico

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

## Casos de Prueba

## Casos de Prueba para Cambio de Contraseña

| Caso | Descripción | Datos de Prueba | Resultado Esperado |
|------|-------------|-----------------|-------------------|
| 1 | Cambio exitoso | username: jdoe, current_password: abc123, new_password: xyz789, confirm_password: xyz789 | Clave cambiada exitosamente |
| 2 | Clave nueva igual a actual | username: jdoe, current_password: abc123, new_password: abc123, confirm_password: abc123 | La nueva clave no debe ser igual a la actual |
| 3 | Clave nueva sin números | username: jdoe, current_password: abc123, new_password: abcdef, confirm_password: abcdef | La nueva clave debe contener letras y números, y tener entre 6 y 8 caracteres |
| 4 | Clave nueva sin letras | username: jdoe, current_password: abc123, new_password: 123456, confirm_password: 123456 | La nueva clave debe contener letras y números, y tener entre 6 y 8 caracteres |
| 5 | Clave nueva menos de 6 caracteres | username: jdoe, current_password: abc123, new_password: ab12, confirm_password: ab12 | La nueva clave debe contener letras y números, y tener entre 6 y 8 caracteres |
| 6 | Clave nueva más de 8 caracteres | username: jdoe, current_password: abc123, new_password: abcd12345, confirm_password: abcd12345 | La nueva clave debe contener letras y números, y tener entre 6 y 8 caracteres |
| 7 | Los tres primeros caracteres iguales | username: jdoe, current_password: abc123, new_password: abc456, confirm_password: abc456 | Los tres primeros caracteres deben ser diferentes a la clave actual |
| 8 | Confirmación no coincide | username: jdoe, current_password: abc123, new_password: xyz789, confirm_password: xyz788 | La nueva clave no es igual a la confirmación |
| 9 | Contraseña actual incorrecta | username: jdoe, current_password: wrongpass, new_password: xyz789, confirm_password: xyz789 | La clave actual no es correcta |

## Casos de Uso

# Casos de Uso - sfrm_chgpass

**Categoría:** Form

## Caso de Uso 1: Cambio exitoso de contraseña

**Descripción:** El usuario desea cambiar su contraseña por una nueva válida.

**Precondiciones:**
El usuario está autenticado y conoce su contraseña actual.

**Pasos a seguir:**
1. El usuario accede a la página de cambio de contraseña.
2. Ingresa su contraseña actual, la nueva y la confirmación.
3. Presiona 'Cambiar Clave'.
4. El sistema valida y actualiza la contraseña.

**Resultado esperado:**
La contraseña se actualiza y el usuario recibe el mensaje 'Clave cambiada exitosamente'.

**Datos de prueba:**
{ "username": "jdoe", "current_password": "abc123", "new_password": "xyz789", "confirm_password": "xyz789" }

---

## Caso de Uso 2: Intento de cambio con clave nueva igual a la actual

**Descripción:** El usuario intenta poner la misma clave como nueva.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Ingresa la misma clave en 'actual' y 'nueva'.
2. Presiona 'Cambiar Clave'.

**Resultado esperado:**
El sistema rechaza el cambio y muestra 'La nueva clave no debe ser igual a la actual'.

**Datos de prueba:**
{ "username": "jdoe", "current_password": "abc123", "new_password": "abc123", "confirm_password": "abc123" }

---

## Caso de Uso 3: Intento de cambio con clave nueva inválida (sin números)

**Descripción:** El usuario intenta poner una clave nueva que no cumple las reglas.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Ingresa una clave nueva sólo con letras.
2. Presiona 'Cambiar Clave'.

**Resultado esperado:**
El sistema rechaza el cambio y muestra 'La nueva clave debe contener letras y números, y tener entre 6 y 8 caracteres'.

**Datos de prueba:**
{ "username": "jdoe", "current_password": "abc123", "new_password": "abcdef", "confirm_password": "abcdef" }

---


