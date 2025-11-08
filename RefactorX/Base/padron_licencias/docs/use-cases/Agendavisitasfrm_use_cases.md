# Casos de Uso - Agendavisitasfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de visitas agendadas por dependencia y rango de fechas

**Descripción:** El usuario desea consultar todas las visitas agendadas para una dependencia específica en un rango de fechas.

**Precondiciones:**
El usuario tiene acceso al sistema y existen visitas agendadas en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página 'Agenda de Visitas'.
2. Selecciona una dependencia del listado.
3. Selecciona la fecha de inicio y fin del rango.
4. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todas las visitas agendadas que cumplen con los filtros seleccionados.

**Datos de prueba:**
id_dependencia: 2
fechaini: 2024-06-01
fechafin: 2024-06-30

---

## Caso de Uso 2: Exportación de visitas agendadas a Excel

**Descripción:** El usuario desea exportar el listado de visitas agendadas a un archivo Excel (CSV).

**Precondiciones:**
El usuario ya realizó una consulta y hay resultados en la tabla.

**Pasos a seguir:**
1. El usuario presiona el botón 'Exportar a Excel'.
2. El sistema genera y descarga un archivo CSV con los datos mostrados.

**Resultado esperado:**
El archivo CSV contiene todas las filas y columnas visibles en la tabla.

**Datos de prueba:**
Resultado de la consulta anterior.

---

## Caso de Uso 3: Impresión del reporte de visitas agendadas

**Descripción:** El usuario desea imprimir el reporte de visitas agendadas filtradas.

**Precondiciones:**
El usuario ya realizó una consulta y hay resultados en la tabla.

**Pasos a seguir:**
1. El usuario presiona el botón 'Imprimir'.
2. El sistema abre una ventana de impresión con el reporte formateado.
3. El usuario imprime el reporte.

**Resultado esperado:**
El reporte impreso contiene los datos filtrados y el encabezado correspondiente.

**Datos de prueba:**
Resultado de la consulta anterior.

---

