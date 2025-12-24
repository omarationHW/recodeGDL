# Documentación: RepDescImpto

## Análisis Técnico

# Documentación Técnica - Migración Formulario RepDescImpto (Delphi) a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo corresponde al reporte de descuentos de impuesto predial (RepDescImpto), permitiendo consultar, filtrar y exportar los descuentos aplicados y reactivados, con filtros por fechas, recaudadora y tipo de descuento. La migración se realizó a una arquitectura Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos), centralizando la lógica de negocio en stored procedures y un endpoint API unificado.

## Arquitectura
- **Backend:** Laravel 10+, controlador único (`RepDescImptoController`) con endpoint `/api/execute`.
- **Frontend:** Vue.js 3, componente de página independiente (`RepDescImpto.vue`).
- **Base de Datos:** PostgreSQL, lógica de reportes en stored procedures (`sp_rep_desc_impto_aplicados`, `sp_rep_desc_impto_reactivados`).
- **API Unificada:** Todas las acciones se ejecutan vía POST `/api/execute` usando el patrón eRequest/eResponse.

## API (Laravel)
- **Endpoint:** `/api/execute` (POST)
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "getDescuentos", // o 'getCatalogs', 'exportExcel', etc.
      "params": { ... } // parámetros según acción
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [...],
      "message": ""
    }
  }
  ```
- **Acciones soportadas:**
  - `getCatalogs`: Devuelve catálogos de recaudadoras y tipos de descuento.
  - `getDescuentos`: Devuelve los descuentos aplicados/reactivados según filtros.
  - `exportExcel`: (Frontend, no implementado en backend)

## Stored Procedures (PostgreSQL)
- **sp_rep_desc_impto_aplicados**: Devuelve descuentos aplicados, filtrando por fechas, recaudadora y tipo de descuento.
- **sp_rep_desc_impto_reactivados**: Devuelve descuentos reactivados, filtrando por fechas, recaudadora y tipo de descuento.

## Frontend (Vue.js)
- Página independiente, sin tabs, con formulario de filtros y tabla de resultados.
- Exportación a Excel se realiza en frontend (window.print o librería xlsx).
- Navegación y breadcrumbs opcionales.

## Seguridad
- El endpoint requiere autenticación (middleware Laravel) si la aplicación lo exige.
- Validación de parámetros en backend y frontend.

## Consideraciones de Migración
- Todas las queries SQL del Delphi fueron convertidas a stored procedures PostgreSQL.
- El endpoint `/api/execute` centraliza todas las acciones, usando el patrón eRequest/eResponse.
- El frontend Vue.js es una página completa, sin tabs ni componentes tabulares.
- El reporte puede ser exportado a Excel desde el frontend.

## Estructura de la Base de Datos
- Tablas principales: `descpred`, `descpred_reactiva`, `convcta`, `c_descpred`, `c_instituciones`, `usuarios`, `deptos`, `detsaldos`, `uem3`.
- Los stored procedures usan JOINs y subconsultas para obtener los datos requeridos.

## Extensibilidad
- Se pueden agregar más filtros o acciones en el controlador y stored procedures.
- El frontend puede adaptarse a nuevos requerimientos de presentación.

## Integración
- El componente Vue.js se integra en el router principal de la SPA.
- El endpoint `/api/execute` puede ser consumido por cualquier cliente autorizado.

## Casos de Uso

# Casos de Uso - RepDescImpto

**Categoría:** Form

## Caso de Uso 1: Consulta de descuentos aplicados por fecha de alta

**Descripción:** El usuario desea obtener un listado de todos los descuentos de impuesto predial aplicados entre dos fechas de alta, filtrando por una recaudadora específica.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte de Descuentos de Impuesto Predial.
2. Selecciona 'Aplicados' como tipo de archivo.
3. Selecciona 'Fecha Alta' como filtro de fecha.
4. Ingresa la fecha inicial y final.
5. Selecciona una recaudadora específica del catálogo.
6. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los descuentos aplicados en el rango de fechas y recaudadora seleccionada.

**Datos de prueba:**
{ "tipoArchivo": "aplicados", "tipoFecha": 1, "fecha1": "2024-01-01", "fecha2": "2024-03-31", "recaudadora": 2, "tipoDescuento": "" }

---

## Caso de Uso 2: Consulta de descuentos reactivados por tipo de descuento

**Descripción:** El usuario requiere ver los descuentos reactivados de un tipo específico, sin filtrar por fechas ni recaudadora.

**Precondiciones:**
El usuario tiene acceso y permisos.

**Pasos a seguir:**
1. Accede a la página del reporte.
2. Selecciona 'Reactivados' como tipo de archivo.
3. Deja los filtros de fecha y recaudadora en 'Todos'.
4. Selecciona un tipo de descuento específico.
5. Da clic en 'Buscar'.

**Resultado esperado:**
Se listan todos los descuentos reactivados del tipo seleccionado.

**Datos de prueba:**
{ "tipoArchivo": "reactivados", "tipoFecha": 0, "fecha1": "", "fecha2": "", "recaudadora": "", "tipoDescuento": 5 }

---

## Caso de Uso 3: Exportación de resultados a Excel

**Descripción:** El usuario desea exportar el listado de descuentos aplicados a Excel para análisis externo.

**Precondiciones:**
El usuario ya realizó una búsqueda y tiene resultados en pantalla.

**Pasos a seguir:**
1. Realiza una búsqueda de descuentos aplicados.
2. Da clic en 'Exportar Excel'.

**Resultado esperado:**
El navegador descarga o imprime la tabla de resultados en formato Excel o similar.

**Datos de prueba:**
No aplica (acción sobre resultados ya cargados).

---

## Casos de Prueba

# Casos de Prueba - RepDescImpto

## 1. Consulta básica de descuentos aplicados
- **Entrada:** tipoArchivo=aplicados, tipoFecha=0, recaudadora="", tipoDescuento=""
- **Acción:** Buscar
- **Resultado esperado:** Lista de todos los descuentos aplicados, sin filtro de fechas ni recaudadora.

## 2. Consulta por rango de fechas de alta
- **Entrada:** tipoArchivo=aplicados, tipoFecha=1, fecha1=2024-01-01, fecha2=2024-03-31
- **Acción:** Buscar
- **Resultado esperado:** Solo descuentos aplicados con fecha de alta en el rango.

## 3. Consulta de descuentos reactivados por tipo
- **Entrada:** tipoArchivo=reactivados, tipoFecha=0, tipoDescuento=5
- **Acción:** Buscar
- **Resultado esperado:** Solo descuentos reactivados del tipo 5.

## 4. Consulta con recaudadora y tipo de descuento
- **Entrada:** tipoArchivo=aplicados, recaudadora=3, tipoDescuento=7
- **Acción:** Buscar
- **Resultado esperado:** Solo descuentos aplicados de la recaudadora 3 y tipo 7.

## 5. Exportación a Excel
- **Precondición:** Hay resultados en pantalla
- **Acción:** Click en 'Exportar Excel'
- **Resultado esperado:** Descarga o impresión de la tabla de resultados.

## 6. Validación de campos obligatorios
- **Entrada:** tipoArchivo=aplicados, tipoFecha=1, fecha1="", fecha2=""
- **Acción:** Buscar
- **Resultado esperado:** Mensaje de error indicando que las fechas son obligatorias.

## 7. Seguridad - Acceso sin autenticación
- **Acción:** Llamar a /api/execute sin token (si aplica)
- **Resultado esperado:** Error de autenticación o acceso denegado.

## Integración con Backend

> ⚠️ Pendiente de documentar

