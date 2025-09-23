# Casos de Uso - EstadxFolio

**Categoría:** Form

## Caso de Uso 1: Consulta de estadísticas de folios por módulo y recaudadora

**Descripción:** El usuario desea obtener un resumen de folios emitidos, practicados y pagados para un rango de folios en un módulo y recaudadora específicos.

**Precondiciones:**
El usuario está autenticado y tiene permisos para consultar estadísticas.

**Pasos a seguir:**
1. El usuario accede a la página EstadxFolio.
2. Selecciona el módulo 'Mercados'.
3. Selecciona la recaudadora '1'.
4. Ingresa folio desde '1000' y folio hasta '1100'.
5. Hace clic en 'Generar'.

**Resultado esperado:**
Se muestra una tabla con los totales agrupados por vigencia y clave_practicado, incluyendo los importes pagados, gastos, adeudo y recargos.

**Datos de prueba:**
{ "modulo": 11, "rec": 1, "fol1": 1000, "fol2": 1100 }

---

## Caso de Uso 2: Exportar estadísticas a Excel

**Descripción:** El usuario desea exportar los resultados de la consulta a un archivo Excel.

**Precondiciones:**
El usuario ya realizó una consulta exitosa de estadísticas.

**Pasos a seguir:**
1. El usuario visualiza la tabla de resultados.
2. Hace clic en el botón 'Exportar a Excel'.

**Resultado esperado:**
Se descarga un archivo Excel con los datos mostrados en la tabla.

**Datos de prueba:**
Usar los mismos parámetros del caso anterior.

---

## Caso de Uso 3: Validación de rango de folios incorrecto

**Descripción:** El usuario intenta consultar estadísticas ingresando un folio final menor que el folio inicial.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página EstadxFolio.
2. Ingresa folio desde '2000' y folio hasta '1990'.
3. Hace clic en 'Generar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que el folio hasta debe ser mayor o igual al folio desde.

**Datos de prueba:**
{ "modulo": 11, "rec": 1, "fol1": 2000, "fol2": 1990 }

---

