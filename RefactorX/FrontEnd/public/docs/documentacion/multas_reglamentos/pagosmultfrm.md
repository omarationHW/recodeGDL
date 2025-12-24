# Documentación: pagosmultfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario pagosmultfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la consulta de pagos de multas, filtrando por fecha, recaudadora, caja, folio, nombre del contribuyente o número de acta. Permite visualizar el detalle de cada multa, incluyendo información de descuentos, estatus y datos relacionados.

## 2. Arquitectura
- **Frontend:** Vue.js (Single Page Component, ruta independiente)
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Base de Datos:** PostgreSQL (toda la lógica SQL encapsulada en stored procedures)
- **Comunicación:** El frontend envía un objeto `eRequest` y `params` al endpoint `/api/execute`. El backend ejecuta el stored procedure correspondiente y retorna la respuesta en `eResponse`.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "pagosmultfrm.searchPagosMultas",
    "params": {
      "fecha": "2024-06-01",
      "recaud": "1",
      "caja": "A",
      "folio": "123",
      "nombre": "JUAN",
      "num_acta": "456"
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
Toda la lógica de consulta y cálculo reside en funciones de PostgreSQL (ver sección `stored_procedures`).

## 5. Flujo de la Aplicación
1. El usuario ingresa criterios de búsqueda y presiona "Buscar".
2. El frontend envía la petición a `/api/execute` con `eRequest: pagosmultfrm.searchPagosMultas`.
3. El backend ejecuta el SP correspondiente y retorna los pagos encontrados.
4. El usuario puede seleccionar un pago para ver el detalle de la multa, que se obtiene mediante otro SP.
5. Los descuentos y datos relacionados se consultan con SPs adicionales.

## 6. Seguridad
- Validación de parámetros en el backend.
- Uso de funciones parametrizadas para evitar SQL Injection.

## 7. Consideraciones de Migración
- Los campos calculados (estatus, descuento) se calculan en el SP de detalle.
- Los combos y lookups de Delphi se resuelven mediante joins en los SPs.
- El frontend es completamente independiente y no usa tabs.

## 8. Extensibilidad
- Para agregar nuevos filtros o columnas, modificar el SP y el frontend.
- Para agregar nuevas operaciones, definir un nuevo `eRequest` y SP.

## 9. Dependencias
- Laravel >= 9.x
- Vue.js >= 3.x
- PostgreSQL >= 12

## 10. Ejemplo de Integración
Ver sección de casos de uso y pruebas.

## Casos de Uso

# Casos de Uso - pagosmultfrm

**Categoría:** Form

## Caso de Uso 1: Búsqueda de pagos de multas por fecha y recaudadora

**Descripción:** El usuario desea consultar todos los pagos de multas realizados en una fecha específica y por una recaudadora determinada.

**Precondiciones:**
El usuario tiene acceso al sistema y existen pagos de multas registrados para la fecha y recaudadora indicadas.

**Pasos a seguir:**
1. El usuario accede a la página de consulta de pagos de multas.
2. Ingresa la fecha (por ejemplo, 2024-06-01) y el número de recaudadora (por ejemplo, 1).
3. Presiona el botón 'Buscar'.
4. El sistema muestra la lista de pagos encontrados.

**Resultado esperado:**
Se muestra una tabla con los pagos de multas correspondientes a la fecha y recaudadora seleccionadas.

**Datos de prueba:**
{ "fecha": "2024-06-01", "recaud": "1" }

---

## Caso de Uso 2: Consulta de detalle de multa y descuentos

**Descripción:** El usuario consulta el detalle de una multa específica, incluyendo los descuentos aplicados.

**Precondiciones:**
El usuario ya realizó una búsqueda y tiene a la vista la lista de pagos de multas.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Detalle' de un pago de la lista.
2. El sistema consulta y muestra el detalle de la multa, incluyendo información de contribuyente, domicilio, giro, calificación, descuento, multa, gastos, total, estatus y observaciones.
3. El sistema muestra una tabla con los descuentos aplicados a la multa.

**Resultado esperado:**
Se muestra el detalle completo de la multa y los descuentos asociados.

**Datos de prueba:**
{ "id_multa": 1001 }

---

## Caso de Uso 3: Búsqueda por nombre de contribuyente y número de acta

**Descripción:** El usuario busca pagos de multas filtrando por nombre de contribuyente y número de acta.

**Precondiciones:**
Existen pagos de multas asociados al nombre y número de acta proporcionados.

**Pasos a seguir:**
1. El usuario accede a la página de consulta de pagos de multas.
2. Ingresa el nombre del contribuyente (por ejemplo, 'JUAN') y el número de acta (por ejemplo, 456).
3. Presiona el botón 'Buscar'.
4. El sistema muestra la lista de pagos encontrados.

**Resultado esperado:**
Se muestra una tabla con los pagos de multas que coinciden con el nombre y número de acta indicados.

**Datos de prueba:**
{ "nombre": "JUAN", "num_acta": "456" }

---

## Casos de Prueba

# Casos de Prueba: pagosmultfrm

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|-------------------|
| 1 | Buscar pagos de multas por fecha | { "fecha": "2024-06-01" } | Lista de pagos de multas para esa fecha |
| 2 | Buscar pagos por recaudadora y caja | { "recaud": "2", "caja": "A" } | Lista de pagos filtrados por recaudadora y caja |
| 3 | Buscar pagos por folio inexistente | { "folio": "999999" } | Lista vacía, mensaje de 'No existen recibos de multas con este criterio.' |
| 4 | Buscar pagos por nombre de contribuyente | { "nombre": "MARIA" } | Lista de pagos donde el contribuyente contiene 'MARIA' |
| 5 | Ver detalle de multa con descuentos | { "id_multa": 1001 } | Detalle de multa con tabla de descuentos |
| 6 | Ver detalle de multa sin descuentos | { "id_multa": 1002 } | Detalle de multa, tabla de descuentos vacía |
| 7 | Buscar pagos por número de acta | { "num_acta": "456" } | Lista de pagos asociados al número de acta 456 |
| 8 | Buscar pagos sin ningún filtro | { } | Lista de todos los pagos de multas (puede ser paginada o limitada) |

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

