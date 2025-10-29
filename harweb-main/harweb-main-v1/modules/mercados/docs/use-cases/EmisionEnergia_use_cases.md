# Casos de Uso - EmisionEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de Emisión de Energía

**Descripción:** El usuario consulta los recibos de energía a emitir para un mercado y periodo específico.

**Precondiciones:**
El usuario está autenticado y existen locales con energía eléctrica en el mercado seleccionado.

**Pasos a seguir:**
1. El usuario accede a la página de Emisión de Energía.
2. Selecciona la recaudadora y el mercado.
3. Selecciona el año y el periodo (mes).
4. Presiona el botón 'Emisión'.
5. El sistema muestra el detalle de la emisión.

**Resultado esperado:**
Se muestra una tabla con los locales, importes y detalles de la emisión de energía.

**Datos de prueba:**
{ oficina: 1, mercado: 1, axo: 2024, periodo: 6 }

---

## Caso de Uso 2: Grabar Emisión de Energía

**Descripción:** El usuario graba la emisión de energía para un mercado y periodo, generando los adeudos correspondientes.

**Precondiciones:**
No existe una emisión previa para ese mercado, año y periodo.

**Pasos a seguir:**
1. El usuario llena el formulario con recaudadora, mercado, año y periodo.
2. Presiona el botón 'Grabar'.
3. El sistema valida que no exista emisión previa.
4. Si no existe, graba los adeudos y muestra mensaje de éxito.

**Resultado esperado:**
Los adeudos de energía se graban correctamente y se muestra un mensaje de confirmación.

**Datos de prueba:**
{ oficina: 1, mercado: 1, axo: 2024, periodo: 6, usuario: 5 }

---

## Caso de Uso 3: Facturación de Emisión de Energía

**Descripción:** El usuario solicita la facturación de la emisión de energía para un mercado y periodo.

**Precondiciones:**
La emisión de energía ya fue grabada para ese mercado, año y periodo.

**Pasos a seguir:**
1. El usuario selecciona recaudadora, mercado, año y periodo.
2. Presiona el botón 'Facturación'.
3. El sistema retorna los datos para la facturación.

**Resultado esperado:**
Se genera la información para la facturación y se muestra mensaje de éxito.

**Datos de prueba:**
{ oficina: 1, mercado: 1, axo: 2024, periodo: 6 }

---

