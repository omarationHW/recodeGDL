# Documentación Técnica: Migración Formulario RptReq_Merc (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el formulario de "Orden de Requerimiento de Pago y Embargo (Mercados)" originalmente en Delphi, migrado a una arquitectura moderna usando:
- **Backend:** Laravel (PHP) + PostgreSQL (SPs)
- **Frontend:** Vue.js (SPA, página independiente)
- **API:** Único endpoint `/api/execute` usando patrón eRequest/eResponse

## 2. Arquitectura
- **Frontend:**
  - Componente Vue.js independiente, página completa, sin tabs.
  - Formulario para capturar oficina (zona), folio inicial y final.
  - Consulta y despliegue de resultados en tarjetas.
- **Backend:**
  - Controlador Laravel `RptReqMercController` con endpoint `/api/execute`.
  - Lógica de negocio y SQL encapsulada en stored procedures PostgreSQL.
  - Comunicación por eRequest/eResponse (JSON).
- **Base de Datos:**
  - Stored Procedures para reporte y catálogo de recaudadora.

## 3. API eRequest/eResponse
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "getRptReqMerc",
      "params": {
        "ofna": 1,
        "folio1": 100,
        "folio2": 200
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
      "error": null
    }
  }
  ```

## 4. Stored Procedures
- **rptreq_merc_reporte(ofna, folio1, folio2):**
  - Devuelve todos los datos requeridos para el reporte, equivalente al query Delphi.
- **rptreq_merc_recaudadora(reca):**
  - Devuelve información de la recaudadora y zona asociada.

## 5. Flujo de la Aplicación
1. Usuario ingresa oficina (zona), folio inicial y final.
2. Vue.js envía eRequest al endpoint `/api/execute`.
3. Laravel recibe, despacha a SP correspondiente y retorna eResponse.
4. Vue.js muestra los resultados en tarjetas.

## 6. Consideraciones
- **Seguridad:**
  - Validar que sólo usuarios autenticados puedan acceder (middleware Laravel).
- **Paginación:**
  - Si el reporte es muy grande, implementar paginación en SP y frontend.
- **Fechas:**
  - Se formatean en frontend para presentación.
- **Moneda:**
  - Se formatea en frontend usando `toLocaleString`.

## 7. Extensibilidad
- El endpoint `/api/execute` puede despachar múltiples acciones, permitiendo crecimiento futuro.

## 8. Pruebas
- Casos de uso y pruebas incluidas para asegurar la funcionalidad y robustez.

## 9. Migración de lógica Delphi
- Toda la lógica de consulta y agrupación de datos se trasladó a SPs.
- El cálculo de periodos, totales y sumatorias se realiza en SQL y/o frontend.
- El formato de fecha a letras puede implementarse en frontend si se requiere.
