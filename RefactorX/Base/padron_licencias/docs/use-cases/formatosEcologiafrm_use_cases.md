# Casos de Uso - formatosEcologiafrm

**Categoría:** Form

## Caso de Uso 1: Consulta de trámite por número de trámite

**Descripción:** El usuario ingresa el número de trámite y obtiene el detalle completo, incluyendo propietario, ubicación, actividad y cruce de calles.

**Precondiciones:**
El trámite con el número ingresado existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte de Verificación Técnica.
2. Ingresa el número de trámite en el campo correspondiente.
3. Presiona 'Buscar'.
4. El sistema muestra los datos del trámite y permite ver el detalle y cruce de calles.

**Resultado esperado:**
Se muestra el detalle del trámite, incluyendo propietario, ubicación, actividad y cruce de calles.

**Datos de prueba:**
{ "tramiteId": 12345 }

---

## Caso de Uso 2: Consulta de trámites por fecha de captura

**Descripción:** El usuario selecciona una fecha y obtiene todos los trámites capturados en esa fecha.

**Precondiciones:**
Existen trámites capturados en la fecha seleccionada.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte de Verificación Técnica.
2. Selecciona una fecha en el campo de fecha.
3. El sistema muestra la lista de trámites capturados en esa fecha.

**Resultado esperado:**
Se muestra una tabla con todos los trámites de la fecha seleccionada.

**Datos de prueba:**
{ "fecha": "2024-06-01" }

---

## Caso de Uso 3: Impresión de reporte de verificación técnica

**Descripción:** El usuario selecciona un trámite y elige imprimir el reporte de verificación técnica o de certificado de anuencia.

**Precondiciones:**
El trámite está cargado y seleccionado.

**Pasos a seguir:**
1. El usuario busca y selecciona un trámite.
2. Elige el tipo de reporte a imprimir (verificación técnica o certificado de anuencia).
3. Presiona el botón 'Imprimir'.
4. El sistema simula la impresión del reporte.

**Resultado esperado:**
Se muestra un mensaje de confirmación de impresión del reporte seleccionado.

**Datos de prueba:**
{ "tramiteId": 12345, "tipoReporte": "verifTec" }

---

