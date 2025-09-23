# Documentación Técnica: Formulario de Acceso (Login)

## Descripción General
Este módulo implementa el formulario de acceso (login) del sistema de Convenios/Obra Pública, migrado desde Delphi a Laravel + Vue.js + PostgreSQL. Incluye:
- Un endpoint API unificado `/api/execute` (patrón eRequest/eResponse)
- Un controlador Laravel que centraliza la lógica de autenticación
- Un componente Vue.js como página independiente de login
- Un stored procedure en PostgreSQL para la autenticación

## Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente. El login es la página inicial.
- **Backend:** Laravel API, endpoint único `/api/execute` que recibe eRequest y responde eResponse.
- **Base de Datos:** PostgreSQL, autenticación vía stored procedure `sp_login_usuario`.

## Flujo de Autenticación
1. El usuario ingresa usuario y contraseña en el formulario Vue.js.
2. Al enviar, se realiza un POST a `/api/execute` con:
   ```json
   {
     "eRequest": {
       "action": "login",
       "params": {
         "username": "usuario",
         "password": "contraseña"
       }
     }
   }
   ```
3. El backend ejecuta el stored procedure `sp_login_usuario`.
4. Si es exitoso, responde con los datos del usuario y un token JWT (simulado).
5. El frontend guarda el token y redirige a la página principal.

## Seguridad
- Las contraseñas se almacenan con hash (usar `crypt` en PostgreSQL).
- El token JWT es simulado para el ejemplo, en producción usar Laravel Passport/Sanctum.
- El endpoint `/api/execute` debe protegerse para acciones sensibles.

## Validaciones
- Usuario y contraseña no pueden estar vacíos.
- Se limita a 10 caracteres (como en Delphi original).
- El usuario debe estar activo (`estado = 'A'`).

## Manejo de Sesión
- El frontend guarda el usuario en localStorage para autocompletar en futuros accesos.
- El token se guarda en localStorage y se usa para autenticación en otras rutas.

## Mensajes de Error
- Si usuario/contraseña incorrectos: "Usuario y/o contraseña incorrectos"
- Si campos vacíos: "El Usuario o la Contraseña no pueden estar vacíos"
- Si error de conexión: "Error de conexión con el servidor"

## Extensibilidad
- El endpoint `/api/execute` permite agregar nuevas acciones (alta usuario, recuperación, etc.)
- El stored procedure puede extenderse para auditoría, bloqueo, etc.

## Integración
- El login es la puerta de entrada para todos los módulos del sistema.
- El token se usará para autorizar todas las operaciones posteriores.

# Esquema de Base de Datos (relevante)
Tabla: `ta_12_passwords`
- id_usuario (PK)
- usuario (varchar)
- password (varchar, hash)
- nombre (varchar)
- estado (char)
- id_rec (smallint)
- nivel (smallint)

# API: /api/execute
- Método: POST
- Entrada: `{ eRequest: { action: 'login', params: { username, password } } }`
- Salida: `{ eResponse: { success, data, message } }`

# Stored Procedure: sp_login_usuario
- Entradas: username, password
- Salida: success, datos usuario
- Seguridad: Usar hash y sólo usuarios activos

# Frontend: LoginPage.vue
- Página independiente
- Navegación automática tras login
- Manejo de errores y loading

# Backend: ExecuteController.php
- Centraliza todas las acciones del sistema
- Fácil de extender para otros módulos
