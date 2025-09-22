# Casos de Uso - Individual_Folio

**Categoría:** Form

## Caso de Uso 1: Consulta de Folio Existente

**Descripción:** El usuario desea consultar un folio de apremios existente para visualizar su información, historia y periodos.

**Precondiciones:**
El folio existe en la base de datos y el usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta por Folio de Apremios.
2. Selecciona la aplicación 'Mercados' y la recaudadora '1'.
3. Ingresa el folio '12345' y presiona 'Buscar'.
4. El sistema muestra los datos del folio, la historia y los periodos asociados.

**Resultado esperado:**
Se visualizan correctamente los datos del folio, su historia y periodos.

**Datos de prueba:**
{ "modulo": 11, "folio": 12345, "recaudadora": 1 }

---

## Caso de Uso 2: Consulta de Folio Inexistente

**Descripción:** El usuario intenta consultar un folio que no existe.

**Precondiciones:**
El folio no existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta por Folio de Apremios.
2. Selecciona la aplicación 'Aseo' y la recaudadora '2'.
3. Ingresa el folio '99999' y presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que no existe registro con esos datos.

**Datos de prueba:**
{ "modulo": 16, "folio": 99999, "recaudadora": 2 }

---

## Caso de Uso 3: Visualización de Historia y Periodos

**Descripción:** El usuario consulta un folio y revisa la historia y los periodos asociados.

**Precondiciones:**
El folio existe y tiene historia y periodos registrados.

**Pasos a seguir:**
1. El usuario consulta el folio '54321' en aplicación 'Estacionamientos Públicos', recaudadora '3'.
2. El sistema muestra los datos principales.
3. El usuario revisa las tablas de historia y periodos.

**Resultado esperado:**
La historia y los periodos se muestran correctamente en tablas separadas.

**Datos de prueba:**
{ "modulo": 24, "folio": 54321, "recaudadora": 3 }

---

