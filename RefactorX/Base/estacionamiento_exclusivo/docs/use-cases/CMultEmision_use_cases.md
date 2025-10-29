# Casos de Uso - CMultEmision

**Categoría:** Form

## Caso de Uso 1: Consulta de Folios por Fecha de Emisión

**Descripción:** El usuario desea consultar todos los folios emitidos en una fecha específica para una recaudadora y aplicación determinada.

**Precondiciones:**
El usuario tiene acceso al sistema y existen folios emitidos en la fecha seleccionada.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta Múltiple por Fecha de Emisión.
2. Selecciona la recaudadora (zona) deseada.
3. Selecciona la aplicación (módulo), por ejemplo, Mercados.
4. Selecciona la fecha de emisión.
5. Hace clic en 'Buscar'.
6. El sistema muestra la lista de folios encontrados.

**Resultado esperado:**
Se muestra una tabla con los folios emitidos en la fecha, con sus datos principales.

**Datos de prueba:**
modulo: 11, zona: 2, fecha_emision: '2024-06-01'

---

## Caso de Uso 2: Visualización de Detalle de Folio

**Descripción:** El usuario desea ver el detalle completo de un folio listado en la búsqueda.

**Precondiciones:**
El usuario ya realizó una búsqueda y hay folios listados.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Ver Detalle' de un folio.
2. El sistema consulta el detalle del folio por id_control.
3. Se muestra el detalle completo en pantalla.

**Resultado esperado:**
Se muestra toda la información del folio seleccionado.

**Datos de prueba:**
id_control: 12345

---

## Caso de Uso 3: Validación de Parámetros Obligatorios

**Descripción:** El usuario intenta buscar folios sin seleccionar todos los parámetros requeridos.

**Precondiciones:**
El usuario accede a la página pero deja algún campo vacío.

**Pasos a seguir:**
1. El usuario deja vacío el campo 'fecha de emisión'.
2. Hace clic en 'Buscar'.
3. El sistema valida los parámetros.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que falta un parámetro obligatorio.

**Datos de prueba:**
modulo: 11, zona: 2, fecha_emision: ''

---

