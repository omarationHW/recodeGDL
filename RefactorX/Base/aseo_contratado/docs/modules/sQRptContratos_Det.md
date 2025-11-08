# Documentación Técnica: Migración de Formulario sQRptContratos_Det (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al reporte "Padron de Contratos" del Municipio de Guadalajara, originalmente implementado en Delphi. Se migró a una arquitectura moderna usando Laravel (API), Vue.js (frontend) y PostgreSQL (base de datos), centralizando la lógica de negocio en stored procedures y exponiendo la funcionalidad mediante un endpoint API unificado.

## 2. Arquitectura
- **Backend:** Laravel 10+, con un único endpoint `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend:** Vue.js 3+, componente de página independiente, sin tabs, con navegación breadcrumb.
- **Base de Datos:** PostgreSQL, lógica de consulta y resumen encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "operation": "getContratosDet", // o "getContratosDetSummary"
      "params": {
        "vigencia": "T", // 'T' = Todos, 'V' = Vigentes, 'C' = Cancelados
        "ofna": 0,        // ID de recaudadora (0 = todas)
        "opcion": 1,      // Clasificación (1-8)
        "num_emp": null   // Número de empleado (opcional)
      }
    }
  }
  ```
- **Response:**
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
- **rpt_contratos_det:** Devuelve el detalle de contratos según filtros y clasificación.
- **rpt_contratos_det_summary:** Devuelve el resumen (total, vigentes, cancelados) según filtros.

## 5. Frontend (Vue.js)
- Página independiente `/contratos-det`.
- Filtros: Vigencia, Recaudadora, Clasificación, Num. Empleado.
- Tabla de resultados y resumen inferior.
- Breadcrumb de navegación.

## 6. Seguridad
- Validación de parámetros en backend.
- Uso de parámetros en stored procedures para evitar SQL Injection.

## 7. Consideraciones
- El endpoint es extensible para otras operaciones.
- El frontend puede ser adaptado fácilmente a otros reportes siguiendo el mismo patrón.

## 8. Migración de Lógica Delphi
- La lógica de clasificación y conteo de vigentes/cancelados se trasladó a los stored procedures y a la capa de presentación.
- Los labels y títulos se mantienen en el frontend.

## 9. Pruebas
- Se recomienda probar con diferentes combinaciones de filtros y validar los totales.

## 10. Extensión
- Para agregar nuevos reportes, basta con crear nuevos stored procedures y mapearlos en el controlador.
