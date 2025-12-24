# Acceso

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Módulo de Acceso (Login)

## Descripción General
Este módulo implementa el formulario de acceso (login) del sistema migrado desde Delphi a Laravel + Vue.js + PostgreSQL. El acceso se realiza mediante un endpoint unificado `/api/execute` que recibe acciones (eRequest) y responde con un objeto estructurado (eResponse). El frontend es un componente Vue.js de página completa.

## Arquitectura
- **Backend:** Laravel Controller (`AccesoController`) expone el endpoint `/api/execute`.
- **Frontend:** Componente Vue.js (`AccesoPage`) como página independiente.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.
- **API:** Patrón eRequest/eResponse, endpoint único.

## Flujo de Autenticación
1. El usuario ingresa usuario, contraseña y ejercicio.
2. El frontend envía un POST a `/api/execute` con `{ action: 'login', params: { ... } }`.
3. El backend ejecuta el stored procedure `sp_acceso_login`.
4. Si es correcto, retorna datos de usuario y guarda en sesión.
5. Si falla, retorna mensaje de error.
6. El frontend maneja intentos y muestra mensajes.

## Validaciones
- Usuario y contraseña no pueden estar vacíos.
- Ejercicio debe estar en el rango permitido.
- Se bloquea el acceso tras 3 intentos fallidos.

## Seguridad
- Las contraseñas deben estar hasheadas en producción (aquí se asume texto plano por compatibilidad con el sistema legado).
- El endpoint no expone detalles de error.
- Se recomienda usar HTTPS.

## Stored Procedures
- `sp_acceso_login`: Valida usuario y contraseña.
- `sp_acceso_ejercicio_minmax`: Devuelve el rango de ejercicios válidos.

## API (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "login",
    "params": {
      "usuario": "...",
      "contrasena": "...",
      "ejercicio": 2024
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "data": { ... },
    "message": "Acceso correcto"
  }
  ```

## Frontend
- Página Vue.js independiente.
- No usa tabs ni componentes compartidos.
- Incluye validación, mensajes de error y control de intentos.
- Guarda usuario en localStorage para autocompletar.

## Extensibilidad
- El endpoint `/api/execute` permite agregar nuevas acciones fácilmente.
- Los stored procedures pueden ampliarse para más lógica de negocio.

## Consideraciones de Migración
- El control de intentos y mensajes se replica del Delphi original.
- El ejercicio por defecto es el año actual, pero puede ser parametrizable.
- El frontend es responsivo y usable en dispositivos modernos.

## Seguridad Adicional
- Se recomienda implementar throttling y logging de intentos fallidos.
- En producción, usar autenticación JWT o Laravel Sanctum para sesiones.


## Casos de Uso

# Casos de Uso - Acceso

**Categoría:** Form

## Caso de Uso 1: Acceso exitoso al sistema

**Descripción:** Un usuario válido ingresa sus credenciales y accede correctamente al sistema.

**Precondiciones:**
El usuario existe en la tabla ta_12_passwords, está activo y conoce su contraseña.

**Pasos a seguir:**
1. El usuario abre la página de acceso.
2. Ingresa usuario, contraseña y ejercicio.
3. Presiona 'Aceptar'.
4. El sistema valida y permite el acceso.

**Resultado esperado:**
El usuario es autenticado y redirigido al menú principal.

**Datos de prueba:**
{ "usuario": "admin", "contrasena": "1234", "ejercicio": 2024 }

---

## Caso de Uso 2: Acceso fallido por contraseña incorrecta

**Descripción:** Un usuario ingresa una contraseña incorrecta y el sistema rechaza el acceso.

**Precondiciones:**
El usuario existe pero la contraseña es incorrecta.

**Pasos a seguir:**
1. El usuario abre la página de acceso.
2. Ingresa usuario válido y contraseña incorrecta.
3. Presiona 'Aceptar'.

**Resultado esperado:**
El sistema muestra un mensaje de error y no permite el acceso.

**Datos de prueba:**
{ "usuario": "admin", "contrasena": "erronea", "ejercicio": 2024 }

---

## Caso de Uso 3: Bloqueo tras 3 intentos fallidos

**Descripción:** Un usuario intenta acceder 3 veces con datos incorrectos y el sistema bloquea el acceso.

**Precondiciones:**
El usuario no conoce la contraseña.

**Pasos a seguir:**
1. El usuario intenta acceder 3 veces con datos incorrectos.
2. En cada intento, el sistema muestra error.
3. Tras el tercer intento, el sistema bloquea el acceso.

**Resultado esperado:**
El sistema muestra un mensaje de bloqueo y no permite más intentos.

**Datos de prueba:**
{ "usuario": "admin", "contrasena": "erronea", "ejercicio": 2024 } (repetir 3 veces)

---



## Casos de Prueba

# Casos de Prueba: Acceso

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|-------------------|
| 1 | Acceso exitoso | usuario: admin, contrasena: 1234, ejercicio: 2024 | success: true, datos de usuario |
| 2 | Contraseña incorrecta | usuario: admin, contrasena: erronea, ejercicio: 2024 | success: false, mensaje de error |
| 3 | Usuario vacío | usuario: '', contrasena: 1234, ejercicio: 2024 | success: false, error de validación |
| 4 | Ejercicio fuera de rango | usuario: admin, contrasena: 1234, ejercicio: 1999 | success: false, error de validación |
| 5 | 3 intentos fallidos | usuario: admin, contrasena: erronea, ejercicio: 2024 (x3) | Bloqueo de acceso, mensaje de bloqueo |
| 6 | Logout | acción: logout | success: true, sesión cerrada |



