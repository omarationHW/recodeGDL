# Casos de Uso - sfrmMetrometers

**Categoría:** Form

## Caso de Uso 1: Consulta de datos generales de un Metrometer

**Descripción:** El usuario ingresa el año y folio de una infracción y visualiza los datos generales asociados.

**Precondiciones:**
El registro existe en la tabla ta14_adicional_mmeters.

**Pasos a seguir:**
1. El usuario accede a la página principal de Metrometers.
2. Ingresa el año (axo) y folio.
3. Presiona 'Buscar'.
4. El sistema consulta la API con eRequest 'getMetrometersByAxoFolio'.
5. Se muestran los datos generales (marca, dirección, motivo).

**Resultado esperado:**
Se muestran correctamente los datos del registro consultado.

**Datos de prueba:**
{ "axo": 2024, "folio": 12345 }

---

## Caso de Uso 2: Visualización de Foto 1 de un Metrometer

**Descripción:** El usuario accede a la página de Foto 1 y visualiza la imagen asociada al registro.

**Precondiciones:**
El registro tiene una URL válida en linkfoto1.

**Pasos a seguir:**
1. El usuario navega a la página de Foto 1 desde la página principal.
2. El sistema consulta la API con eRequest 'getMetrometersPhoto' y photo_number=1.
3. Se muestra la imagen en pantalla.

**Resultado esperado:**
La imagen se visualiza correctamente.

**Datos de prueba:**
{ "axo": 2024, "folio": 12345, "photo_number": 1 }

---

## Caso de Uso 3: Visualización de la ubicación en el mapa

**Descripción:** El usuario accede a la página de mapa y visualiza la ubicación de la infracción en Google Maps.

**Precondiciones:**
El registro tiene coordenadas poslat y poslong válidas.

**Pasos a seguir:**
1. El usuario navega a la página de Mapa desde la página principal.
2. El sistema consulta la API con eRequest 'getMetrometersMapUrl'.
3. Se muestra el mapa estático de Google Maps.

**Resultado esperado:**
El mapa se visualiza correctamente con el marcador en la ubicación indicada.

**Datos de prueba:**
{ "axo": 2024, "folio": 12345 }

---

