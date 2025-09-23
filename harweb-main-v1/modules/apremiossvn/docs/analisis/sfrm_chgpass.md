# Documentación Técnica: Cambio de Clave de Usuario

## Descripción General
Este módulo permite a los usuarios cambiar su clave de acceso de manera segura, cumpliendo con las reglas de negocio y validaciones establecidas. La solución está compuesta por:
- Un endpoint API unificado `/api/execute` (patrón eRequest/eResponse)
- Un controlador Laravel (`ChgPassController`)
- Un componente Vue.js de página completa
- Stored Procedures en PostgreSQL para la lógica de validación y cambio de clave

## Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel API, endpoint único `/api/execute` que recibe `{ action, params }` y responde `{ success, message, data }`.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.

## Flujo de Cambio de Clave
1. El usuario accede a la página de cambio de clave.
2. Ingresa clave actual, nueva clave y confirmación.
3. El frontend valida reglas básicas (longitud, letras y números, confirmación).
4. Se envía la petición a `/api/execute` con acción `changePassword` y los parámetros.
5. El backend ejecuta el stored procedure `sp_change_password`.
6. El resultado se muestra al usuario.

## Validaciones de Negocio
- La clave nueva debe tener entre 6 y 8 caracteres.
- Debe contener al menos una letra y un número.
- No puede ser igual a la actual.
- Los 3 primeros caracteres deben ser diferentes a la actual.
- Confirmación debe coincidir.
- No puede estar vacía.

## Seguridad
- Las contraseñas se almacenan con hash bcrypt (`crypt` en PostgreSQL).
- El endpoint requiere autenticación (token JWT o sesión, según la plataforma).
- No se exponen detalles de errores internos.

## API (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "changePassword",
    "params": {
      "user_id": 123,
      "current_password": "actual",
      "new_password": "nueva123",
      "confirm_password": "nueva123"
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "message": "Clave cambiada satisfactoriamente"
  }
  ```

## Integración Vue.js
- El componente es una página completa, sin tabs.
- Incluye validación frontend y mensajes claros.
- Utiliza Vuex o similar para obtener el `user_id` autenticado.

## Integración Laravel
- El controlador recibe la acción y parámetros, y delega a los métodos internos.
- Toda la lógica de negocio crítica está en los stored procedures.

## Integración PostgreSQL
- Los stored procedures encapsulan toda la lógica de validación y actualización.
- Se utiliza `crypt` para comparar y actualizar contraseñas.

## Consideraciones
- El sistema es extensible para otras acciones usando el mismo endpoint.
- El frontend puede adaptarse a cualquier diseño, siempre como página independiente.
