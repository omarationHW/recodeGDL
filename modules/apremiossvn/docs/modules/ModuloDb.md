# Documentación Técnica: Migración ModuloDb Delphi a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la migración del formulario Delphi `ModuloDb` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). Toda la lógica de negocio y validación se traslada a procedimientos almacenados y a un endpoint API unificado.

## 2. Arquitectura
- **Backend:** Laravel 10+ (PHP 8+)
- **Frontend:** Vue.js 2/3 SPA
- **Base de Datos:** PostgreSQL 12+
- **API:** Endpoint único `/api/execute` que recibe `{ eRequest, params }` y responde `{ eResponse }`.

## 3. Endpoints y eRequest soportados
- `getCurrentTime`: Retorna la fecha y hora actual del servidor.
- `getUserByCredentials`: Valida usuario y contraseña, retorna datos del usuario si es válido.
- `checkNewVersion`: Verifica si hay una nueva versión para un proyecto.
- `dateToWords`: Convierte una fecha a letras en español.

## 4. Stored Procedures
- `sp_get_user_by_credentials(p_usuario TEXT, p_clave TEXT)`: Retorna datos del usuario si es válido y activo.
- `sp_check_new_version(p_proyecto TEXT, p_version TEXT)`: Retorna TRUE si hay una nueva versión, FALSE si no.
- `date_to_words(p_date DATE)`: Convierte una fecha a letras en español.

## 5. Controlador Laravel
- `ExecuteController@handle`: Recibe el eRequest y parámetros, ejecuta el SP correspondiente y retorna la respuesta unificada.

## 6. Componente Vue.js
- Página independiente con login, consulta de fecha/hora, conversión de fecha a letras y verificación de versión.
- Cada sección es funcional y no depende de tabs ni de otras páginas.

## 7. Seguridad
- Las contraseñas deben almacenarse hasheadas en producción. Aquí se asume texto plano para compatibilidad con el sistema legado.
- El endpoint `/api/execute` debe protegerse con autenticación y/o rate limiting en producción.

## 8. Consideraciones de Migración
- Los nombres de tablas y campos deben coincidir con los del sistema original.
- Los procedimientos almacenados encapsulan toda la lógica SQL.
- El frontend no accede directamente a la base de datos, solo a través del API.

## 9. Pruebas
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.

## 10. Extensibilidad
- Para agregar nuevas operaciones, basta con crear un nuevo SP y agregar el case correspondiente en el controlador.
