# Documentación Técnica: Migración de Formulario RprtListaxRegEstacionometro

## 1. Descripción General
Este desarrollo migra el formulario Delphi `RprtListaxRegEstacionometro` a una arquitectura moderna basada en Laravel (API RESTful), Vue.js (SPA), y PostgreSQL (Stored Procedures), siguiendo el patrón eRequest/eResponse con endpoint unificado `/api/execute`.

## 2. Arquitectura
- **Backend:** Laravel 10+, PostgreSQL 13+
- **Frontend:** Vue.js 2/3 (compatible con Vue CLI o Vite)
- **API:** Un único endpoint `/api/execute` que recibe `{ action, params }` y responde `{ success, data, message }`.
- **Base de Datos:** Toda la lógica de consulta se traslada a stored procedures en PostgreSQL.

## 3. Endpoints
### /api/execute
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "getEstacionometroReport",
    "params": {
      "vigencia": "1|2|3|P|todas",
      "clave_practicado": "clave|todas",
      "colonia": "nombre_colonia",
      "oficina": 2
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## 4. Stored Procedures
- **rpt_listaxreg_estacionometro:** Devuelve el listado de registros filtrados.
- **get_recaudadora_zona:** Devuelve información de la recaudadora y zona.

## 5. Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o session-based.
- Validar y sanear todos los parámetros recibidos.

## 6. Frontend
- Página Vue.js independiente, sin tabs.
- Formulario para filtros (vigencia, clave_practicado, colonia, oficina).
- Tabla de resultados con totales y sumatorias.
- Breadcrumb para navegación.
- Manejo de errores y estados de carga.

## 7. Backend
- Controlador Laravel centralizado (`ExecuteController`).
- Uso de DB::select para invocar stored procedures.
- Manejo de errores y respuesta unificada.

## 8. Pruebas
- Casos de uso y pruebas unitarias/manuales para cada escenario de consulta.

## 9. Extensibilidad
- Para agregar nuevas acciones, basta con añadir nuevos cases en el controlador y nuevos stored procedures.

## 10. Notas
- El reporte puede exportarse a Excel/PDF desde el frontend si se requiere (no incluido en este alcance).
- Los nombres de tablas y campos deben existir en la base de datos destino (`BasePHP`).
