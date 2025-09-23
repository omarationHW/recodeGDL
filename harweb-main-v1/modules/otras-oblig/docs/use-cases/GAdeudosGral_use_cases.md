# Casos de Uso - GAdeudosGral

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos Generales Anualizados - Periodo Actual

**Descripción:** El usuario desea consultar el reporte general de adeudos anualizados para el periodo actual (año y mes en curso) para el rubro Rastro.

**Precondiciones:**
El usuario tiene acceso a la aplicación y permisos para consultar reportes.

**Pasos a seguir:**
1. El usuario accede a la página 'Adeudos Generales Anualizados'.
2. Selecciona 'A .- Total General' como tipo de reporte.
3. Selecciona 'T .- TODOS' como opción.
4. Selecciona 'Periodo Actual'.
5. Da clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los adeudos generales anualizados del periodo actual para todos los registros del rubro Rastro.

**Datos de prueba:**
{ "par_tabla": 3, "par_fecha": "2024-06" }

---

## Caso de Uso 2: Consulta de Adeudos Generales - Otro Periodo

**Descripción:** El usuario consulta el reporte de adeudos para un periodo específico (por ejemplo, marzo 2023) para el rubro Rastro.

**Precondiciones:**
El usuario tiene acceso y existen datos para el periodo solicitado.

**Pasos a seguir:**
1. Accede a la página 'Adeudos Generales Anualizados'.
2. Selecciona 'B .- Total General Anualizado'.
3. Selecciona 'S .- CON ADEUDO ALGUNO'.
4. Selecciona 'Otro Periodo', ingresa año 2023 y mes '03'.
5. Da clic en 'Consultar'.

**Resultado esperado:**
Se muestra la tabla de adeudos anualizados para marzo 2023, solo con registros con adeudo.

**Datos de prueba:**
{ "par_tabla": 3, "par_fecha": "2023-03" }

---

## Caso de Uso 3: Exportación de Reporte a Excel

**Descripción:** El usuario exporta el reporte de adeudos general anualizado a un archivo Excel.

**Precondiciones:**
El usuario ya realizó una consulta y hay datos en pantalla.

**Pasos a seguir:**
1. Da clic en el botón 'Exportar a Excel'.
2. El sistema genera el archivo y muestra un enlace de descarga.

**Resultado esperado:**
El usuario puede descargar el archivo Excel con los datos del reporte.

**Datos de prueba:**
No aplica (simulado en el ejemplo, en real debe devolver un archivo generado).

---

