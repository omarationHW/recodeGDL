# Documentación Técnica: Migración de Formulario ConsRemesas (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario "ConsRemesas" de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad original, permitiendo la consulta de remesas y su detalle, con una interfaz moderna y una API unificada.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel API, endpoint único `/api/execute` que recibe `eRequest` y `params`.
- **Base de Datos:** PostgreSQL, lógica SQL encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "getRemesas" | "getRemesaDetalle",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "error": null|string
    }
  }
  ```

## 4. Stored Procedures
- Toda la lógica de consulta se realiza mediante stored procedures:
  - `sp_get_remesas(tipo)`
  - `sp_get_remesa_detalle_edo(remesa)`
  - `sp_get_remesa_detalle_mpio(remesa)`

## 5. Flujo de la Aplicación
1. **Al cargar la página:**
   - Se consulta la lista de remesas del tipo seleccionado (por defecto 'A').
2. **Al cambiar el tipo de consulta:**
   - Se actualiza la lista de remesas según el tipo ('A', 'B', 'C', 'D').
3. **Al hacer doble clic en una remesa:**
   - Se consulta el detalle de la remesa correspondiente, usando el stored procedure adecuado según el tipo.

## 6. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (ej. JWT, Sanctum) en producción.
- Validar siempre los parámetros recibidos.

## 7. Consideraciones de Migración
- Los nombres de tablas y campos deben coincidir con los originales.
- El frontend no usa tabs ni componentes compartidos entre formularios.
- El componente Vue es una página completa, con navegación breadcrumb.

## 8. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.

## 9. Extensibilidad
- Para agregar nuevas operaciones, basta con crear un nuevo stored procedure y mapearlo en el controlador Laravel.

## 10. Dependencias
- Laravel >= 8
- Vue.js >= 2.6 (o 3.x si se adapta el código)
- PostgreSQL >= 12

## 11. Instalación
- Crear las stored procedures en la base de datos destino.
- Registrar la ruta en Laravel:
  ```php
  Route::post('/api/execute', [App\Http\Controllers\Api\ExecuteController::class, 'execute']);
  ```
- Agregar el componente Vue a la SPA y registrar la ruta correspondiente.

## 12. Notas
- El nombre de la base de datos destino es `BasePHP`.
- El código asume que las tablas `ta14_bitacora`, `ta14_datos_edo`, y `ta14_datos_mpio` existen y tienen la estructura esperada.
