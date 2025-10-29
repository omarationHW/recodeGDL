# Casos de Uso - ZonaAnuncio

**Categoría:** Form

## Caso de Uso 1: Registrar zona para un anuncio nuevo

**Descripción:** El usuario desea asignar zona, subzona y recaudadora a un anuncio que aún no tiene registro en anuncios_zona.

**Precondiciones:**
El anuncio existe en la tabla anuncios y no tiene registro en anuncios_zona.

**Pasos a seguir:**
1. El usuario navega a la página de Zona de Anuncio para el anuncio.
2. El sistema carga los catálogos de zonas, subzonas y recaudadoras.
3. El usuario selecciona la zona, subzona y recaudadora deseada.
4. El usuario presiona 'Guardar'.
5. El sistema envía la acción 'zonaanuncio.create' con los datos.
6. El backend crea el registro y responde éxito.

**Resultado esperado:**
El registro se crea correctamente y el usuario ve un mensaje de éxito.

**Datos de prueba:**
{ "anuncio": 1001, "zona": 2, "subzona": 5, "recaud": 3 }

---

## Caso de Uso 2: Actualizar zona de un anuncio existente

**Descripción:** El usuario necesita modificar la zona, subzona o recaudadora de un anuncio ya registrado.

**Precondiciones:**
El anuncio tiene un registro existente en anuncios_zona.

**Pasos a seguir:**
1. El usuario navega a la página de Zona de Anuncio para el anuncio.
2. El sistema carga los datos actuales y catálogos.
3. El usuario cambia la zona, subzona o recaudadora.
4. El usuario presiona 'Guardar'.
5. El sistema envía la acción 'zonaanuncio.update' con los datos.
6. El backend actualiza el registro y responde éxito.

**Resultado esperado:**
El registro se actualiza correctamente y el usuario ve un mensaje de éxito.

**Datos de prueba:**
{ "anuncio": 1001, "zona": 3, "subzona": 7, "recaud": 2 }

---

## Caso de Uso 3: Eliminar zona de un anuncio

**Descripción:** El usuario desea eliminar la asignación de zona/subzona/recaudadora de un anuncio.

**Precondiciones:**
El anuncio tiene un registro en anuncios_zona.

**Pasos a seguir:**
1. El usuario accede a la página de Zona de Anuncio para el anuncio.
2. El usuario presiona el botón de eliminar.
3. El sistema envía la acción 'zonaanuncio.delete' con el id del anuncio.
4. El backend elimina el registro y responde éxito.

**Resultado esperado:**
El registro se elimina correctamente y el usuario ve un mensaje de éxito.

**Datos de prueba:**
{ "anuncio": 1001 }

---

