# Casos de Uso - ListxFec

**Categoría:** Form

## Caso de Uso 1: Generar reporte de requerimientos por fecha de practicado para Mercados

**Descripción:** El usuario desea obtener un listado de requerimientos del módulo Mercados, filtrando por fecha de practicado, para una recaudadora específica y todos los ejecutores.

**Precondiciones:**
El usuario está autenticado y tiene permisos para consultar el módulo.

**Pasos a seguir:**
1. Accede a la página ListxFec.
2. Selecciona 'Mercados' como aplicación.
3. Selecciona 'Practicado' como tipo de fecha.
4. Selecciona la recaudadora 2.
5. Selecciona 'Todos' los ejecutores.
6. Ingresa fecha desde '2024-01-01' y hasta '2024-01-31'.
7. Da clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestra una tabla con los folios practicados en el rango de fechas, con datos de ejecutor, vigencia, importe y datos relacionados.

**Datos de prueba:**
{ "rec": 2, "modulo": 11, "tipo_fecha": 2, "fecha1": "2024-01-01", "fecha2": "2024-01-31", "vigencia": "todas", "ejecutor": "todos" }

---

## Caso de Uso 2: Filtrar reporte por ejecutor específico y vigencia

**Descripción:** El usuario requiere ver solo los requerimientos vigentes asignados a un ejecutor específico en el módulo Aseo.

**Precondiciones:**
El usuario está autenticado y conoce el cve_eje del ejecutor.

**Pasos a seguir:**
1. Accede a la página ListxFec.
2. Selecciona 'Aseo' como aplicación.
3. Selecciona 'Actualización' como tipo de fecha.
4. Selecciona la recaudadora 3.
5. Selecciona el ejecutor con cve_eje=5.
6. Selecciona vigencia '1'.
7. Ingresa fechas desde '2024-02-01' hasta '2024-02-28'.
8. Da clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestran solo los folios vigentes asignados al ejecutor 5 en el rango de fechas.

**Datos de prueba:**
{ "rec": 3, "modulo": 16, "tipo_fecha": 1, "fecha1": "2024-02-01", "fecha2": "2024-02-28", "vigencia": "1", "ejecutor": "5" }

---

## Caso de Uso 3: Reporte de requerimientos pagados en Estacionamientos Públicos

**Descripción:** El usuario desea obtener todos los requerimientos pagados en el módulo Estacionamientos Públicos, sin filtrar ejecutor.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Accede a la página ListxFec.
2. Selecciona 'Estacionamientos Públicos' como aplicación.
3. Selecciona 'Pago' como tipo de fecha.
4. Selecciona la recaudadora 4.
5. Selecciona 'Todos' los ejecutores.
6. Selecciona vigencia '2'.
7. Ingresa fechas desde '2024-03-01' hasta '2024-03-31'.
8. Da clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestran los folios pagados en el rango de fechas para el módulo seleccionado.

**Datos de prueba:**
{ "rec": 4, "modulo": 24, "tipo_fecha": 4, "fecha1": "2024-03-01", "fecha2": "2024-03-31", "vigencia": "2", "ejecutor": "todos" }

---

