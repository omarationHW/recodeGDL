# Casos de Uso - AdeudosLocales

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos de Mercados por Año y Oficina

**Descripción:** El usuario consulta el listado de adeudos de mercados para un año, oficina y periodo específicos.

**Precondiciones:**
El usuario está autenticado y tiene permisos para consultar adeudos.

**Pasos a seguir:**
1. El usuario accede a la página 'Adeudos de Mercados'.
2. Selecciona el año (por ejemplo, 2023), la oficina (por ejemplo, 2) y el periodo (por ejemplo, 5).
3. Hace clic en 'Consultar'.
4. El sistema muestra la tabla con los adeudos correspondientes.

**Resultado esperado:**
Se muestra una tabla con los adeudos de locales para los parámetros seleccionados, incluyendo control, rec, merc, cat, sección, local, letra, bloque, nombre, superficie, renta, adeudo y meses de adeudo.

**Datos de prueba:**
{ "axo": 2023, "oficina": 2, "periodo": 5 }

---

## Caso de Uso 2: Exportación de Adeudos a Excel

**Descripción:** El usuario exporta el listado de adeudos consultados a un archivo Excel.

**Precondiciones:**
El usuario ya realizó una consulta de adeudos y hay datos en pantalla.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Exportar Excel'.
2. El sistema genera y descarga un archivo Excel con los datos mostrados.

**Resultado esperado:**
Se descarga un archivo Excel con el listado de adeudos.

**Datos de prueba:**
Debe haber datos consultados previamente.

---

## Caso de Uso 3: Impresión de Reporte de Adeudos

**Descripción:** El usuario imprime el reporte de adeudos de mercados.

**Precondiciones:**
El usuario ya realizó una consulta de adeudos y hay datos en pantalla.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Imprimir'.
2. El sistema genera un PDF o abre una ventana de impresión con el reporte.

**Resultado esperado:**
Se muestra el reporte listo para imprimir o se descarga un PDF.

**Datos de prueba:**
Debe haber datos consultados previamente.

---

