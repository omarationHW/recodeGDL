# Casos de Uso - sQRptCves_Operacion

**Categoría:** Form

## Caso de Uso 1: Visualizar catálogo de claves de operación ordenado por Número de Control

**Descripción:** El usuario accede a la página y visualiza el listado de claves de operación ordenado por el campo 'ctrol_operacion'.

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen registros en la tabla 'ta_16_operacion'.

**Pasos a seguir:**
1. El usuario navega a la página 'Catálogo de Claves de Operación'.
2. Por defecto, la clasificación es 'Número de Control'.
3. La aplicación realiza una petición POST a '/api/execute' con eRequest 'get_operaciones' y opcion=1.
4. El backend ejecuta el SP y retorna los datos ordenados.
5. El frontend muestra la tabla con los datos.

**Resultado esperado:**
El usuario ve la tabla de claves de operación ordenada por 'ctrol_operacion'.

**Datos de prueba:**
Registros de ejemplo en 'ta_16_operacion' con diferentes valores en 'ctrol_operacion'.

---

## Caso de Uso 2: Cambiar clasificación a 'Clave' y visualizar resultados

**Descripción:** El usuario selecciona la opción 'Clave' en el selector de clasificación y la tabla se actualiza.

**Precondiciones:**
El usuario está en la página y existen registros con diferentes 'cve_operacion'.

**Pasos a seguir:**
1. El usuario selecciona 'Clave' en el selector.
2. El frontend envía POST a '/api/execute' con opcion=2.
3. El backend ejecuta el SP y retorna los datos ordenados por 'cve_operacion'.
4. El frontend actualiza la tabla.

**Resultado esperado:**
La tabla muestra los datos ordenados por 'cve_operacion'.

**Datos de prueba:**
Registros con valores variados en 'cve_operacion'.

---

## Caso de Uso 3: Visualizar catálogo ordenado por 'Descripción'

**Descripción:** El usuario selecciona 'Descripción' y la tabla se ordena alfabéticamente por ese campo.

**Precondiciones:**
El usuario está en la página y existen descripciones distintas.

**Pasos a seguir:**
1. El usuario selecciona 'Descripción' en el selector.
2. El frontend envía POST a '/api/execute' con opcion=3.
3. El backend ejecuta el SP y retorna los datos ordenados por 'descripcion'.
4. El frontend muestra la tabla actualizada.

**Resultado esperado:**
La tabla se muestra ordenada alfabéticamente por 'descripcion'.

**Datos de prueba:**
Registros con descripciones variadas.

---

