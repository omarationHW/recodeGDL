# Casos de Uso - sfrm_chg_autorizadescto

**Categoría:** Form

## Caso de Uso 1: Consulta de folios históricos por placa

**Descripción:** El usuario ingresa una placa y consulta los folios históricos asociados a esa placa.

**Precondiciones:**
La placa debe existir en la tabla ta14_folios_histo con registros entre 2013-10-01 y 2014-12-31.

**Pasos a seguir:**
1. El usuario accede a la página de Autorización de Descuento.
2. Ingresa la placa 'ABC1234' en el campo correspondiente.
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los folios históricos asociados a la placa ingresada.

**Datos de prueba:**
placa: 'ABC1234'

---

## Caso de Uso 2: Visualización de descuentos otorgados para un folio

**Descripción:** El usuario selecciona un folio de la lista y visualiza los descuentos otorgados asociados.

**Precondiciones:**
Debe existir al menos un folio para la placa y debe haber registros en ta14_folios_free para ese axo y folio.

**Pasos a seguir:**
1. El usuario realiza una búsqueda de folios históricos por placa.
2. Selecciona el folio con axo=2014 y folio=5678.
3. El sistema muestra los descuentos otorgados para ese folio.

**Resultado esperado:**
Se muestra una tabla con los descuentos otorgados (obs, porcentaje, fecha, etc).

**Datos de prueba:**
axo: 2014, folio: 5678

---

## Caso de Uso 3: Cambio de descuento a 'Tesorero'

**Descripción:** El usuario cambia el estado de un descuento otorgado a 'Tesorero'.

**Precondiciones:**
Debe existir un registro en ta14_folios_free con axo=2014 y folio=5678, y obs diferente de 'Tesorero'.

**Pasos a seguir:**
1. El usuario visualiza los descuentos otorgados para un folio.
2. Presiona el botón 'Cambiar a Tesorero' en el descuento deseado.
3. Confirma la acción.
4. El sistema actualiza el campo obs a 'Tesorero' y refresca la tabla.

**Resultado esperado:**
El campo obs del descuento cambia a 'Tesorero' y se muestra un mensaje de éxito.

**Datos de prueba:**
axo: 2014, folio: 5678

---

