# Documentación Técnica: Consulta de Zonas (Cons_Zonas)

## Descripción General
Este módulo permite consultar el catálogo de zonas del sistema, mostrando los campos: Control, Zona, Sub-Zona y Descripción. Permite ordenar por cualquiera de estos campos y exportar el resultado a Excel (CSV). La consulta se realiza a través de un endpoint API unificado y un stored procedure en PostgreSQL.

## Arquitectura
- **Backend:** Laravel Controller (ConsZonasController) expone un endpoint unificado `/api/execute` que recibe un objeto `eRequest` con la operación y parámetros.
- **Frontend:** Componente Vue.js de página completa, con navegación breadcrumb, tabla de resultados, selección de orden y exportación a Excel.
- **Base de Datos:** PostgreSQL, con stored procedure `sp_cons_zonas_list` para obtener los datos ordenados dinámicamente.

## API
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "eRequest": {
      "operation": "cons_zonas_list",
      "params": { "order": "ctrol_zona" }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [
        { "ctrol_zona": 1, "zona": 1, "sub_zona": 1, "descripcion": "Centro" },
        ...
      ],
      "message": ""
    }
  }
  ```

## Stored Procedure
- **Nombre:** `sp_cons_zonas_list`
- **Parámetro:** `p_order` (campo por el que se ordena, default `ctrol_zona`)
- **Retorna:** Tabla con los campos principales de la tabla `ta_16_zonas`.
- **Seguridad:** El campo de orden es validado con `quote_ident` para evitar SQL injection.

## Frontend (Vue.js)
- Página independiente, sin tabs.
- Breadcrumb de navegación.
- Tabla con los campos principales.
- Botones para exportar a Excel (CSV) y salir.
- Selección de orden por radio buttons.
- Lógica de exportación a CSV implementada en frontend.

## Backend (Laravel)
- Controlador único, método `execute`.
- Recibe operación y parámetros.
- Llama al stored procedure con el campo de orden.
- Devuelve datos en formato eResponse.
- Manejo de errores y logging.

## Seguridad
- El stored procedure utiliza `quote_ident` para evitar inyección SQL en el campo de orden.
- El endpoint requiere autenticación (no mostrado aquí, pero se recomienda usar middleware auth).

## Extensibilidad
- El endpoint y el patrón eRequest/eResponse permiten agregar más operaciones fácilmente.
- El frontend puede ser extendido para agregar filtros adicionales.

## Exportación a Excel
- El backend retorna los datos en JSON.
- El frontend convierte el JSON a CSV y lo descarga como archivo Excel-compatible.

## Pruebas
- Incluye casos de uso y escenarios de prueba para asegurar la funcionalidad y robustez del módulo.
