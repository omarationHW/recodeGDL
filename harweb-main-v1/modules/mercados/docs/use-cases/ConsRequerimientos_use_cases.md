# Casos de Uso - ConsRequerimientos

**Categoría:** Form

## Caso de Uso 1: Consulta de Requerimientos de un Local Existente

**Descripción:** El usuario desea consultar los requerimientos asociados a un local específico en un mercado.

**Precondiciones:**
El usuario tiene acceso al sistema y existen mercados y locales cargados.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Requerimientos.
2. Selecciona un mercado de la lista desplegable.
3. Ingresa la sección, número de local, letra y bloque (si aplica).
4. Presiona 'Buscar'.
5. Selecciona el local de la lista de resultados.
6. Visualiza los requerimientos asociados al local.

**Resultado esperado:**
Se muestran los requerimientos del local seleccionado, incluyendo folio, fecha de emisión, vigencia, diligencia, importes y acciones.

**Datos de prueba:**
Mercado: 1-5-2-ABASTOS
Sección: SS
Local: 123
Letra: A
Bloque: 1

---

## Caso de Uso 2: Visualización de Periodos de un Requerimiento

**Descripción:** El usuario desea ver los periodos asociados a un requerimiento específico.

**Precondiciones:**
El usuario ya ha consultado los requerimientos de un local.

**Pasos a seguir:**
1. En la tabla de requerimientos, el usuario presiona 'Ver Periodos' en el requerimiento deseado.
2. El sistema muestra una tabla con los periodos, importes y recargos.

**Resultado esperado:**
Se listan los periodos asociados al requerimiento, con año, mes, importe y recargos.

**Datos de prueba:**
Requerimiento con folio: 456

---

## Caso de Uso 3: Error al Buscar Local Inexistente

**Descripción:** El usuario intenta buscar un local que no existe en el mercado seleccionado.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Selecciona un mercado válido.
2. Ingresa una sección y número de local inexistente.
3. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que no existe el local digitado.

**Datos de prueba:**
Mercado: 1-5-2-ABASTOS
Sección: XX
Local: 99999
Letra: Z
Bloque: 9

---

