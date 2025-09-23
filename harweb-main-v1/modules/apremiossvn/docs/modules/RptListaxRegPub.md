# Documentación Técnica: Migración de Formulario RptListaxRegPub (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al reporte "Listado de Registros de Mercados con Requerimientos" originalmente implementado en Delphi. La migración incluye:
- Backend en Laravel (API REST unificada)
- Frontend en Vue.js (página independiente)
- Lógica SQL en stored procedures PostgreSQL
- Comunicación mediante endpoint único `/api/execute` usando patrón eRequest/eResponse

## 2. Arquitectura
- **Backend:** Laravel 10+, PostgreSQL
- **Frontend:** Vue.js 2/3 (compatible), Bootstrap opcional para estilos
- **API:** Un solo endpoint `/api/execute` que recibe `{ eRequest, params }` y responde `{ success, data, message }`
- **Stored Procedures:** Toda la lógica de consulta y catálogo se implementa en funciones de PostgreSQL

## 3. Endpoints y Requests
### /api/execute
- **Método:** POST
- **Body:**
  ```json
  {
    "eRequest": "RptListaxRegPub.getReport",
    "params": {
      "vigencia": "1|2|3|P|todas",
      "clave_practicado": "todas|clave",
      "numesta": "todas|número",
      "usuario_id_rec": 1
    }
  }
  ```
- **Respuestas:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## 4. Stored Procedures
- **rpt_listaxregpub_get_report:** Devuelve el listado filtrado según los parámetros.
- **rpt_listaxregpub_get_recaudadora_info:** Devuelve información de la recaudadora y zona del usuario.

## 5. Seguridad
- El endpoint debe protegerse con autenticación (token JWT o sesión Laravel).
- El parámetro `usuario_id_rec` debe obtenerse del usuario autenticado.

## 6. Frontend
- Página Vue.js independiente, sin tabs.
- Filtros de búsqueda (vigencia, clave_practicado, numesta)
- Tabla de resultados con totales y sumatorias.
- Breadcrumb de navegación.
- Manejo de estados: cargando, error, sin datos.

## 7. Backend
- Controlador Laravel único (`ExecuteController`) con lógica de ruteo por `eRequest`.
- Llamadas a stored procedures usando DB::select.
- Manejo de errores y validaciones.

## 8. Consideraciones de Migración
- Los campos calculados (como VigReg) se calculan en el stored procedure.
- Los nombres de tablas y campos deben coincidir con la base de datos destino.
- El frontend asume que los nombres de los campos devueltos coinciden con los usados en Delphi.

## 9. Pruebas
- Se deben probar los filtros combinados y la correcta suma de totales.
- Validar que los datos de recaudadora correspondan al usuario autenticado.

## 10. Extensibilidad
- Para agregar nuevos reportes, basta con agregar nuevos eRequest y stored procedures.

---
