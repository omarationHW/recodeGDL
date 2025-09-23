# Documentación Técnica: Padrón de Convenios (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo implementa la consulta y exportación del padrón de convenios, migrando la lógica de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos y lógica de negocio). Toda la lógica de negocio y reportes se encapsula en stored procedures y se expone mediante un endpoint API unificado (`/api/execute`) bajo el patrón eRequest/eResponse.

## 2. Arquitectura
- **Backend:** Laravel 10+, controlador `PadronConveniosController`.
- **Frontend:** Vue.js 3+, componente de página independiente `PadronConveniosPage.vue`.
- **Base de Datos:** PostgreSQL 13+, lógica de reportes en stored procedures.
- **API:** Endpoint único `/api/execute` que recibe `{ eRequest: { action, params } }` y responde `{ eResponse: { success, data, message } }`.

## 3. Flujo de Datos
1. El usuario accede a la página de Padrón de Convenios.
2. El frontend carga catálogos (tipos, subtipos, recaudadoras, vigencias) vía API.
3. El usuario selecciona filtros y ejecuta la búsqueda.
4. El frontend envía un eRequest con acción `getPadronConvenios` y los filtros.
5. El backend ejecuta el stored procedure `sp_padron_convenios` y retorna los resultados.
6. El usuario puede consultar los folios de un convenio (parcialidades) y exportar a Excel.

## 4. API (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "getPadronConvenios",
      "params": {
        "tipo": 3,
        "subtipo": 1,
        "vigencia": "A",
        "recaudadora": 1,
        "anio_desde": 2020,
        "anio_hasta": 2024
      }
    }
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

## 5. Stored Procedures
- **sp_padron_convenios:** Consulta principal del padrón de convenios con filtros.
- **sp_padron_convenios_folios:** Consulta de folios (parcialidades) de un convenio.

## 6. Frontend (Vue.js)
- Página independiente, sin tabs.
- Filtros: tipo, subtipo, vigencia, recaudadora, año desde/hasta.
- Tabla de resultados con acción para ver folios.
- Exportación a Excel (CSV).
- Breadcrumb de navegación.

## 7. Seguridad
- Validación de parámetros en backend.
- El endpoint puede protegerse con middleware de autenticación según la política del sistema.

## 8. Consideraciones de Migración
- Toda la lógica de SQL dinámica y cálculos de campos Delphi se migró a stored procedures y/o lógica de backend.
- El frontend es desacoplado y no usa tabs ni componentes tabulares.
- El endpoint es único y flexible para futuras extensiones.

## 9. Extensibilidad
- Se pueden agregar nuevas acciones al endpoint `/api/execute` simplemente agregando nuevos métodos en el controlador y/o nuevos stored procedures.

---
