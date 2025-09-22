# Casos de Uso - RptAdeudosLocales

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos de Locales por Año y Recaudadora

**Descripción:** El usuario consulta el listado de adeudos de locales para un año y recaudadora específicos.

**Precondiciones:**
El usuario está autenticado y tiene permisos para la recaudadora seleccionada.

**Pasos a seguir:**
1. El usuario accede a la página de Adeudos de Locales.
2. Selecciona el año 2024, recaudadora 'Zona Centro', y periodo 6 (junio).
3. Hace clic en 'Consultar'.
4. El sistema muestra el listado de adeudos correspondientes.

**Resultado esperado:**
Se muestra una tabla con los adeudos de locales de la recaudadora 'Zona Centro' para junio 2024.

**Datos de prueba:**
{ axo: 2024, oficina: 1, periodo: 6 }

---

## Caso de Uso 2: Exportación de Adeudos a Excel

**Descripción:** El usuario exporta el listado de adeudos consultado a un archivo Excel.

**Precondiciones:**
El usuario ya realizó una consulta de adeudos y hay resultados en pantalla.

**Pasos a seguir:**
1. El usuario hace clic en 'Exportar Excel'.
2. El sistema genera el archivo y ofrece la descarga.

**Resultado esperado:**
El usuario descarga un archivo Excel con los datos mostrados.

**Datos de prueba:**
Debe existir al menos un registro en la consulta previa.

---

## Caso de Uso 3: Consulta de Meses de Adeudo de un Local

**Descripción:** El usuario consulta los meses de adeudo de un local específico.

**Precondiciones:**
El usuario conoce el ID del local y tiene permisos.

**Pasos a seguir:**
1. El usuario solicita los meses de adeudo para el local ID 1234, año 2024, periodo 6.
2. El sistema retorna la lista de meses y montos adeudados.

**Resultado esperado:**
Se retorna un arreglo con los meses y montos de adeudo del local.

**Datos de prueba:**
{ id_local: 1234, axo: 2024, periodo: 6 }

---

