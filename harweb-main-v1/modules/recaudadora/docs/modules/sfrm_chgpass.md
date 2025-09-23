# Documentación Técnica: Migración de Formulario Cambio de Clave (sfrm_chgpass)

## 1. Descripción General
Este módulo permite a los usuarios cambiar su clave de acceso de manera segura, replicando la lógica y validaciones del formulario Delphi original, ahora en una arquitectura Laravel + Vue.js + PostgreSQL.

## 2. Arquitectura
- **Frontend**: Componente Vue.js independiente, página completa.
- **Backend**: Laravel Controller con endpoint unificado `/api/execute` (patrón eRequest/eResponse).
- **Base de Datos**: PostgreSQL con stored procedure para el cambio de clave.

## 3. Flujo de Cambio de Clave
1. El usuario ingresa su clave actual.
2. El sistema valida la clave actual vía API.
3. Si es válida, se habilita el campo para la nueva clave.
4. El usuario ingresa la nueva clave y su confirmación.
5. El sistema valida:
   - Que la nueva clave sea diferente a la actual.
   - Que tenga entre 6 y 8 caracteres.
   - Que contenga letras y números.
   - Que los 3 primeros caracteres sean diferentes a la clave actual.
   - Que la confirmación coincida.
6. Si todo es correcto, se actualiza la clave en la base de datos.

## 4. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  - `eRequest`: Nombre de la operación (`chgpass.validate_current`, `chgpass.change_password`)
  - `params`: Parámetros específicos de la operación
- **Respuesta**:
  - `eResponse.success`: true/false
  - `eResponse.message`: Mensaje descriptivo
  - `eResponse.data`: Datos adicionales (si aplica)

## 5. Validaciones
- Clave actual válida (hash verificado)
- Nueva clave:
  - Entre 6 y 8 caracteres
  - Letras y números
  - Diferente a la actual
  - Primeros 3 caracteres diferentes
- Confirmación igual a la nueva clave

## 6. Seguridad
- Las contraseñas se almacenan hasheadas (bcrypt/argon2)
- Todas las validaciones críticas se hacen en backend
- El stored procedure sólo actualiza si el usuario existe

## 7. Stored Procedure
- `sp_chgpass_change_password(p_user_id integer, p_new_password text)`
  - Actualiza la contraseña del usuario
  - Retorna éxito o error

## 8. Integración Vue.js
- Página independiente
- Navegación por pasos (clave actual → nueva → confirmación)
- Mensajes de error y éxito claros
- Llama a la API usando Axios

## 9. Consideraciones
- El `user_id` debe obtenerse del contexto de autenticación (ejemplo: Vuex, JWT, etc.)
- El endpoint `/api/execute` puede ser extendido para otros formularios

## 10. Ejemplo de Request/Response
### Validar clave actual
```json
{
  "eRequest": "chgpass.validate_current",
  "params": {
    "user_id": 1,
    "current_password": "abc123"
  }
}
```

### Cambiar clave
```json
{
  "eRequest": "chgpass.change_password",
  "params": {
    "user_id": 1,
    "current_password": "abc123",
    "new_password": "xyz789",
    "confirm_password": "xyz789"
  }
}
```

## 11. Errores Comunes
- Clave actual incorrecta
- Nueva clave igual a la actual
- Nueva clave no cumple requisitos
- Confirmación no coincide

## 12. Extensibilidad
- El patrón eRequest/eResponse permite agregar más operaciones sin crear nuevos endpoints.
