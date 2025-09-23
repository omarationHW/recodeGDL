# Casos de Uso - sQRptRecaudadoras

**Categoría:** Form

## Caso de Uso 1: Visualizar catálogo de recaudadoras ordenado por número de recaudadora

**Descripción:** El usuario accede a la página de recaudadoras y visualiza la lista ordenada por el número de recaudadora (id_rec).

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen registros en la tabla ta_12_recaudadoras.

**Pasos a seguir:**
1. El usuario navega a la página 'Catálogo de Recaudadoras'.
2. El sistema muestra la tabla ordenada por 'Rec' (id_rec) por defecto.
3. El usuario verifica que los datos estén correctamente ordenados.

**Resultado esperado:**
La tabla muestra todas las recaudadoras ordenadas ascendentemente por id_rec.

**Datos de prueba:**
Registros de ejemplo en ta_12_recaudadoras con diferentes valores de id_rec.

---

## Caso de Uso 2: Cambiar criterio de ordenamiento a 'Nombre'

**Descripción:** El usuario selecciona 'Nombre' en el selector de clasificación y la tabla se actualiza automáticamente.

**Precondiciones:**
El usuario está en la página de recaudadoras y existen registros con diferentes nombres.

**Pasos a seguir:**
1. El usuario selecciona 'Nombre' en el selector de clasificación.
2. El sistema envía la solicitud al backend con opcion=2.
3. El backend devuelve los datos ordenados por recaudadora.
4. La tabla se actualiza mostrando los datos ordenados por nombre.

**Resultado esperado:**
La tabla muestra las recaudadoras ordenadas alfabéticamente por el campo 'recaudadora'.

**Datos de prueba:**
Registros con nombres variados en el campo recaudadora.

---

## Caso de Uso 3: Visualizar recaudadoras ordenadas por sector y recaudadora

**Descripción:** El usuario selecciona 'Sector y Recaudadora' y verifica que la tabla esté agrupada por sector y ordenada por id_rec dentro de cada sector.

**Precondiciones:**
Existen recaudadoras con diferentes valores de sector.

**Pasos a seguir:**
1. El usuario selecciona 'Sector y Recaudadora' en el selector.
2. El sistema envía la solicitud con opcion=4.
3. El backend devuelve los datos ordenados por sector y luego por id_rec.
4. El usuario verifica la agrupación y orden.

**Resultado esperado:**
La tabla muestra las recaudadoras agrupadas por sector y ordenadas por id_rec dentro de cada sector.

**Datos de prueba:**
Registros con sectores 'A', 'B', 'C' y varios id_rec por sector.

---

