# Casos de Uso - cambiaPorcentajeCondu

**Categoría:** Form

## Caso de Uso 1: Consulta de propietarios de una cuenta

**Descripción:** El usuario desea visualizar la lista de condueños y sus porcentajes para una cuenta catastral específica.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página de cambio de porcentajes.
2. El sistema solicita los parámetros cvecuenta y cveregprop (por query o selección previa).
3. El frontend envía eRequest con action 'getPropietarios'.
4. El backend responde con la lista de propietarios.

**Resultado esperado:**
Se muestra la tabla con los propietarios, porcentajes, encabeza y calidad.

**Datos de prueba:**
{ "cvecuenta": 12345, "cveregprop": 1 }

---

## Caso de Uso 2: Actualización exitosa de porcentajes

**Descripción:** El usuario edita los porcentajes y calidades, asegurando que el total sea 100% y solo uno encabece.

**Precondiciones:**
El usuario está autenticado y la cuenta tiene al menos dos propietarios.

**Pasos a seguir:**
1. El usuario modifica los porcentajes y calidades en la tabla.
2. El usuario pulsa 'Actualizar'.
3. El frontend valida y envía eRequest con action 'updatePorcentajes'.
4. El backend valida reglas y actualiza los datos.

**Resultado esperado:**
Se actualizan los porcentajes y se muestra mensaje de éxito.

**Datos de prueba:**
{ "cvecuenta": 12345, "cveregprop": 1, "propietarios": [ { "cvecont": 1, "porcentaje": 60, "encabeza": "S", "descripcion": "PROPIETARIO" }, { "cvecont": 2, "porcentaje": 40, "encabeza": "N", "descripcion": "COPROPIETARIO" } ] }

---

## Caso de Uso 3: Error por suma de porcentajes incorrecta

**Descripción:** El usuario intenta guardar porcentajes que no suman 100%.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario edita los porcentajes para que sumen 90%.
2. Pulsa 'Actualizar'.
3. El backend valida y detecta el error.

**Resultado esperado:**
Se muestra mensaje de error indicando que el total debe ser 100%.

**Datos de prueba:**
{ "cvecuenta": 12345, "cveregprop": 1, "propietarios": [ { "cvecont": 1, "porcentaje": 50, "encabeza": "S", "descripcion": "PROPIETARIO" }, { "cvecont": 2, "porcentaje": 40, "encabeza": "N", "descripcion": "COPROPIETARIO" } ] }

---

