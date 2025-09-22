# Casos de Uso - ReportAutor

**Categoría:** Form

## Caso de Uso 1: Consulta de Reporte de Descuentos Autorizados

**Descripción:** El usuario desea obtener el reporte de descuentos autorizados para una oficina recaudadora y un rango de fechas.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte de Descuentos Autorizados.
2. Selecciona la oficina recaudadora de la lista desplegable.
3. Selecciona la fecha inicial y final del rango.
4. Presiona el botón 'Generar Reporte'.
5. El sistema muestra la tabla con los resultados.

**Resultado esperado:**
Se muestra una tabla con los folios, importes, porcentaje autorizado, usuario, datos de registro, vigencia, y demás columnas relevantes.

**Datos de prueba:**
rec: 1, fecha1: '2024-01-01', fecha2: '2024-01-31'

---

## Caso de Uso 2: Cancelación de Autorizados Vigentes

**Descripción:** El usuario desea cancelar los descuentos autorizados vigentes para un folio específico.

**Precondiciones:**
El usuario tiene permisos de administrador.

**Pasos a seguir:**
1. El usuario identifica el folio y fecha de alta del autorizado a cancelar.
2. Envía una petición a la API con acción 'cancelAutorizados' y los parámetros correspondientes.
3. El sistema ejecuta el stored procedure y actualiza el estado.

**Resultado esperado:**
El registro de autorizado queda con estado=2 y fecha_baja actual.

**Datos de prueba:**
id_control: 12345, fecha_alta: '2024-01-15'

---

## Caso de Uso 3: Actualización de Porcentaje de Multa a 100%

**Descripción:** El usuario requiere actualizar el porcentaje de multa a 100% para un folio.

**Precondiciones:**
El usuario tiene permisos de supervisor.

**Pasos a seguir:**
1. El usuario identifica el id_control del folio.
2. Envía una petición a la API con acción 'set100Porciento' y el parámetro id_control.
3. El sistema ejecuta el stored procedure y actualiza el porcentaje.

**Resultado esperado:**
El campo porcentaje_multa del folio queda en 100.

**Datos de prueba:**
id_control: 12345

---

