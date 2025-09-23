# Casos de Uso - RprtListaxRegAseo

**Categoría:** Form

## Caso de Uso 1: Consulta de registros de aseo vigentes para una oficina

**Descripción:** El usuario desea obtener el listado de registros de aseo con requerimientos vigentes para la oficina 1 y tipo de aseo 'H'.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el id_rec de su oficina.

**Pasos a seguir:**
1. Ingresar a la página 'Listado de Registros de Mercados con Requerimientos'.
2. Ingresar '1' en el campo Oficina (id_rec).
3. Ingresar 'H' en el campo Tipo de Aseo.
4. Seleccionar 'Todas' en Clave Practicado.
5. Seleccionar 'Vigente' en Vigencia.
6. Presionar el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los registros de aseo vigentes para la oficina 1 y tipo 'H', incluyendo totales.

**Datos de prueba:**
{ "id_rec": 1, "tipo_aseo": "H", "clave_practicado": "todas", "vigencia": "1" }

---

## Caso de Uso 2: Exportar resultados a CSV

**Descripción:** El usuario desea exportar el listado filtrado a un archivo CSV para su análisis.

**Precondiciones:**
Se ha realizado una consulta y hay resultados en pantalla.

**Pasos a seguir:**
1. Realizar una búsqueda con cualquier filtro.
2. Una vez mostrados los resultados, presionar el botón 'Exportar CSV'.

**Resultado esperado:**
Se descarga un archivo CSV con los datos mostrados en la tabla.

**Datos de prueba:**
Cualquier filtro que arroje resultados.

---

## Caso de Uso 3: Consulta de registros con clave practicado específica y vigencia vencida/parcial

**Descripción:** El usuario desea ver los registros con clave practicado 'A' y vigencia '2' (vencido o parcial) para la oficina 2 y tipo de aseo 'G'.

**Precondiciones:**
El usuario tiene acceso y existen registros con esas condiciones.

**Pasos a seguir:**
1. Ingresar '2' en Oficina (id_rec).
2. Ingresar 'G' en Tipo de Aseo.
3. Seleccionar 'A' en Clave Practicado.
4. Seleccionar 'Vencido' en Vigencia.
5. Presionar 'Buscar'.

**Resultado esperado:**
Se muestran solo los registros con clave practicado 'A' y vigencia '2' o 'P' para la oficina y tipo seleccionados.

**Datos de prueba:**
{ "id_rec": 2, "tipo_aseo": "G", "clave_practicado": "A", "vigencia": "2" }

---

