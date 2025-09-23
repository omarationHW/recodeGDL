# Documentación Técnica: Migración de Formulario regHfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario `regHfrm` de Delphi muestra y administra los registros históricos de movimientos catastrales (tabla `h_catastro`). La migración implica:
- Backend API en Laravel (controlador único, endpoint `/api/execute`)
- Lógica SQL en stored procedures PostgreSQL
- Frontend como página Vue.js independiente
- Comunicación por eRequest/eResponse

## 2. Arquitectura
- **Backend**: Laravel Controller (`RegHController`) expone un endpoint `/api/execute` que recibe un objeto JSON con `eRequest` y `params`. Cada acción (listar, crear, editar, eliminar) se mapea a un método y a un stored procedure.
- **Frontend**: Componente Vue.js de página completa, sin tabs, con tabla, formularios de alta/edición y navegación breadcrumb.
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint**: `POST /api/execute`
- **Request**:
  ```json
  {
    "eRequest": "get_historic_records",
    "params": { "cvecuenta": 12345 }
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": [ { "axocomp": 2023, "nocomp": 1 }, ... ],
    "message": ""
  }
  ```

## 4. Stored Procedures
- `sp_get_historic_records(p_cvecuenta)`
- `sp_get_historic_record(p_cvecuenta, p_axocomp, p_nocomp)`
- `sp_create_historic_record(p_cvecuenta, p_axocomp, p_nocomp)`
- `sp_update_historic_record(p_cvecuenta, p_axocomp, p_nocomp, p_new_axocomp, p_new_nocomp)`
- `sp_delete_historic_record(p_cvecuenta, p_axocomp, p_nocomp)`

## 5. Seguridad
- Validación de parámetros en el controlador
- Solo permite operaciones sobre registros históricos de la cuenta indicada
- El endpoint puede protegerse con middleware de autenticación Laravel

## 6. Frontend (Vue.js)
- Página independiente `/reg-historic`
- Tabla con columnas Año (`axocomp`), No. Comp. (`nocomp`), acciones (editar/eliminar)
- Formularios modales para alta y edición
- Breadcrumb para navegación
- Llama a `/api/execute` con eRequest adecuado

## 7. Integración
- El frontend y backend se comunican exclusivamente por `/api/execute` usando el patrón eRequest/eResponse
- El frontend puede ser integrado en un router Vue.js como página independiente

## 8. Consideraciones de Migración
- No se usan tabs ni componentes tabulares; cada formulario es una página
- El formulario es autosuficiente y no depende de otros módulos
- El diseño permite extensión para agregar más campos a futuro

## 9. Ejemplo de Uso
- Para listar registros históricos de la cuenta 12345:
  ```json
  {
    "eRequest": "get_historic_records",
    "params": { "cvecuenta": 12345 }
  }
  ```
- Para crear un registro:
  ```json
  {
    "eRequest": "create_historic_record",
    "params": { "cvecuenta": 12345, "axocomp": 2024, "nocomp": 2 }
  }
  ```

## 10. Extensión
- Para agregar más campos, modificar los stored procedures y el controlador para aceptar/retornar los nuevos campos.

## 11. Pruebas
- Ver sección de casos de uso y casos de prueba.
