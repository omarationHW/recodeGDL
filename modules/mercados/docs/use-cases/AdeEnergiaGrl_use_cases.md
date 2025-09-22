# Casos de Uso - AdeEnergiaGrl

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos de Energía por Mercado

**Descripción:** El usuario desea consultar todos los adeudos de energía eléctrica del Mercado 5 de la Recaudadora 1 hasta junio de 2024.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos de adeudos en la base.

**Pasos a seguir:**
1. Acceder a la página de Adeudos Generales de Energía.
2. Seleccionar '1' en el campo Oficina (Recaudadora).
3. Seleccionar '5' en el campo Mercado.
4. Ingresar '2024' en Año Hasta y '6' en Mes Hasta.
5. Presionar el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los adeudos de energía eléctrica del Mercado 5 de la Recaudadora 1 hasta junio de 2024, incluyendo nombre, cuota, adeudo y periodos.

**Datos de prueba:**
{ "id_rec": 1, "num_mercado_nvo": 5, "axo": 2024, "mes": 6 }

---

## Caso de Uso 2: Exportación de Adeudos a Excel

**Descripción:** El usuario desea exportar el listado de adeudos consultado a un archivo Excel.

**Precondiciones:**
El usuario ya realizó una consulta y hay datos en la tabla.

**Pasos a seguir:**
1. Realizar la consulta como en el caso anterior.
2. Presionar el botón 'Excel'.

**Resultado esperado:**
Se descarga un archivo Excel con los mismos datos mostrados en la tabla.

**Datos de prueba:**
N/A (depende de la implementación de exportación)

---

## Caso de Uso 3: Validación de Parámetros Faltantes

**Descripción:** El usuario intenta buscar sin seleccionar recaudadora o mercado.

**Precondiciones:**
El usuario accede a la página pero no selecciona todos los filtros.

**Pasos a seguir:**
1. Acceder a la página.
2. No seleccionar recaudadora o mercado.
3. Presionar 'Buscar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que debe seleccionar recaudadora, mercado, año y mes.

**Datos de prueba:**
{ "id_rec": null, "num_mercado_nvo": null, "axo": 2024, "mes": 6 }

---

