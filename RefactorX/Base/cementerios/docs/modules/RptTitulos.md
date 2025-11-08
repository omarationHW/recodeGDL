# Documentación Técnica: Migración de Formulario RptTitulos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario **RptTitulos** de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad original, permitiendo la consulta y visualización de reportes de títulos, con criterios de búsqueda por fecha y folio.

## 2. Arquitectura
- **Backend:** Laravel API con endpoint unificado `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente, sin tabs, con navegación breadcrumb.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 3. Endpoints y Protocolo
- **POST /api/execute**
  - **Entrada:**
    - `eRequest`: Identificador de la operación (ej: `RptTitulos.getReport`)
    - `params`: Objeto con parámetros requeridos por la operación
  - **Salida:**
    - `eResponse`: Objeto con `success`, `data`, `message`

### Ejemplo de Request
```json
{
  "eRequest": "RptTitulos.getReport",
  "params": {
    "fecha": "2024-06-01",
    "folio": 12345
  }
}
```

### Ejemplo de Response
```json
{
  "eResponse": {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
}
```

## 4. Stored Procedures
- **rpt_titulos_get_report(fecha, folio):** Devuelve los datos del reporte de títulos.
- **rpt_titulos_get_recaudadora(id_rec):** Devuelve los datos de la recaudadora.
- **rpt_titulos_fecha_aletras_corta(fecha):** Devuelve la fecha en formato corto en español.

## 5. Controlador Laravel
- Centraliza todas las operaciones bajo `/api/execute`.
- Valida parámetros y llama a los stored procedures correspondientes.
- Devuelve siempre el objeto `eResponse`.

## 6. Componente Vue.js
- Página independiente para el formulario RptTitulos.
- Permite ingresar fecha y folio, consultar y mostrar resultados en tabla.
- Incluye botón de impresión y breadcrumbs.
- Usa fetch API para consumir `/api/execute`.

## 7. Seguridad
- Validación de parámetros en backend.
- No expone SQL ni lógica interna al frontend.

## 8. Consideraciones de Migración
- Todos los nombres de campos y lógica de joins se mantienen según el formulario Delphi original.
- La lógica de formato de fecha se implementa como stored procedure para mantener consistencia.
- El frontend no implementa tabs ni componentes compartidos con otros formularios.

## 9. Extensibilidad
- Nuevos reportes o formularios pueden agregarse siguiendo el mismo patrón eRequest/eResponse y stored procedures.

## 10. Pruebas
- Casos de uso y pruebas detalladas en secciones siguientes.
