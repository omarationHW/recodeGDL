# Documentación Técnica: Migración de Formulario RptAdeudosPredios (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel API con endpoint unificado `/api/execute` (patrón eRequest/eResponse).
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (NO tabs).
- **Base de Datos**: PostgreSQL, toda la lógica de reportes en stored procedures.

## 2. API Unificada
- **Endpoint**: `POST /api/execute`
- **Request**:
  ```json
  {
    "action": "getAdeudosPredios", // o getAdeudosPrediosSaldoAnt, getSubtipos, etc.
    "params": { ... }
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": [...],
    "message": ""
  }
  ```

## 3. Stored Procedures
- Toda la lógica de consulta de reportes se implementa en funciones/stored procedures de PostgreSQL.
- Ejemplo: `sp_get_adeudos_predios(subtipo, fecha_hasta, estado)`
- Los SP devuelven tablas con los campos requeridos para el frontend.

## 4. Laravel Controller
- Un solo controlador maneja todas las acciones relacionadas con el formulario.
- El método `execute` recibe el nombre de la acción y los parámetros, y despacha la llamada al SP correspondiente.
- El controlador es seguro para uso en API y desacoplado de la UI.

## 5. Vue.js Component
- El componente es una página completa, no usa tabs ni subcomponentes.
- El usuario selecciona subtipo, fecha y estado, y obtiene el reporte en tabla.
- El componente es reactivo y muestra totales en el pie de la tabla.
- El diseño es responsivo y amigable para escritorio.

## 6. Seguridad y Validaciones
- El backend valida los parámetros y retorna errores claros en el campo `message`.
- El frontend valida campos requeridos antes de enviar la petición.

## 7. Extensibilidad
- Para agregar nuevos reportes, basta con crear un nuevo SP y agregar el case correspondiente en el controlador.
- El frontend puede consumir cualquier reporte usando el mismo patrón.

## 8. Consideraciones de Migración
- Los nombres de campos y lógica de negocio se respetan según el código Delphi original.
- Se recomienda revisar los índices y optimizaciones en las tablas para reportes de alto volumen.

## 9. Pruebas
- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad y la migración correcta.

---
