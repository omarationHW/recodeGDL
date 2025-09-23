# Casos de Uso - Cons_Zonas

**Categoría:** Form

## Caso de Uso 1: Consulta básica de zonas ordenadas por Control

**Descripción:** El usuario accede a la página de Consulta de Zonas y visualiza la lista ordenada por el campo Control.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario navega a la página 'Consulta de Zonas'.
2. El sistema muestra la tabla de zonas ordenada por 'Control'.
3. El usuario visualiza los datos correctamente.

**Resultado esperado:**
La tabla muestra todas las zonas ordenadas por el campo 'Control'.

**Datos de prueba:**
Tabla ta_16_zonas con al menos 3 registros diferentes.

---

## Caso de Uso 2: Cambio de orden a 'Descripción'

**Descripción:** El usuario selecciona la opción de ordenar por 'Descripción' y la tabla se actualiza.

**Precondiciones:**
El usuario está en la página de Consulta de Zonas.

**Pasos a seguir:**
1. El usuario selecciona el radio button 'Descripción'.
2. El sistema envía la petición al backend con el parámetro order='descripcion'.
3. El sistema muestra la tabla ordenada por 'Descripción'.

**Resultado esperado:**
La tabla se reordena correctamente por el campo 'Descripción'.

**Datos de prueba:**
Registros con descripciones distintas y fácilmente ordenables alfabéticamente.

---

## Caso de Uso 3: Exportar a Excel (CSV)

**Descripción:** El usuario exporta la tabla de zonas a un archivo Excel-compatible (CSV).

**Precondiciones:**
El usuario visualiza la tabla de zonas.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Exportar Excel'.
2. El sistema descarga un archivo CSV con los datos actuales de la tabla.

**Resultado esperado:**
El archivo CSV contiene los mismos datos que la tabla y puede abrirse en Excel.

**Datos de prueba:**
Cualquier conjunto de datos en la tabla ta_16_zonas.

---

