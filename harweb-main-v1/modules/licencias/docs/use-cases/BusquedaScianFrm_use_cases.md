# Casos de Uso - BusquedaScianFrm

**Categoría:** Form

## Caso de Uso 1: Búsqueda de giros por descripción parcial

**Descripción:** El usuario desea buscar todos los giros cuyo nombre contenga la palabra 'RESTAURANTE'.

**Precondiciones:**
La tabla c_scian contiene registros vigentes con descripciones variadas.

**Pasos a seguir:**
1. El usuario accede a la página de búsqueda de giros.
2. Escribe 'RESTAURANTE' en el campo de descripción.
3. El sistema muestra todos los registros cuyo campo descripción contiene 'RESTAURANTE'.

**Resultado esperado:**
Se listan todos los giros vigentes que contienen 'RESTAURANTE' en la descripción.

**Datos de prueba:**
descripcion = 'RESTAURANTE'

---

## Caso de Uso 2: Búsqueda de giros por código SCIAN

**Descripción:** El usuario conoce el código SCIAN y desea buscarlo directamente.

**Precondiciones:**
La tabla c_scian contiene el código 722511.

**Pasos a seguir:**
1. El usuario accede a la página de búsqueda de giros.
2. Escribe '722511' en el campo de descripción.
3. El sistema muestra el registro con código_scian 722511.

**Resultado esperado:**
Se muestra el giro con código_scian 722511.

**Datos de prueba:**
descripcion = '722511'

---

## Caso de Uso 3: Búsqueda sin filtro (todos los vigentes)

**Descripción:** El usuario desea ver todos los giros vigentes sin aplicar ningún filtro.

**Precondiciones:**
Existen registros vigentes en la tabla c_scian.

**Pasos a seguir:**
1. El usuario accede a la página de búsqueda de giros.
2. Deja el campo de descripción vacío.
3. El sistema muestra todos los registros vigentes.

**Resultado esperado:**
Se listan todos los giros vigentes.

**Datos de prueba:**
descripcion = ''

---

