# Documentación Técnica: Migración Formulario Ctrol_Imp_Cat (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la impresión y consulta del catálogo de claves de operación. Permite al usuario seleccionar el orden de impresión (por número de control, clave o descripción) y visualizar una vista previa del reporte.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente, sin tabs, con navegación y vista previa.
- **Base de Datos:** PostgreSQL, lógica de consulta encapsulada en stored procedure `sp_ctrol_imp_cat_report`.

## 3. API (Laravel Controller)
- **Endpoint:** `/api/execute` (POST)
- **Parámetros:**
  - `action`: string. Acción a ejecutar (`getOptions`, `previewReport`)
  - `params`: objeto. Parámetros adicionales según acción.
- **Acciones soportadas:**
  - `getOptions`: Devuelve las opciones de ordenamiento.
  - `previewReport`: Devuelve el catálogo ordenado según parámetro `order` (1,2,3).
- **Respuesta:**
  - `success`: boolean
  - `data`: array de resultados
  - `message`: string (mensaje de error si aplica)

## 4. Frontend (Vue.js)
- Página independiente `/ctrol-imp-cat`.
- Permite seleccionar el orden de impresión mediante radio buttons.
- Botón "Vista Previa" ejecuta la consulta y muestra los resultados en tabla.
- Botón "Salir" regresa al inicio.
- Manejo de loading y errores.

## 5. Stored Procedure (PostgreSQL)
- `sp_ctrol_imp_cat_report(p_order integer)`
- Devuelve el catálogo de claves de operación ordenado según parámetro.
- Utiliza EXECUTE dynamic SQL para seleccionar el campo de ordenamiento.

## 6. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (middleware Laravel).
- Validar que el parámetro `order` sea 1,2,3 para evitar SQL injection.

## 7. Integración
- El frontend consume el endpoint mediante Axios.
- El backend ejecuta el stored procedure y retorna los datos en formato JSON.

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- El stored procedure puede ser extendido para filtros adicionales si se requiere.

## 9. Consideraciones de Migración
- El reporte QuickReport de Delphi se reemplaza por tabla HTML en la vista previa.
- La impresión/exportación puede ser implementada posteriormente usando librerías JS (ej: jsPDF, Excel export).

## 10. Dependencias
- Laravel 9+
- Vue.js 2/3
- PostgreSQL 12+

