# Casos de Uso - ZonaLicencia

**Categoría:** Form

## Caso de Uso 1: Consulta de Zona/Subzona/Recaudadora de una Licencia

**Descripción:** El usuario desea consultar la zona, subzona y recaudadora asociada a una licencia específica.

**Precondiciones:**
El usuario está autenticado y conoce el número de licencia.

**Pasos a seguir:**
1. El usuario accede a la página de Zona de Licencia.
2. Ingresa el número de licencia en el campo correspondiente.
3. El sistema consulta los datos de la licencia y su zona/subzona/recaudadora actual.
4. El sistema muestra los datos en pantalla.

**Resultado esperado:**
Se muestran los datos actuales de zona, subzona y recaudadora de la licencia.

**Datos de prueba:**
{ "licencia": 123456 }

---

## Caso de Uso 2: Actualización de Zona/Subzona/Recaudadora

**Descripción:** El usuario desea actualizar la zona, subzona y recaudadora de una licencia.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición.

**Pasos a seguir:**
1. El usuario accede a la página de Zona de Licencia.
2. Ingresa el número de licencia y espera a que se carguen los datos.
3. Selecciona una nueva recaudadora, zona y subzona de los combos.
4. Presiona el botón Guardar.
5. El sistema guarda los cambios y muestra mensaje de éxito.

**Resultado esperado:**
La zona, subzona y recaudadora quedan actualizadas en la base de datos.

**Datos de prueba:**
{ "licencia": 123456, "zona": 2, "subzona": 5, "recaud": 3 }

---

## Caso de Uso 3: Validación de Campos Obligatorios

**Descripción:** El usuario intenta guardar sin seleccionar todos los campos requeridos.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página de Zona de Licencia.
2. Ingresa el número de licencia.
3. No selecciona zona, subzona o recaudadora.
4. Presiona Guardar.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que todos los campos son obligatorios.

**Datos de prueba:**
{ "licencia": 123456, "zona": "", "subzona": "", "recaud": "" }

---

