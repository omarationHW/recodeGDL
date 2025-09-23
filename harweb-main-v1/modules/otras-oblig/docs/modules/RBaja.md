# Documentación Técnica: Migración Formulario RBaja (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite dar de baja (cancelar) un local/concesión, asegurando que no existan adeudos vigentes o posteriores. El proceso incluye:
- Búsqueda del local por número y letra.
- Visualización de datos del local.
- Verificación de adeudos pasados y posteriores.
- Ejecución de la baja mediante stored procedure.

## 2. Arquitectura
- **Frontend:** Vue.js (Single Page Component, página independiente)
- **Backend:** Laravel Controller (API REST, endpoint único `/api/execute`)
- **Base de Datos:** PostgreSQL (Stored Procedures)
- **Comunicación:** Patrón eRequest/eResponse (JSON)

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "rbaja.buscar_local", // o rbaja.verificar_adeudos, rbaja.cancelar_local, etc.
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## 4. Stored Procedures
- **sp_rbaja_buscar_local:** Busca local por número/letra.
- **sp_rbaja_verificar_adeudos:** Verifica adeudos pasados.
- **sp_rbaja_verificar_adeudos_post:** Verifica adeudos posteriores.
- **sp_rbaja_cancelar_local:** Realiza la baja/cancelación.

## 5. Flujo de la Página (Vue.js)
1. Usuario ingresa número y letra del local y presiona "Buscar".
2. Se consulta `/api/execute` con acción `rbaja.buscar_local`.
3. Si existe, se muestran los datos del local.
4. Usuario ingresa año y mes de baja y presiona "Aplicar Baja".
5. Se consulta `/api/execute` con acciones `rbaja.verificar_adeudos` y `rbaja.verificar_adeudos_post`.
6. Si no hay adeudos, se ejecuta `/api/execute` con acción `rbaja.cancelar_local`.
7. Se muestra mensaje de éxito o error.

## 6. Validaciones
- Número de local obligatorio y numérico (máx 3 dígitos).
- Año obligatorio y numérico (4 dígitos).
- No permitir baja si existen adeudos vigentes o posteriores.

## 7. Seguridad
- Todas las acciones deben estar autenticadas (middleware Laravel, no incluido aquí).
- Validar parámetros en backend.

## 8. Consideraciones
- El endpoint es único y recibe la acción a ejecutar.
- Los stored procedures encapsulan la lógica de negocio y validación.
- El frontend es una página independiente, sin tabs.

## 9. Extensibilidad
- Se pueden agregar nuevas acciones en el controlador y nuevos stored procedures siguiendo el mismo patrón.

