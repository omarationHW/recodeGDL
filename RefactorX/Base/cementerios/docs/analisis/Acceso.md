# Documentación Técnica - Formulario Acceso (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo corresponde al formulario de acceso (login) del sistema de cementerios, migrado desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El acceso se realiza mediante un endpoint unificado `/api/execute` bajo el patrón eRequest/eResponse.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, componente de página independiente para el login.
- **Backend:** Laravel Controller (`AccesoController`) con endpoint `/api/execute`.
- **Base de Datos:** PostgreSQL, lógica de autenticación en stored procedure `sp_acceso_login`.

## 3. Flujo de Autenticación
1. El usuario ingresa usuario y contraseña en el formulario.
2. El frontend envía una petición POST a `/api/execute` con `{ action: 'login', params: { usuario, clave } }`.
3. El backend ejecuta el stored procedure `sp_acceso_login`.
4. Si las credenciales son correctas, retorna los datos del usuario; si no, retorna error.
5. El frontend muestra mensajes de error o redirige al menú principal.

## 4. Endpoint API
- **URL:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "login",
    "params": {
      "usuario": "usuario",
      "clave": "contraseña"
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "message": "Acceso correcto",
    "data": {
      "usuario": "...",
      "id_usuario": 1,
      "nivel": 1,
      "nombre": "..."
    }
  }
  ```

## 5. Stored Procedure
- **Nombre:** `sp_acceso_login`
- **Entradas:** `p_usuario TEXT`, `p_clave TEXT`
- **Salida:** `success BOOLEAN`, `usuario TEXT`, `id_usuario INT`, `nivel INT`, `nombre TEXT`
- **Lógica:** Busca usuario activo con usuario y clave, retorna datos si existe.

## 6. Seguridad
- Las contraseñas deben almacenarse hasheadas en producción (aquí se asume texto plano por compatibilidad).
- El endpoint limita intentos de login en frontend (3 intentos).
- El backend no expone detalles de error de base de datos al usuario final.

## 7. Compatibilidad con Registro de Windows
- El guardado/lectura del usuario en el registro de Windows se simula usando `localStorage` en el frontend web.

## 8. Extensibilidad
- El endpoint `/api/execute` permite agregar nuevas acciones (más formularios) bajo el mismo patrón.

## 9. Consideraciones de Migración
- El formulario Delphi usaba componentes visuales y lógica de eventos; todo esto se traduce a eventos y estados en Vue.js.
- La lógica de conexión y validación de usuario se centraliza en el stored procedure y el controlador Laravel.
- El manejo de intentos y mensajes de error se realiza en el frontend.

## 10. Pruebas
- Ver sección de casos de uso y casos de prueba para escenarios detallados.
