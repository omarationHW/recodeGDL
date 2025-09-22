# Casos de Uso - RptLista_mercados

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos de Mercados por Rango de Mercados

**Descripción:** El usuario desea obtener el listado de adeudos de todos los locales de los mercados 1 al 2 de la oficina 1, sin filtrar por sección.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos de adeudos en los mercados 1 y 2.

**Pasos a seguir:**
1. Ingresar a la página 'Listado de Adeudos de Mercados'.
2. Ingresar '1' en Oficina.
3. Ingresar '1' en Mercado Inicial y '2' en Mercado Final.
4. Ingresar '1' en Local Inicial y '9999' en Local Final.
5. Dejar Sección en 'todas'.
6. Presionar 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con todos los adeudos de los mercados 1 y 2, incluyendo cálculos de recargos y gastos.

**Datos de prueba:**
{ "vofna": 1, "vmerc1": 1, "vmerc2": 2, "vlocal1": 1, "vlocal2": 9999, "vsecc": "todas" }

---

## Caso de Uso 2: Consulta de Adeudos Filtrando por Sección

**Descripción:** El usuario desea ver solo los adeudos de la sección 'A' del mercado 1.

**Precondiciones:**
Existen locales en la sección 'A' del mercado 1 con adeudos.

**Pasos a seguir:**
1. Ingresar a la página 'Listado de Adeudos de Mercados'.
2. Ingresar '1' en Oficina.
3. Ingresar '1' en Mercado Inicial y '1' en Mercado Final.
4. Ingresar '1' en Local Inicial y '9999' en Local Final.
5. Escribir 'A' en Sección.
6. Presionar 'Consultar'.

**Resultado esperado:**
Se muestran solo los adeudos de la sección 'A' del mercado 1.

**Datos de prueba:**
{ "vofna": 1, "vmerc1": 1, "vmerc2": 1, "vlocal1": 1, "vlocal2": 9999, "vsecc": "A" }

---

## Caso de Uso 3: Exportación de Resultados a CSV

**Descripción:** El usuario consulta el reporte y exporta los resultados a un archivo CSV.

**Precondiciones:**
El usuario ya realizó una consulta y hay resultados en pantalla.

**Pasos a seguir:**
1. Realizar una consulta válida.
2. Hacer clic en el botón 'Exportar a CSV'.

**Resultado esperado:**
Se descarga un archivo CSV con los datos mostrados en la tabla.

**Datos de prueba:**
Cualquier consulta válida con resultados.

---

