# Documentación Técnica: Migración Formulario List_Mov (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al formulario "Listado de Movimientos de Cementerios" (List_Mov) migrado desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad original, modernizando la interfaz y la lógica de acceso a datos.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel, con un endpoint único `/api/execute` que recibe acciones (eRequest/eResponse).
- **Base de Datos:** PostgreSQL, toda la lógica SQL relevante se implementa como stored procedures.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Payload:**
  ```json
  {
    "action": "list_movements", // o "print_report"
    "params": {
      "fecha1": "YYYY-MM-DD",
      "fecha2": "YYYY-MM-DD",
      "reca": 1
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "data": [ ... ]
  }
  ```

## 4. Stored Procedure Principal
- **Nombre:** `sp_list_movements`
- **Entradas:**
  - `p_fecha1` (DATE): Fecha inicial
  - `p_fecha2` (DATE): Fecha final
  - `p_reca` (INTEGER): ID de recaudadora
- **Salida:** Listado de movimientos con todos los campos requeridos, incluyendo el campo calculado `llave`.

## 5. Controlador Laravel
- **Ubicación:** `app/Http/Controllers/ListMovController.php`
- **Métodos:**
  - `execute`: Recibe la acción y parámetros, despacha a los métodos internos.
  - `listMovements`: Llama al SP y retorna los resultados.
  - `printReport`: (Simulado) retorna los mismos datos, en un sistema real generaría un PDF.

## 6. Componente Vue.js
- **Ubicación:** `src/pages/ListMovPage.vue`
- **Características:**
  - Formulario con selección de fechas y recaudadora.
  - Tabla de resultados.
  - Botón para imprimir (simulado).
  - Manejo de errores y estados de carga.
  - Navegación breadcrumb.

## 7. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (middleware Laravel), y los permisos de usuario deben ser validados según corresponda.

## 8. Consideraciones de Migración
- El campo calculado `llave` se implementa en el SP usando `CONCAT_WS`.
- El campo de recaudadora puede ser visible u oculto según el usuario (lógica frontend/backend).
- El reporte impreso es simulado; en producción se recomienda usar una librería de generación de PDF.

## 9. Pruebas y Validación
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los stored procedures pueden ser versionados y auditados en la base de datos.
