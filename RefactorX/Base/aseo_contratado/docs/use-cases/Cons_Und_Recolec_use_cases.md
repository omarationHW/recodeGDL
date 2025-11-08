# Casos de Uso - Cons_Und_Recolec

**Categoría:** Form

## Caso de Uso 1: Consulta básica de Unidades de Recolección por ejercicio

**Descripción:** El usuario consulta todas las unidades de recolección del ejercicio actual, ordenadas por número de control.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en la tabla ta_16_unidades para el ejercicio actual.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Unidades de Recolección.
2. Selecciona el ejercicio actual (por defecto).
3. Selecciona 'Control' como criterio de orden.
4. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra la tabla con todas las unidades de recolección del ejercicio actual, ordenadas por número de control.

**Datos de prueba:**
Ejercicio: 2024, Orden: ctrol_recolec

---

## Caso de Uso 2: Exportar listado de Unidades de Recolección a Excel

**Descripción:** El usuario exporta el listado filtrado a un archivo Excel (CSV).

**Precondiciones:**
El usuario ya realizó una consulta y hay datos en pantalla.

**Pasos a seguir:**
1. El usuario presiona el botón 'Exportar Excel'.
2. El sistema genera y descarga un archivo CSV con los datos mostrados.

**Resultado esperado:**
El archivo CSV contiene las mismas filas y columnas que la tabla mostrada.

**Datos de prueba:**
Ejercicio: 2024, Orden: descripcion

---

## Caso de Uso 3: Consulta por descripción

**Descripción:** El usuario consulta las unidades de recolección ordenadas por descripción.

**Precondiciones:**
El usuario tiene acceso y existen varias unidades con diferentes descripciones.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Selecciona el ejercicio deseado.
3. Selecciona 'Descripción' como criterio de orden.
4. Presiona 'Buscar'.

**Resultado esperado:**
La tabla muestra las unidades ordenadas alfabéticamente por descripción.

**Datos de prueba:**
Ejercicio: 2023, Orden: descripcion

---

