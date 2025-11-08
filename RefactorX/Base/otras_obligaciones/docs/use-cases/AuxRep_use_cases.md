# Casos de Uso - AuxRep

**Categoría:** Form

## Caso de Uso 1: Consulta de Padrón General

**Descripción:** El usuario desea consultar el padrón completo de concesionarios para una tabla específica, sin filtrar por vigencia.

**Precondiciones:**
El usuario tiene acceso al sistema y la tabla existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página AuxRep.
2. Selecciona la tabla deseada (por defecto, tabla 3).
3. Deja la vigencia en 'TODOS'.
4. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra la lista completa de concesionarios para la tabla seleccionada, sin filtrar por vigencia.

**Datos de prueba:**
{ "par_tabla": 3, "par_vigencia": "TODOS" }

---

## Caso de Uso 2: Consulta de Padrón por Vigencia

**Descripción:** El usuario desea consultar el padrón filtrando por una vigencia específica (por ejemplo, 'VIGENTE').

**Precondiciones:**
La tabla tiene registros con diferentes vigencias.

**Pasos a seguir:**
1. El usuario accede a la página AuxRep.
2. Selecciona la tabla deseada.
3. Selecciona la vigencia 'VIGENTE' en el selector.
4. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra la lista de concesionarios cuya vigencia es 'VIGENTE'.

**Datos de prueba:**
{ "par_tabla": 3, "par_vigencia": "VIGENTE" }

---

## Caso de Uso 3: Exportación/Impresión del Padrón

**Descripción:** El usuario desea exportar el padrón filtrado a un archivo CSV para impresión o análisis externo.

**Precondiciones:**
El usuario ya realizó una búsqueda y hay datos en pantalla.

**Pasos a seguir:**
1. El usuario presiona el botón 'Imprimir'.
2. El sistema genera y descarga un archivo CSV con los datos actuales.

**Resultado esperado:**
El archivo CSV contiene las columnas y filas mostradas en pantalla.

**Datos de prueba:**
{ "par_tabla": 3, "par_vigencia": "TODOS" }

---

