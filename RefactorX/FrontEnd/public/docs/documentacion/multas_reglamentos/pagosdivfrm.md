# Documentación: pagosdivfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario pagosdivfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la consulta de pagos diversos (cveconcepto=4) con filtros por fecha, recaudadora, caja, folio y nombre del contribuyente. Incluye la visualización de detalles del pago, aplicaciones (auditoría) y cancelaciones.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel API, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica de búsqueda encapsulada en stored procedures.

## 3. Endpoints API
### POST /api/execute
- **Request:**
  - `action`: Acción a ejecutar (`buscar_pagos_diversos`, `detalle_pago_diverso`)
  - `params`: Parámetros de la acción
- **Response:**
  - `success`: true/false
  - `data`: Datos resultantes
  - `message`: Mensaje de error o información

#### Acciones soportadas
- `buscar_pagos_diversos`: Busca pagos diversos según filtros.
- `detalle_pago_diverso`: Devuelve detalles de un pago (diversos, auditoría, cancelación).

## 4. Stored Procedures
- **pagosdiv_buscar**: Devuelve pagos diversos según filtros. Implementa la lógica de búsqueda dinámica.

## 5. Frontend (Vue.js)
- Formulario de búsqueda con validación de números.
- Tabla de resultados.
- Vista de detalle con información de contribuyente, concepto, aplicaciones y cancelación.
- Navegación breadcrumb.

## 6. Seguridad
- Validación de parámetros en backend.
- Uso de procedimientos almacenados para evitar SQL Injection.

## 7. Consideraciones
- El endpoint es único y recibe la acción a ejecutar.
- El frontend es desacoplado y consume la API vía fetch/AJAX.
- El stored procedure permite filtros opcionales.

## 8. Tablas involucradas
- `pagos`: Recibos de pagos diversos.
- `pago_diversos`: Detalle de contribuyente y concepto.
- `auditoria`: Aplicación de pagos.
- `pagoscan`: Cancelaciones.

## 9. Validaciones
- Los campos recaud y folio sólo aceptan números.
- Todos los filtros son opcionales.

## 10. Extensibilidad
- Para agregar nuevas acciones, implementar en el controlador y/o nuevos stored procedures.

---

## Casos de Uso

# Casos de Uso - pagosdivfrm

**Categoría:** Form

## Caso de Uso 1: Búsqueda de pagos diversos por fecha y recaudadora

**Descripción:** El usuario desea consultar todos los pagos diversos realizados en una fecha específica y por una recaudadora determinada.

**Precondiciones:**
Existen pagos diversos registrados en la base de datos para la fecha y recaudadora indicadas.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Pagos Diversos.
2. Ingresa la fecha deseada en el campo 'Fecha'.
3. Ingresa el número de recaudadora en el campo 'Rec'.
4. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los pagos diversos que coinciden con la fecha y recaudadora ingresadas.

**Datos de prueba:**
fecha: 2024-06-10
recaud: 2
caja: (vacío)
folio: (vacío)
contribuyente: (vacío)

---

## Caso de Uso 2: Consulta de detalle de un pago diverso

**Descripción:** El usuario desea ver el detalle completo de un pago diverso específico, incluyendo contribuyente, concepto, aplicaciones y cancelación.

**Precondiciones:**
Existe al menos un pago diverso en la base de datos.

**Pasos a seguir:**
1. El usuario realiza una búsqueda general de pagos diversos.
2. En la tabla de resultados, identifica el pago de interés y presiona el botón 'Detalle'.

**Resultado esperado:**
Se muestra la información detallada del pago, incluyendo nombre, domicilio, concepto, aplicaciones y, si existe, información de cancelación.

**Datos de prueba:**
cvepago: 12345 (debe existir en la base de datos)

---

## Caso de Uso 3: Búsqueda por nombre de contribuyente

**Descripción:** El usuario busca pagos diversos filtrando por el nombre del contribuyente.

**Precondiciones:**
Existen pagos diversos asociados a contribuyentes cuyos nombres contienen la cadena buscada.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Pagos Diversos.
2. Ingresa una parte del nombre del contribuyente en el campo 'Nombre'.
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestran todos los pagos diversos cuyo contribuyente coincide parcial o totalmente con el texto ingresado.

**Datos de prueba:**
contribuyente: "JUAN"

---

## Casos de Prueba

# Casos de Prueba: Consulta de Pagos Diversos

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|-------------------|
| 1 | Buscar pagos por fecha y recaudadora | fecha: 2024-06-10, recaud: 2 | Tabla con pagos diversos de esa fecha y recaudadora |
| 2 | Buscar pagos por folio inexistente | folio: 99999999 | Mensaje: 'No existen recibos de diversos con este criterio.' |
| 3 | Buscar pagos por nombre de contribuyente | contribuyente: "MARIA" | Tabla con pagos diversos cuyo contribuyente contiene "MARIA" |
| 4 | Ver detalle de pago | cvepago: 12345 | Se muestra detalle con nombre, domicilio, concepto, aplicaciones y cancelación (si existe) |
| 5 | Validación de solo números en recaud y folio | recaud: "abc" | Al teclear letras, alerta: 'Solo puedes teclear números' |
| 6 | Limpiar formulario | (Cualquier búsqueda previa) | Todos los campos vacíos y resultados ocultos |

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

