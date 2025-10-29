# Casos de Uso - EmisionLocales

**Categoría:** Form

## Caso de Uso 1: Emisión de Recibos para un Mercado

**Descripción:** El usuario emite los recibos de renta para todos los locales de un mercado en un periodo determinado.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos sobre la recaudadora y mercado.

**Pasos a seguir:**
1. El usuario accede a la página de Emisión de Recibos.
2. Selecciona la recaudadora y el mercado.
3. Selecciona el año y el periodo (mes).
4. Presiona el botón 'Emisión'.
5. El sistema muestra la lista de recibos generados.

**Resultado esperado:**
Se muestran los recibos generados para todos los locales del mercado seleccionado, con los importes correctos.

**Datos de prueba:**
{ oficina: 2, mercado: 15, axo: 2024, periodo: 6, usuario_id: 1 }

---

## Caso de Uso 2: Grabar Emisión de Recibos

**Descripción:** El usuario graba la emisión de recibos, persistiendo los adeudos en la base de datos.

**Precondiciones:**
Debe haberse realizado previamente la emisión de recibos para el mercado y periodo.

**Pasos a seguir:**
1. El usuario revisa la lista de recibos generados.
2. Presiona el botón 'Grabar'.
3. El sistema ejecuta el SP de grabado y retorna el estado de cada local.

**Resultado esperado:**
Los adeudos quedan registrados en la tabla ta_11_adeudo_local para cada local. Si ya existía, se indica 'ya_existe'.

**Datos de prueba:**
{ oficina: 2, mercado: 15, axo: 2024, periodo: 6, usuario_id: 1 }

---

## Caso de Uso 3: Generar Facturación del Mercado

**Descripción:** El usuario genera la facturación (listado para impresión) de los recibos emitidos.

**Precondiciones:**
Debe haberse realizado la emisión y grabado de recibos.

**Pasos a seguir:**
1. El usuario presiona el botón 'Facturación'.
2. El sistema ejecuta el SP de facturación y retorna los datos tabulares para impresión.

**Resultado esperado:**
Se genera el listado de facturación para el mercado y periodo seleccionado.

**Datos de prueba:**
{ oficina: 2, mercado: 15, axo: 2024, periodo: 6, solo_mercado: true }

---

