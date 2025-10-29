# Casos de Uso - Facturacion

**Categoría:** Form

## Caso de Uso 1: Consulta de Facturación de Mercados

**Descripción:** El usuario desea obtener el listado de facturación para el módulo de Mercados, recaudadora 1, folios del 100 al 200.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para la recaudadora 1.

**Pasos a seguir:**
1. El usuario accede a la página de Facturación.
2. Selecciona 'Mercados' como aplicación.
3. Selecciona recaudadora 1.
4. Ingresa Folio Desde: 100 y Folio Hasta: 200.
5. Presiona 'Generar'.

**Resultado esperado:**
Se muestra una tabla con los folios del 100 al 200 del módulo Mercados y recaudadora 1, incluyendo nombre, importes y fecha de emisión.

**Datos de prueba:**
{ "modulo": 11, "rec": 1, "fol1": 100, "fol2": 200 }

---

## Caso de Uso 2: Validación de Rango de Folios Incorrecto

**Descripción:** El usuario intenta consultar facturación con Folio Desde mayor que Folio Hasta.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Accede a la página de Facturación.
2. Selecciona cualquier aplicación y recaudadora.
3. Ingresa Folio Desde: 300 y Folio Hasta: 200.
4. Presiona 'Generar'.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'El Folio Desde no puede ser mayor que el Folio Hasta'.

**Datos de prueba:**
{ "modulo": 11, "rec": 1, "fol1": 300, "fol2": 200 }

---

## Caso de Uso 3: Exportación de Resultados a Excel

**Descripción:** El usuario desea exportar el listado de facturación a Excel.

**Precondiciones:**
El usuario ya realizó una consulta exitosa y hay resultados en pantalla.

**Pasos a seguir:**
1. Realiza una consulta de facturación válida.
2. Presiona el botón 'Exportar a Excel'.

**Resultado esperado:**
El sistema descarga un archivo Excel con los datos mostrados en la tabla.

**Datos de prueba:**
{ "modulo": 16, "rec": 2, "fol1": 10, "fol2": 20 }

---

