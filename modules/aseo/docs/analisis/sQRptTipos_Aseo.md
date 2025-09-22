# Documentación Técnica: Migración de Formulario sQRptTipos_Aseo

## 1. Descripción General
Este módulo implementa la migración del formulario Delphi `sQRptTipos_Aseo` a una arquitectura moderna basada en Laravel (API RESTful), Vue.js (SPA) y PostgreSQL (procedimientos almacenados). El objetivo es ofrecer una página de reporte/catalogación de los tipos de aseo, permitiendo la clasificación dinámica por diferentes campos.

## 2. Arquitectura
- **Backend:** Laravel 10+, PostgreSQL
- **Frontend:** Vue.js 3+
- **API:** Endpoint único `/api/execute` usando patrón eRequest/eResponse
- **Base de datos:** Procedimientos almacenados para lógica de negocio

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "get_tipos_aseo_report",
    "params": { "opcion": 1 }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```
- **Parámetro `opcion`:**
  - 1: Clasificar por Número de Control (`ctrol_aseo`)
  - 2: Clasificar por Tipo (`tipo_aseo`)
  - 3: Clasificar por Descripción (`descripcion`)

## 4. Stored Procedure
- **Nombre:** `sp_ta_16_tipo_aseo_report`
- **Parámetro:** `opcion integer`
- **Retorna:** Tabla con columnas `ctrol_aseo`, `tipo_aseo`, `descripcion` ordenada según la opción.

## 5. Frontend
- **Ruta:** `/tipos-aseo` (ejemplo)
- **Funcionalidad:**
  - Selector de clasificación
  - Tabla de resultados
  - Breadcrumb de navegación
  - Fecha/hora de impresión

## 6. Seguridad
- El endpoint puede protegerse con middleware de autenticación según la política del sistema.

## 7. Extensibilidad
- El endpoint `/api/execute` permite agregar nuevas operaciones fácilmente usando el patrón eRequest.

## 8. Consideraciones
- El procedimiento almacenado está optimizado para ordenamiento dinámico.
- El frontend es responsivo y puede integrarse en cualquier SPA Vue.js.

## 9. Dependencias
- Laravel 10+, PHP 8+
- PostgreSQL 12+
- Vue.js 3+
- Axios (para llamadas HTTP)

## 10. Pruebas
- Ver sección de casos de uso y casos de prueba.
