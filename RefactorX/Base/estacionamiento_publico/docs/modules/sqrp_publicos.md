# Documentación Técnica: Migración de sqrp_publicos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al reporte de Estacionamientos Públicos, originalmente implementado en Delphi usando QuickReport y consultas SQL dinámicas. La migración se realiza a una arquitectura moderna basada en Laravel (API), Vue.js (frontend SPA) y PostgreSQL (base de datos), centralizando la lógica de negocio en stored procedures y exponiendo la funcionalidad mediante un endpoint API unificado.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3+, componente de página independiente.
- **Base de Datos:** PostgreSQL, lógica de reporte en stored procedure `sqrp_publicos_report`.
- **Patrón API:** eRequest/eResponse, permitiendo la extensión y centralización de la lógica de negocio.

## 3. Endpoint API Unificado
- **Ruta:** `/api/execute`
- **Método:** POST
- **Payload:**
  ```json
  {
    "eRequest": "sqrp_publicos_report",
    "params": { "opc": 1 }
  }
  ```
- **Respuesta:**
  ```json
  {
    "eResponse": {
      "status": "success",
      "message": "Relación de Estacionamientos Públicos clasificado por : Número",
      "data": [ ... ]
    }
  }
  ```

## 4. Stored Procedure: sqrp_publicos_report
- **Función:** Genera el reporte con todos los campos y clasificaciones requeridas, permitiendo ordenar por diferentes criterios según el parámetro `opc`.
- **Parámetro:** `order_by` (text) — columna(s) por las que se ordena el resultado.
- **Retorno:** Tabla con todos los campos originales y los campos calculados (j1, jc1, h1, hc1, etc.).

## 5. Controlador Laravel
- **Clase:** `App\Http\Controllers\Api\ExecuteController`
- **Método principal:** `handle(Request $request)`
- **Lógica:**
  - Recibe el eRequest y parámetros.
  - Llama al stored procedure correspondiente.
  - Devuelve la respuesta en formato eResponse.

## 6. Componente Vue.js
- **Nombre:** `SqrpPublicosPage`
- **Características:**
  - Página independiente con ruta propia.
  - Selector para tipo de clasificación (opc).
  - Tabla de resultados con todos los campos relevantes.
  - Breadcrumb de navegación.
  - Manejo de estados de carga y error.

## 7. Seguridad y Buenas Prácticas
- El endpoint `/api/execute` valida el eRequest y parámetros.
- El stored procedure utiliza SQL dinámico seguro (no expone inyección, ya que el ordenamiento es controlado).
- El frontend no expone lógica sensible y sólo consume la API.

## 8. Extensibilidad
- Para agregar nuevos reportes o procesos, basta con implementar un nuevo eRequest en el controlador y su respectivo stored procedure.

## 9. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad y robustez del sistema.

---
