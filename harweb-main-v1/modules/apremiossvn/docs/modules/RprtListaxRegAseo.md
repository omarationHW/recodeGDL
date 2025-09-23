# Documentación Técnica: Migración Formulario RprtListaxRegAseo (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo corresponde al reporte de registros de mercados con requerimientos de aseo, migrado desde Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend SPA) y PostgreSQL (base de datos y lógica de negocio).

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint unificado `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 2/3 SPA, cada formulario es una página independiente
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures

## 3. Endpoints API
### `/api/execute` (POST)
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "getReportData", // o "getRecaudadoraZona"
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

#### Acciones soportadas:
- `getReportData`: Obtiene el listado de registros de aseo (ver stored procedure `sp_rprt_listax_reg_aseo`)
- `getRecaudadoraZona`: Obtiene datos de recaudadora y zona (ver stored procedure `sp_get_recaudadora_zona`)

## 4. Stored Procedures
- **sp_rprt_listax_reg_aseo:**
  - Parámetros: `id_rec`, `tipo_aseo`, `clave_practicado`, `vigencia`
  - Devuelve: Todos los campos requeridos para el reporte, con los filtros aplicados
- **sp_get_recaudadora_zona:**
  - Parámetro: `id_rec`
  - Devuelve: Datos de recaudadora y zona para la oficina

## 5. Frontend (Vue.js)
- Página independiente `/rprt-listax-reg-aseo`
- Formulario de filtros (oficina, tipo aseo, clave practicado, vigencia)
- Tabla de resultados con totales
- Exportación a CSV
- Breadcrumb de navegación

## 6. Seguridad
- Se recomienda proteger el endpoint `/api/execute` con autenticación JWT o session según la política del sistema.
- Validar y sanear todos los parámetros recibidos.

## 7. Consideraciones de Migración
- El query Delphi original usaba joins implícitos y outer joins; en PostgreSQL se migró a JOIN/LEFT JOIN explícitos.
- Los campos y tipos se ajustaron a la estructura de la base de datos destino.
- El frontend permite exportar los resultados a CSV para facilitar la impresión o análisis externo.

## 8. Extensibilidad
- El endpoint unificado permite agregar nuevas acciones fácilmente.
- Los stored procedures pueden ser reutilizados por otros módulos.

## 9. Pruebas y Validación
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad y la migración de datos.

---
