# Casos de Uso - Individual

**Categoría:** Form

## Caso de Uso 1: Consulta de Folio Individual Existente

**Descripción:** El usuario consulta un folio individual existente y visualiza todos los datos relacionados.

**Precondiciones:**
El folio existe en la base de datos y el usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta Individual.
2. Ingresa el número de folio, selecciona la aplicación y recaudadora.
3. Presiona 'Buscar'.
4. El sistema muestra los datos generales del folio, historia, periodos y detalle de aplicación.

**Resultado esperado:**
Se muestran correctamente todos los datos del folio, incluyendo historia y periodos.

**Datos de prueba:**
{ "folio": 12345, "aplicacion": 11, "rec": 2 }

---

## Caso de Uso 2: Consulta de Folio Inexistente

**Descripción:** El usuario intenta consultar un folio que no existe.

**Precondiciones:**
El folio no existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta Individual.
2. Ingresa un número de folio inexistente.
3. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el folio no existe.

**Datos de prueba:**
{ "folio": 999999, "aplicacion": 11, "rec": 2 }

---

## Caso de Uso 3: Visualización de Historia y Periodos

**Descripción:** El usuario consulta la historia y periodos de un folio existente.

**Precondiciones:**
El folio existe y tiene historia y periodos asociados.

**Pasos a seguir:**
1. El usuario consulta un folio existente.
2. El sistema muestra la tabla de historia y la tabla de periodos.

**Resultado esperado:**
Las tablas de historia y periodos muestran los registros asociados correctamente.

**Datos de prueba:**
{ "folio": 12345 }

---

