# Documentación Técnica: Migración de Formulario Menu (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (API RESTful)
- **Frontend:** Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL 13+ (con stored procedures para lógica de negocio)
- **API Unificada:** Todas las operaciones se realizan a través de un único endpoint `/api/execute` usando el patrón `eRequest`/`eResponse`.

## Flujo de Autenticación y Menú
1. **Login:**
   - El usuario ingresa usuario y contraseña.
   - Se llama a `/api/execute` con operación `login`.
   - El backend valida contra la tabla `ta_12_passwords` usando el SP `sp_menu_login`.
   - Si es correcto, retorna datos de usuario y nivel.

2. **Carga de Menú:**
   - Se llama a `/api/execute` con operación `getMenu` y el usuario.
   - El backend retorna el menú permitido según el nivel del usuario.

3. **Carga de Ejercicios:**
   - Se llama a `/api/execute` con operación `getEjercicios`.
   - El backend retorna los ejercicios disponibles.

4. **Verificación de Versión:**
   - Se llama a `/api/execute` con operación `checkVersion`.
   - El backend indica si hay una nueva versión disponible.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "operation": "string", // Ej: "login", "getMenu", "getEjercicios", "checkVersion"
      "params": { ... } // Parámetros específicos
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": { ... } // Respuesta específica de la operación
  }
  ```

## Stored Procedures
- Toda la lógica de acceso a datos y negocio se implementa en stored procedures de PostgreSQL.
- Los SPs devuelven tablas o JSON según el caso.
- El controlador Laravel llama a los SPs usando `DB::select`.

## Frontend (Vue.js)
- Cada formulario es un componente/página independiente.
- El menú se renderiza dinámicamente según los permisos del usuario.
- El cambio de ejercicio se realiza mediante un `<select>` y se propaga a los formularios hijos.
- El componente principal `MenuPage` maneja la navegación y la carga de formularios.

## Seguridad
- El login debe hacerse siempre por HTTPS.
- El backend nunca retorna la contraseña.
- Los SPs deben validar los parámetros de entrada para evitar SQL Injection.

## Extensibilidad
- Para agregar nuevas opciones de menú, basta con modificar el SP `sp_menu_get_menu` y los componentes Vue correspondientes.
- El endpoint `/api/execute` puede ser extendido para nuevas operaciones sin romper compatibilidad.

## Manejo de Errores
- Todos los errores se retornan en el campo `message` de la respuesta.
- El frontend debe mostrar los mensajes de error al usuario.

## Ejemplo de Llamada API
```json
POST /api/execute
{
  "eRequest": {
    "operation": "login",
    "params": {
      "usuario": "admin",
      "password": "secreto"
    }
  }
}
```

## Ejemplo de Respuesta
```json
{
  "eResponse": {
    "status": "ok",
    "user": {
      "id_usuario": 1,
      "usuario": "admin",
      "nombre": "Administrador",
      "nivel": 5
    }
  }
}
```

## Notas de Migración
- Los permisos y niveles de usuario deben mapearse fielmente desde Delphi.
- Los combos de ejercicios y menús deben ser dinámicos.
- El frontend debe ser responsivo y usable en dispositivos modernos.
