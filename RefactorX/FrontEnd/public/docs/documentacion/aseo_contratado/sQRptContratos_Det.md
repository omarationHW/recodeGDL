# Documentación Técnica: sQRptContratos_Det

## Análisis

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


## Casos de Uso

# Casos de Uso - sQRptContratos_Det

**Categoría:** Form

## Caso de Uso 1: Consulta de todos los contratos vigentes, clasificados por número de contrato

**Descripción:** El usuario desea obtener el listado completo de contratos vigentes, ordenados por número de contrato.

**Precondiciones:**
El usuario tiene acceso al sistema y existen contratos vigentes en la base de datos.

**Pasos a seguir:**
1. Ingresar a la página 'Padron de Contratos'.
2. Seleccionar 'Vigentes' en el filtro de Vigencia.
3. Seleccionar 'Numero de Contrato' en Clasificación.
4. Dejar Recaudadora en 0 (todas).
5. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se muestra la tabla con todos los contratos vigentes, ordenados por número de contrato. El resumen muestra el total de contratos y el número de vigentes/cancelados.

**Datos de prueba:**
vigencia: 'V', ofna: 0, opcion: 2, num_emp: null

---

## Caso de Uso 2: Consulta de contratos cancelados de una recaudadora específica

**Descripción:** El usuario requiere ver los contratos cancelados asociados a una recaudadora específica.

**Precondiciones:**
Existen contratos cancelados para la recaudadora con ID 5.

**Pasos a seguir:**
1. Ingresar a la página 'Padron de Contratos'.
2. Seleccionar 'Cancelados' en Vigencia.
3. Ingresar '5' en el campo Recaudadora.
4. Seleccionar cualquier clasificación.
5. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se listan solo los contratos cancelados de la recaudadora 5. El resumen muestra el total y el número de cancelados.

**Datos de prueba:**
vigencia: 'C', ofna: 5, opcion: 1, num_emp: null

---

## Caso de Uso 3: Consulta de contratos por domicilio, todos los estados de vigencia

**Descripción:** El usuario desea ver todos los contratos, clasificados por domicilio, sin importar su vigencia.

**Precondiciones:**
Existen contratos con diferentes domicilios y estados de vigencia.

**Pasos a seguir:**
1. Ingresar a la página 'Padron de Contratos'.
2. Seleccionar 'Todos' en Vigencia.
3. Seleccionar 'Domicilio' en Clasificación.
4. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se muestra la tabla de contratos agrupados por domicilio, con todos los estados de vigencia. El resumen muestra totales correctos.

**Datos de prueba:**
vigencia: 'T', ofna: 0, opcion: 8, num_emp: null

---



## Casos de Prueba

# Casos de Prueba: Padron de Contratos

| # | Descripción | Parámetros | Resultado Esperado |
|---|-------------|------------|--------------------|
| 1 | Consulta todos los contratos vigentes, ordenados por número de contrato | vigencia: 'V', ofna: 0, opcion: 2, num_emp: null | Tabla con contratos vigentes, ordenados por número de contrato. Resumen correcto. |
| 2 | Consulta contratos cancelados de recaudadora 5 | vigencia: 'C', ofna: 5, opcion: 1, num_emp: null | Solo contratos cancelados de recaudadora 5. Resumen correcto. |
| 3 | Consulta todos los contratos por domicilio | vigencia: 'T', ofna: 0, opcion: 8, num_emp: null | Contratos agrupados por domicilio, todos los estados de vigencia. |
| 4 | Consulta con recaudadora inexistente | vigencia: 'V', ofna: 9999, opcion: 1, num_emp: null | Tabla vacía, resumen con totales en 0. |
| 5 | Consulta con combinación inválida (vigencia 'Z') | vigencia: 'Z', ofna: 0, opcion: 1, num_emp: null | Tabla vacía, resumen con totales en 0. |
| 6 | Consulta con número de empleado específico | vigencia: 'V', ofna: 0, opcion: 1, num_emp: 123 | Solo contratos asociados al empleado 123 (si existen). |

**Notas:**
- Validar que los totales de resumen coincidan con los datos mostrados.
- Probar la navegación y recarga de filtros.
- Verificar formato de fechas y labels de vigencia.

