# Casos de Uso - PadronConvenios

**Categoría:** Form

## Caso de Uso 1: Consulta básica del padrón de convenios vigentes

**Descripción:** El usuario desea consultar todos los convenios vigentes de un tipo y subtipo específico, en un rango de años.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de consulta.

**Pasos a seguir:**
1. Accede a la página 'Padrón de Convenios'.
2. Selecciona un tipo (por ejemplo, '3 - Licencias').
3. Selecciona un subtipo (por ejemplo, '1 - Licencias de Giro').
4. Selecciona 'VIGENTES' en vigencia.
5. Deja 'Todas las recaudadoras'.
6. Ingresa año desde 2022 y año hasta 2024.
7. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra la lista de convenios vigentes del tipo y subtipo seleccionados, en el rango de años indicado.

**Datos de prueba:**
{ "tipo": 3, "subtipo": 1, "vigencia": "A", "recaudadora": null, "anio_desde": 2022, "anio_hasta": 2024 }

---

## Caso de Uso 2: Consulta de folios (parcialidades) de un convenio

**Descripción:** El usuario desea ver el detalle de folios (parcialidades) de un convenio específico.

**Precondiciones:**
El usuario ya realizó una búsqueda y tiene la lista de convenios en pantalla.

**Pasos a seguir:**
1. En la tabla de resultados, ubica el convenio deseado.
2. Haz clic en el botón 'Folios' de la fila correspondiente.

**Resultado esperado:**
Se despliega una tabla con los folios (parcialidades), ejecutor, fechas y periodos del convenio seleccionado.

**Datos de prueba:**
{ "id_conv_resto": 123, "modulo": 9, "id_referencia": 456, "fecha_inicio": "2023-01-01", "fecha_venc": "2023-12-31" }

---

## Caso de Uso 3: Exportación de resultados a Excel

**Descripción:** El usuario desea exportar el resultado de la consulta a un archivo Excel (CSV).

**Precondiciones:**
El usuario ya realizó una búsqueda y hay resultados en pantalla.

**Pasos a seguir:**
1. Haz clic en el botón 'Exportar Excel'.
2. El navegador descarga un archivo CSV con los datos mostrados.

**Resultado esperado:**
El archivo CSV contiene todas las filas y columnas de la tabla de resultados.

**Datos de prueba:**
No aplica (usa los datos de la consulta actual).

---

