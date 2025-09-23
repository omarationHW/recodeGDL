# Casos de Uso - BusquedaActividadFrm

**Categoría:** Form

## Caso de Uso 1: Búsqueda de actividades por SCIAN y descripción parcial

**Descripción:** El usuario desea buscar actividades económicas cuyo SCIAN es 561110 y la descripción contiene la palabra 'RESTAURANTE'.

**Precondiciones:**
El usuario conoce el código SCIAN y tiene acceso a la página de búsqueda.

**Pasos a seguir:**
1. Ingresar a la página de búsqueda de actividades.
2. El sistema recibe el parámetro scian=561110 (por query string).
3. El usuario escribe 'RESTAURANTE' en el campo de descripción.
4. El sistema consulta el API y muestra las actividades que coinciden.

**Resultado esperado:**
Se muestran todas las actividades vigentes con SCIAN 561110 y descripción que contiene 'RESTAURANTE', junto con su costo y refrendo.

**Datos de prueba:**
{ "scian": 561110, "descripcion": "RESTAURANTE" }

---

## Caso de Uso 2: Selección de actividad y confirmación

**Descripción:** El usuario selecciona una actividad de la lista y confirma su selección.

**Precondiciones:**
La búsqueda previa ha devuelto al menos una actividad.

**Pasos a seguir:**
1. El usuario hace clic en una fila de la tabla.
2. El sistema resalta la fila seleccionada.
3. El usuario presiona el botón 'Aceptar'.

**Resultado esperado:**
El sistema emite un evento o realiza una acción con la actividad seleccionada (por ejemplo, mostrar un mensaje o navegar a otra página).

**Datos de prueba:**
Actividad seleccionada: id_giro=5010, cod_giro=561110, descripcion='RESTAURANTE BAR', costo=1500

---

## Caso de Uso 3: Búsqueda sin resultados

**Descripción:** El usuario realiza una búsqueda con una descripción que no existe.

**Precondiciones:**
El usuario está en la página de búsqueda y el SCIAN es válido.

**Pasos a seguir:**
1. El usuario ingresa una descripción inexistente, por ejemplo 'ZZZZZZ'.
2. El sistema consulta el API.

**Resultado esperado:**
La tabla muestra el mensaje 'No se encontraron actividades.'

**Datos de prueba:**
{ "scian": 561110, "descripcion": "ZZZZZZ" }

---

