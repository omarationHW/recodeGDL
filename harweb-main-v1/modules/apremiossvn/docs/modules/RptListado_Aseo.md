# Documentación Técnica: Migración de RptListado_Aseo (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el reporte "Listado de Adeudos para Requerimiento de Pago y Embargo, Derechos de Aseo Contratado" originalmente en Delphi, migrado a una arquitectura moderna con:
- Backend: Laravel (PHP), PostgreSQL (SPs)
- Frontend: Vue.js (SPA)
- API: Unificada bajo /api/execute usando patrón eRequest/eResponse

## 2. Arquitectura
- **Frontend**: Página Vue.js independiente, consulta el API y muestra los resultados en tabla con totales.
- **Backend**: Un único controlador Laravel recibe todas las peticiones y delega según el eRequest.
- **Base de Datos**: Toda la lógica de consulta y cálculo (incluyendo recargos) está en un Stored Procedure PostgreSQL.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": "RptListado_Aseo",
    "params": {
      "vtipo": "ORDINARIO", // o 'todos'
      "xnum1": 1000,
      "xnum2": 2000,
      "vrec": 1,
      "fecha_corte": "2024-06-30"
    }
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "rows": [ ... ],
      "totals": {
        "total_importe": 12345.67,
        "total_recargos": 234.56,
        ...
      }
    },
    "message": ""
  }
  ```

## 4. Stored Procedure
- **Nombre**: rpt_listado_aseo
- **Parámetros**:
  - vtipo: TEXT (tipo de aseo, 'todos' para todos)
  - xnum1, xnum2: INT (rango de contratos)
  - vrec: INT (id_rec)
  - vaxo: INT (año de corte)
  - vxmes: TEXT (mes de corte, con cero a la izquierda)
- **Lógica**:
  - Filtra contratos y pagos según parámetros.
  - Calcula recargos según reglas del negocio (idéntico a Delphi).
  - Obtiene gastos desde subconsulta.
  - Devuelve todos los campos necesarios para el reporte.

## 5. Frontend (Vue.js)
- Página independiente, no usa tabs.
- Formulario para filtros (fecha de corte, tipo, contratos, id_rec).
- Tabla con resultados y totales.
- Navegación breadcrumb.
- Lógica de consulta desacoplada del renderizado.

## 6. Seguridad
- El endpoint debe protegerse con autenticación (no incluido aquí por brevedad).
- Validar y sanear los parámetros en el backend.

## 7. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevos reportes y procesos sin crear nuevos endpoints.
- El SP puede extenderse para nuevos campos o reglas.

## 8. Pruebas
- Casos de uso y pruebas incluidas más abajo.

## 9. Consideraciones
- El SP asume que los nombres de tablas y campos en PostgreSQL coinciden con los del sistema original.
- Si existen diferencias, ajustar los nombres en el SP.
- El frontend asume que los tipos de aseo pueden ser fijos o consultados dinámicamente.
