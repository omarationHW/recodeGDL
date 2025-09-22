# Casos de Uso - DatosRequerimientos

**Categoría:** Form

## Caso de Uso 1: Consulta de requerimiento existente por folio

**Descripción:** El usuario consulta un requerimiento existente ingresando el ID del local, el módulo y el folio.

**Precondiciones:**
El usuario está autenticado y existe un requerimiento con los datos proporcionados.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Requerimientos.
2. Ingresa el ID Local, Módulo y Folio.
3. Presiona 'Buscar'.
4. El sistema consulta los datos y muestra la información del local, mercado, requerimiento y periodos.

**Resultado esperado:**
Se muestran correctamente todos los datos del local, mercado, requerimiento y periodos asociados.

**Datos de prueba:**
{ "id_local": 1001, "modulo": 11, "folio": 12345 }

---

## Caso de Uso 2: Consulta con folio inexistente

**Descripción:** El usuario intenta consultar un requerimiento con un folio que no existe.

**Precondiciones:**
El usuario está autenticado. El folio no existe para el local y módulo indicados.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Requerimientos.
2. Ingresa un ID Local, Módulo y Folio inexistentes.
3. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el requerimiento no fue encontrado.

**Datos de prueba:**
{ "id_local": 1001, "modulo": 11, "folio": 99999 }

---

## Caso de Uso 3: Validación de campos obligatorios

**Descripción:** El usuario intenta consultar sin ingresar todos los campos requeridos.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Requerimientos.
2. Deja vacío el campo 'folio'.
3. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el campo 'folio' es requerido.

**Datos de prueba:**
{ "id_local": 1001, "modulo": 11, "folio": "" }

---

