# Documentación: sfrm_chgpass

## Análisis Técnico

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

## Casos de Uso

# Casos de Uso - sfrm_chgpass

**Categoría:** Form

## Caso de Uso 1: Cambio exitoso de clave

**Descripción:** El usuario ingresa correctamente su clave actual, una nueva clave válida y la confirmación coincide.

**Precondiciones:**
El usuario está autenticado y conoce su clave actual.

**Pasos a seguir:**
1. Ingresa la clave actual.
2. El sistema valida la clave.
3. Ingresa la nueva clave (diferente, válida).
4. Ingresa la confirmación igual a la nueva clave.
5. El sistema actualiza la clave.

**Resultado esperado:**
La clave se cambia exitosamente y el usuario recibe un mensaje de éxito.

**Datos de prueba:**
{ "user_id": 1, "current_password": "abc123", "new_password": "xyz789", "confirm_password": "xyz789" }

---

## Caso de Uso 2: Intento con clave actual incorrecta

**Descripción:** El usuario ingresa una clave actual incorrecta.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Ingresa una clave actual incorrecta.
2. El sistema rechaza la validación.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que la clave actual es incorrecta.

**Datos de prueba:**
{ "user_id": 1, "current_password": "wrongpass" }

---

## Caso de Uso 3: Nueva clave no cumple requisitos

**Descripción:** El usuario intenta poner una nueva clave que no contiene números o letras, o es igual a la actual.

**Precondiciones:**
El usuario está autenticado y la clave actual es válida.

**Pasos a seguir:**
1. Ingresa la clave actual correcta.
2. Ingresa una nueva clave inválida (por ejemplo, sólo letras, o igual a la actual).
3. El sistema rechaza la nueva clave.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando el motivo (debe contener números y letras, o no debe ser igual a la actual).

**Datos de prueba:**
{ "user_id": 1, "current_password": "abc123", "new_password": "abcdef", "confirm_password": "abcdef" }

---

## Casos de Prueba

# Casos de Prueba: Cambio de Clave

| # | Descripción | Datos de Entrada | Resultado Esperado |
|---|-------------|------------------|--------------------|
| 1 | Cambio exitoso | user_id: 1, current_password: 'abc123', new_password: 'xyz789', confirm_password: 'xyz789' | Clave cambiada satisfactoriamente |
| 2 | Clave actual incorrecta | user_id: 1, current_password: 'wrongpass' | Error: La clave actual no es correcta |
| 3 | Nueva clave igual a la actual | user_id: 1, current_password: 'abc123', new_password: 'abc123', confirm_password: 'abc123' | Error: La clave nueva no debe ser igual a la actual |
| 4 | Nueva clave menos de 6 caracteres | user_id: 1, current_password: 'abc123', new_password: 'a1b2', confirm_password: 'a1b2' | Error: La clave debe ser mayor a 5 dígitos |
| 5 | Nueva clave sólo letras | user_id: 1, current_password: 'abc123', new_password: 'abcdef', confirm_password: 'abcdef' | Error: La clave debe contener números y letras |
| 6 | Nueva clave sólo números | user_id: 1, current_password: 'abc123', new_password: '123456', confirm_password: '123456' | Error: La clave debe contener números y letras |
| 7 | Confirmación no coincide | user_id: 1, current_password: 'abc123', new_password: 'xyz789', confirm_password: 'xyz788' | Error: La confirmación de la clave no es igual |
| 8 | Primeros 3 caracteres iguales | user_id: 1, current_password: 'abc123', new_password: 'abc999', confirm_password: 'abc999' | Error: Los tres primeros caracteres deben ser diferentes al actual |

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

