# Documentación Técnica: Migración DsDBGasto Delphi a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `DsDBGasto` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El objetivo es replicar la lógica de conexión y autenticación de dos bases de datos (seguridad y estación) usando un endpoint API unificado y procedimientos almacenados.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 2/3, página independiente para el formulario de conexión.
- **Base de Datos:** PostgreSQL, procedimientos almacenados para lógica de autenticación y conexión.

## 3. Flujo de Trabajo
1. El usuario ingresa usuario y contraseña de seguridad.
2. El frontend llama a `/api/execute` con `eRequest: 'login_seguridad'`.
3. Si es exitoso, el frontend llama a `/api/execute` con `eRequest: 'connect_estacion'` (credenciales fijas).
4. Si ambos pasos son exitosos, se muestra éxito.

## 4. Endpoint API Unificado
- **Ruta:** `/api/execute`
- **Método:** POST
- **Entrada:**
  - `eRequest`: string (ej: 'login_seguridad', 'connect_estacion')
  - `params`: objeto con parámetros requeridos
- **Salida:**
  - `eResponse`: objeto con `success`, `data`, `error`

## 5. Stored Procedures
- `sp_login_seguridad(user, pass)`: Verifica credenciales en la tabla `seguridad_usuarios`.
- `sp_connect_estacion()`: Verifica credenciales fijas en la tabla `estacion_usuarios`.

## 6. Seguridad
- Las contraseñas deben almacenarse hasheadas en producción.
- El endpoint no expone detalles de error sensibles.

## 7. Frontend
- Página Vue.js independiente.
- No usa tabs ni componentes compartidos.
- Navegación breadcrumb incluida.
- Mensajes claros de éxito/error.

## 8. Consideraciones
- Las tablas `seguridad_usuarios` y `estacion_usuarios` deben existir y contener los usuarios requeridos.
- El endpoint puede extenderse para otros formularios usando el patrón `eRequest`.

## 9. Extensibilidad
- Para agregar nuevos formularios, crear nuevos stored procedures y manejar nuevos valores de `eRequest` en el controlador.
