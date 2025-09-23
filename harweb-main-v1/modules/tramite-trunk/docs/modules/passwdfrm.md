# Documentación Técnica: Migración Formulario passwdfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario `passwdfrm` es utilizado para solicitar autorización de usuario para operaciones sensibles (por ejemplo, cambios de propietario, valores, etc). El usuario debe ingresar su nombre de usuario y contraseña. El sistema valida que la contraseña sea correcta y que el usuario esté autorizado (clave inicia con `&T`).

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute`.
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica de validación en stored procedures.
- **API:** Patrón eRequest/eResponse.

## 3. Flujo de Autenticación
1. El usuario ingresa usuario y contraseña en el formulario.
2. El frontend envía la petición a `/api/execute` con `{ eRequest: { action: 'login', params: { usuario, password } } }`.
3. El backend ejecuta el stored procedure `sp_passwdfrm_login`.
4. El resultado se retorna en `eResponse` con los campos `success`, `message`, `usuario`, `autorizado`.

## 4. Detalles Técnicos
### 4.1. Laravel Controller
- Controlador: `PasswdFrmController`
- Método principal: `execute(Request $request)`
- Acciones soportadas:
  - `login`: Valida usuario y contraseña.
  - `getUser`: Obtiene datos del usuario para autocompletar.
  - `reset`: (placeholder, no implementado)
- Todas las respuestas siguen el patrón `{ eResponse: { ... } }`.

### 4.2. Vue.js Component
- Página independiente, sin tabs.
- Campos: Usuario, Password.
- Botones: Aceptar, Cancelar.
- Mensajes de error y éxito.
- Emite eventos `autorizado` y `cancelar` para integración.

### 4.3. Stored Procedures
- `sp_passwdfrm_login`: Valida usuario y contraseña, verifica autorización.
- `sp_passwdfrm_get_user`: Devuelve datos básicos del usuario.

### 4.4. Seguridad
- Las contraseñas se comparan en texto plano (igual que el sistema original). Se recomienda migrar a hash en el futuro.
- El endpoint `/api/execute` debe estar protegido por autenticación de sesión o token.

### 4.5. Integración
- El formulario puede ser llamado como modal o página completa desde cualquier parte del sistema que requiera autorización.
- El evento `autorizado` puede ser usado para continuar el flujo de la operación protegida.

## 5. Ejemplo de Petición y Respuesta
### Petición
```json
{
  "eRequest": {
    "action": "login",
    "params": {
      "usuario": "admin",
      "password": "&T123456"
    }
  }
}
```

### Respuesta Exitosa
```json
{
  "eResponse": {
    "success": true,
    "message": "Autorización concedida",
    "usuario": "admin",
    "autorizado": true
  }
}
```

### Respuesta Fallida
```json
{
  "eResponse": {
    "success": false,
    "message": "Password incorrecto",
    "usuario": "admin",
    "autorizado": false
  }
}
```

## 6. Consideraciones de Migración
- El formulario Delphi usaba componentes visuales y lógica embebida; ahora la lógica está centralizada en el backend y la UI es web.
- El acceso a la base de datos se realiza únicamente a través de stored procedures.
- El endpoint es único y extensible para otras acciones.

## 7. Seguridad y Buenas Prácticas
- Se recomienda migrar el almacenamiento de contraseñas a hash seguro.
- Limitar intentos de login para evitar ataques de fuerza bruta.
- Auditar los accesos y autorizaciones.
