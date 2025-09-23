# Casos de Uso - dictamenfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de Dictamen de Anuncio Existente

**Descripción:** El usuario ingresa el número de anuncio existente y obtiene todos los datos del dictamen.

**Precondiciones:**
El anuncio existe en la base de datos y está vigente.

**Pasos a seguir:**
- El usuario accede a la página Dictamen de Anuncio.
- Ingresa el número de anuncio (ej: 12345).
- Selecciona el tipo de dictamen (Procedente o Improcedente).
- Presiona 'Buscar'.

**Resultado esperado:**
Se muestran todos los datos del anuncio, incluyendo propietario, ubicación, descripción, medidas, etc.

**Datos de prueba:**
{ "anuncio": 12345 }

---

## Caso de Uso 2: Intento de Consulta con Anuncio Inexistente

**Descripción:** El usuario ingresa un número de anuncio que no existe o no está vigente.

**Precondiciones:**
El anuncio no existe o no está vigente.

**Pasos a seguir:**
- El usuario accede a la página Dictamen de Anuncio.
- Ingresa el número de anuncio (ej: 99999).
- Presiona 'Buscar'.

**Resultado esperado:**
Se muestra un mensaje de error: 'No se encontró el anuncio'.

**Datos de prueba:**
{ "anuncio": 99999 }

---

## Caso de Uso 3: Generación de Reporte PDF de Dictamen

**Descripción:** El usuario consulta un anuncio existente y solicita la impresión del dictamen.

**Precondiciones:**
El anuncio existe y los datos han sido cargados.

**Pasos a seguir:**
- El usuario busca un anuncio válido.
- Se muestran los datos.
- El usuario presiona 'Imprimir Dictamen'.

**Resultado esperado:**
Se genera un enlace para descargar el PDF del dictamen.

**Datos de prueba:**
{ "anuncio": 12345, "tipo": 1 }

---

