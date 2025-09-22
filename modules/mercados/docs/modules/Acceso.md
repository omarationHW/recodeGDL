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
