# Casos de Uso - PagosLocGrl

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos de un mercado en un rango de fechas

**Descripción:** El usuario desea consultar todos los pagos realizados en el Mercado 5 de la Recaudadora 2 entre el 2024-01-01 y el 2024-03-31.

**Precondiciones:**
El usuario tiene acceso al sistema y existen pagos registrados en ese rango.

**Pasos a seguir:**
1. Accede a la página de Pagos por Mercado.
2. Selecciona la recaudadora '2'.
3. Espera a que se carguen los mercados y selecciona el mercado '5'.
4. Selecciona las fechas desde '2024-01-01' hasta '2024-03-31'.
5. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los pagos realizados en el mercado 5 de la recaudadora 2 en el rango de fechas seleccionado.

**Datos de prueba:**
{ "recaudadora_id": 2, "mercado_id": 5, "fecha_desde": "2024-01-01", "fecha_hasta": "2024-03-31" }

---

## Caso de Uso 2: Exportar pagos a Excel

**Descripción:** El usuario desea exportar a Excel los pagos consultados previamente.

**Precondiciones:**
El usuario ya realizó una consulta y hay resultados en pantalla.

**Pasos a seguir:**
1. Después de ver los resultados de la consulta, presiona el botón 'Exportar a Excel'.

**Resultado esperado:**
Se descarga un archivo Excel con los datos mostrados en la tabla.

**Datos de prueba:**
Usar los mismos parámetros de la consulta anterior.

---

## Caso de Uso 3: Validación de parámetros obligatorios

**Descripción:** El usuario intenta buscar pagos sin seleccionar recaudadora o mercado.

**Precondiciones:**
El usuario accede a la página pero no selecciona todos los filtros.

**Pasos a seguir:**
1. Deja vacío el campo recaudadora o mercado.
2. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que los campos son obligatorios y no realiza la consulta.

**Datos de prueba:**
{ "recaudadora_id": null, "mercado_id": null, "fecha_desde": "2024-01-01", "fecha_hasta": "2024-03-31" }

---

