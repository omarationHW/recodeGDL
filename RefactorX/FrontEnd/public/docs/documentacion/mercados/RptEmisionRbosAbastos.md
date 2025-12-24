# RptEmisionRbosAbastos

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario RptEmisionRbosAbastos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario de emisión de recibos de abastos (RptEmisionRbosAbastos) desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos y lógica de negocio en stored procedures). El objetivo es mantener la lógica de negocio, cálculos y reportes, pero modernizando la interfaz y la integración.

## 2. Arquitectura
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Backend**: Laravel, con endpoint único `/api/execute` que recibe eRequest/eResponse.
- **Base de Datos**: PostgreSQL, toda la lógica SQL y de negocio reside en stored procedures.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**: `{ action: 'nombreAccion', params: { ... } }`
- **Respuesta**: `{ success: bool, data: ..., message: '' }`

### Acciones soportadas para este formulario:
- `getReportData`: Obtiene el reporte principal de emisión de recibos de abastos.
- `getRequerimientos`: Obtiene los requerimientos (apremios) asociados a un local.
- `getRecargosMes`: Obtiene los recargos del mes para un año y periodo.

## 4. Stored Procedures
Toda la lógica de negocio y cálculos reside en stored procedures PostgreSQL:
- `sp_rpt_emision_rbos_abastos`: Genera el reporte principal.
- `sp_get_requerimientos_abastos`: Devuelve los requerimientos de un local.
- `sp_get_recargos_mes_abastos`: Devuelve los recargos del mes.

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Formulario para seleccionar oficina, mercado, año y periodo.
- Tabla de resultados con totales calculados en frontend.
- Modal para ver requerimientos de cada local.
- Navegación breadcrumb.
- Validaciones y mensajes de error.

## 6. Backend (Laravel)
- Controlador único con método `execute`.
- Cada acción del frontend se mapea a una función privada que llama al stored procedure correspondiente.
- Manejo de errores y logging.

## 7. Seguridad
- Validación de parámetros en backend.
- (Opcional) Autenticación JWT o session para restringir acceso.

## 8. Consideraciones de Migración
- Todos los cálculos de campos calculados (renta, rentaaxos, meses, subtotal, etc.) se realizan en el stored procedure.
- El frontend sólo muestra los datos y realiza sumatorias para totales.
- El reporte puede ser exportado a Excel desde el frontend (no incluido en este ejemplo, pero fácilmente integrable).

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar la estructura del endpoint.
- Los stored procedures pueden ser versionados y optimizados sin afectar el frontend.

## 10. Pruebas
- Se recomienda usar Postman para probar el endpoint `/api/execute` con diferentes acciones y parámetros.
- El frontend puede ser probado con datos reales y de prueba.

---


## Casos de Uso

# Casos de Uso - RptEmisionRbosAbastos

**Categoría:** Form

## Caso de Uso 1: Consulta de Recibos de Abastos para un Mercado y Periodo

**Descripción:** El usuario desea consultar el reporte de emisión de recibos de abastos para la oficina 5 (Cruz del Sur), mercado 1 (Abastos), año 2024 y periodo 6 (junio).

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos de adeudos para el mercado y periodo seleccionados.

**Pasos a seguir:**
- El usuario accede a la página 'Emisión de Recibos de Abastos'.
- Selecciona 'Cruz del Sur' en el campo Oficina.
- Selecciona 'Mercado Abastos' en el campo Mercado.
- Ingresa 2024 en el campo Año.
- Ingresa 6 en el campo Periodo.
- Presiona el botón 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los locales, nombre, descripción, meses adeudados, renta, adeudo, recargos, subtotal y multa. Los totales se muestran al pie de la tabla.

**Datos de prueba:**
{ oficina: 5, mercado: 1, axo: 2024, periodo: 6 }

---

## Caso de Uso 2: Visualización de Requerimientos de un Local

**Descripción:** El usuario desea ver los requerimientos (apremios) asociados a un local específico desde el reporte.

**Precondiciones:**
El usuario ya consultó el reporte y hay al menos un local con requerimientos.

**Pasos a seguir:**
- El usuario hace clic en el botón 'Ver Requerimientos' en la fila de un local.
- Se abre un modal mostrando la lista de requerimientos asociados.

**Resultado esperado:**
El modal muestra una tabla con los folios, importe de multa, importe de gastos, fecha de emisión y observaciones de cada requerimiento.

**Datos de prueba:**
{ id_local: 12345 }

---

## Caso de Uso 3: Consulta de Recargos del Mes

**Descripción:** El sistema debe mostrar los recargos aplicables para un año y mes específico.

**Precondiciones:**
Existen registros de recargos en la tabla ta_12_recargos para el año y mes consultados.

**Pasos a seguir:**
- El frontend solicita los recargos del mes llamando a la acción 'getRecargosMes' con los parámetros axo=2024, mes=6.

**Resultado esperado:**
El backend responde con los datos de recargos para ese año y mes.

**Datos de prueba:**
{ axo: 2024, mes: 6 }

---



## Casos de Prueba

# Casos de Prueba: RptEmisionRbosAbastos

## Caso 1: Consulta exitosa de reporte
- **Entrada:** { action: 'getReportData', params: { oficina: 5, mercado: 1, axo: 2024, periodo: 6 } }
- **Esperado:** Respuesta con success=true, data es un array de locales con campos calculados, sin error.

## Caso 2: Consulta de requerimientos de local
- **Entrada:** { action: 'getRequerimientos', params: { id_local: 12345 } }
- **Esperado:** Respuesta con success=true, data es un array de requerimientos, sin error.

## Caso 3: Consulta de recargos del mes
- **Entrada:** { action: 'getRecargosMes', params: { axo: 2024, mes: 6 } }
- **Esperado:** Respuesta con success=true, data es un array con los recargos del mes.

## Caso 4: Parámetros insuficientes
- **Entrada:** { action: 'getReportData', params: { oficina: 5, mercado: 1 } }
- **Esperado:** success=false, message indica parámetros insuficientes.

## Caso 5: Acción no soportada
- **Entrada:** { action: 'accionInexistente', params: {} }
- **Esperado:** success=false, message indica acción no soportada.



