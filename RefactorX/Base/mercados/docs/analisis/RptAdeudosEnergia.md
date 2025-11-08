# Documentación Técnica: Migración RptAdeudosEnergia Delphi a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el reporte de adeudos de energía eléctrica por local, migrando la lógica de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). Toda la lógica de consulta y cálculo se traslada a stored procedures en PostgreSQL, y la comunicación entre frontend y backend se realiza mediante un endpoint API unificado usando el patrón eRequest/eResponse.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 2/3 SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, lógica de reportes en stored procedures.

## 3. Endpoint API Unificado
- **Ruta:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": "RptAdeudosEnergia.getReport",
    "params": {
      "axo": 2024,
      "oficina": 1
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

## 4. Stored Procedures
- **rpt_adeudos_energia(axo, oficina):** Devuelve el listado de adeudos, datos del local, nombre, locales adicionales, meses y adeudo total por local.
- **rpt_adeudos_energia_meses(id_energia, axo):** Devuelve los periodos (meses/bimestres) y el importe de adeudo para un id_energia y año.

## 5. Lógica de Negocio Migrada
- El cálculo de campos como `datoslocal`, `meses` y `cuota` se realiza en el stored procedure principal.
- El frontend ajusta los labels de columnas según el año y la oficina (por ejemplo, "Cuota Mes." vs "Cuota Bim.").
- El frontend muestra totales y cuenta de locales con adeudo.

## 6. Seguridad
- Validación de parámetros en el backend.
- El endpoint sólo ejecuta procedimientos conocidos.
- Se recomienda proteger el endpoint con autenticación JWT o similar en producción.

## 7. Extensibilidad
- Para agregar nuevos reportes o acciones, basta con agregar nuevos casos en el controlador y nuevos stored procedures.

## 8. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.

## 9. Dependencias
- Laravel 10+
- Vue.js 2/3
- PostgreSQL 12+

## 10. Notas de Migración
- Los nombres de campos y tablas deben coincidir con los de la base de datos origen.
- El procedimiento principal replica la lógica de Delphi, incluyendo la construcción de campos calculados.
