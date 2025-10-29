# Documentación Técnica: Migración de Formulario ConsGral (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario "ConsGral" de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El formulario permite consultar información de folios asociados a una placa específica, mostrando resultados provenientes de dos fuentes de datos (principal y secundaria).

## 2. Arquitectura
- **Backend:** Laravel 10+ (API RESTful, endpoint unificado /api/execute)
- **Frontend:** Vue.js 3+ (SPA, componente de página independiente)
- **Base de Datos:** PostgreSQL 13+ (stored procedures para lógica de consulta)

## 3. API Unificada (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "ConsGral.buscarPorPlaca",
    "params": {
      "placa": "ABC1234"
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": {
      "aFolios": [ ... ],
      "bFolios": [ ... ]
    },
    "message": ""
  }
  ```

## 4. Stored Procedures (PostgreSQL)
- **sp14_afolios(parPlaca):** Devuelve folios de la fuente principal y pagos electrónicos asociados a la placa.
- **sp14_bfolios(parPlaca):** Devuelve folios de la fuente secundaria asociados a la placa.

Ambos SP devuelven los campos requeridos por la UI, incluyendo fechas, importes y descripciones.

## 5. Controlador Laravel
- **Clase:** `App\Http\Controllers\Api\ExecuteController`
- **Método:** `execute(Request $request)`
- **Lógica:**
  - Recibe el eRequest y parámetros.
  - Ejecuta los SP correspondientes según el eRequest.
  - Devuelve los resultados en formato eResponse.

## 6. Componente Vue.js
- **Nombre:** `ConsGralPage`
- **Características:**
  - Página independiente con ruta propia.
  - Formulario para ingresar la placa (input text, uppercase, maxlength 9).
  - Botón Buscar (llama a la API).
  - Botón Salir (regresa a inicio).
  - Tabla de resultados unificada (aFolios + bFolios).
  - Manejo de errores y loading.

## 7. Seguridad
- Validación de parámetros en backend.
- Sanitización de entrada.
- Uso de parámetros en SP para evitar SQL Injection.

## 8. Consideraciones de Migración
- Los SP reproducen la lógica SQL original de Delphi.
- Los campos y tipos de datos se adaptan a PostgreSQL.
- El frontend no usa tabs ni componentes compartidos: cada formulario es una página.
- El endpoint es único y extensible para otros formularios.

## 9. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.

## 10. Extensibilidad
- Para agregar nuevos formularios, basta con definir nuevos eRequest y SP asociados.
- El frontend puede agregar nuevas páginas independientes siguiendo el mismo patrón.
