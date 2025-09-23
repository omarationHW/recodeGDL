# Casos de Uso - CMultFolio

**Categoría:** Form

## Caso de Uso 1: Consulta de Folios por Rango

**Descripción:** El usuario desea consultar los folios de requerimiento para una recaudadora y módulo específicos, ingresando un folio inicial.

**Precondiciones:**
El usuario está autenticado y tiene acceso al sistema. Existen folios en la base de datos para la recaudadora y módulo seleccionados.

**Pasos a seguir:**
1. El usuario accede a la página 'Consulta Múltiple por Folio'.
2. Selecciona la aplicación 'Mercados'.
3. Selecciona la recaudadora '2'.
4. Ingresa el folio '1000'.
5. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los folios del 1000 al 1100 (o hasta el último disponible) para la recaudadora y módulo seleccionados.

**Datos de prueba:**
{ "modulo": 11, "zona": 2, "folio": 1000 }

---

## Caso de Uso 2: Visualización de Detalle Individual de Folio

**Descripción:** El usuario desea ver el detalle completo de un folio específico.

**Precondiciones:**
El usuario ya realizó una búsqueda y tiene a la vista la lista de folios.

**Pasos a seguir:**
1. El usuario hace clic en 'Ver Detalle' en la fila del folio con id_control=12345.

**Resultado esperado:**
Se muestra el detalle completo del folio, incluyendo todos los campos y relaciones.

**Datos de prueba:**
{ "id_control": 12345 }

---

## Caso de Uso 3: Carga de Recaudadoras para Selección

**Descripción:** El usuario necesita seleccionar una recaudadora antes de buscar folios.

**Precondiciones:**
El usuario accede a la página de consulta.

**Pasos a seguir:**
1. El frontend realiza una petición para obtener la lista de recaudadoras.
2. El usuario selecciona una recaudadora de la lista desplegable.

**Resultado esperado:**
La lista de recaudadoras se carga correctamente y permite la selección.

**Datos de prueba:**
{}

---

