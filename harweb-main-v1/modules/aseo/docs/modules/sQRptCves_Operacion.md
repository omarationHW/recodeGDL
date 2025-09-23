# Documentación Técnica: Migración de Formulario sQRptCves_Operacion

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `sQRptCves_Operacion` a una arquitectura moderna basada en Laravel (API RESTful), Vue.js (SPA) y PostgreSQL (procedimientos almacenados). El objetivo es listar el catálogo de claves de operación con opciones de clasificación dinámica.

## 2. Arquitectura
- **Backend:** Laravel 10+ (PHP 8+), PostgreSQL 13+
- **Frontend:** Vue.js 3+, Bootstrap 5 (opcional para estilos)
- **API:** Endpoint único `/api/execute` que recibe un objeto `eRequest` y parámetros, y responde con `eResponse`.
- **Base de Datos:** Toda la lógica de consulta reside en procedimientos almacenados PostgreSQL.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "get_operaciones",
    "params": { "opcion": 1 }
  }
  ```
  - `opcion`: 1=ctrol_operacion, 2=cve_operacion, 3=descripcion
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ { "ctrol_operacion": ..., "cve_operacion": ..., "descripcion": ... }, ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedure
- **Nombre:** `sp_get_operaciones`
- **Parámetro:** `opcion` (integer)
- **Retorno:** SETOF json (cada fila como objeto JSON)
- **Lógica:** Ordena según el campo seleccionado.

## 5. Laravel Controller
- **Ruta:** Definir en `routes/api.php`:
  ```php
  Route::post('/execute', [\App\Http\Controllers\Api\ExecuteController::class, 'handle']);
  ```
- **Controlador:** `ExecuteController` maneja el patrón eRequest/eResponse y ejecuta el SP correspondiente.

## 6. Vue.js Component
- **Página independiente** con ruta propia (ej: `/cves-operacion`)
- **Funcionalidad:**
  - Selector de clasificación (Control, Clave, Descripción)
  - Tabla de resultados
  - Breadcrumb de navegación
  - Footer con fecha/hora de impresión
- **Consumo:** Llama a `/api/execute` con el eRequest y muestra los datos.

## 7. Seguridad
- Validar que sólo se acepten eRequests válidos.
- Sanitizar parámetros antes de pasarlos al SP.

## 8. Pruebas
- Pruebas unitarias y de integración para el endpoint y el SP.
- Pruebas de UI para el componente Vue.

## 9. Consideraciones
- El SP devuelve cada fila como JSON para facilitar la integración y desacoplar la lógica de presentación.
- El endpoint es extensible para otros formularios/futuros eRequests.
