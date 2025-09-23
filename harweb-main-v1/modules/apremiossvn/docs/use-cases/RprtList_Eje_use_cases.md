# Casos de Uso - RprtList_Eje

**Categoría:** Form

## Caso de Uso 1: Consulta de Requerimientos Vigentes por Ejecutores

**Descripción:** El usuario desea obtener el listado de requerimientos vigentes para un grupo de ejecutores en un periodo específico.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce los IDs de los ejecutores.

**Pasos a seguir:**
1. Ingresar los IDs de ejecutores (ej: 1,2,3) en el campo correspondiente.
2. Seleccionar 'Vigentes' en el campo Vigencia.
3. Ingresar la fecha inicial y final del periodo.
4. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los requerimientos vigentes de los ejecutores seleccionados en el periodo indicado.

**Datos de prueba:**
{ "varios": "1,2,3", "vvig": "1", "vrec": "", "vopc": 1, "vfec1": "2024-01-01", "vfec2": "2024-01-31", "vrecaudadora": 0, "vfecP1": null, "vfecP2": null, "vnombre": "", "v90d": "N" }

---

## Caso de Uso 2: Consulta de Requerimientos Pagados con Filtro de Zona

**Descripción:** El usuario requiere ver los requerimientos pagados en una zona específica durante un rango de fechas.

**Precondiciones:**
El usuario conoce el ID de la zona/recaudadora.

**Pasos a seguir:**
1. Ingresar los IDs de ejecutores.
2. Seleccionar 'Pagados' en Vigencia.
3. Ingresar el ID de la zona en el campo Zona/Recaudadora.
4. Ingresar fechas inicial y final.
5. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se listan los requerimientos pagados en la zona seleccionada.

**Datos de prueba:**
{ "varios": "2,5", "vvig": "2", "vrec": "3", "vopc": 1, "vfec1": "2024-02-01", "vfec2": "2024-02-28", "vrecaudadora": 3, "vfecP1": null, "vfecP2": null, "vnombre": "", "v90d": "N" }

---

## Caso de Uso 3: Consulta de Requerimientos con Días Pasados Menores a 91

**Descripción:** El usuario desea filtrar los requerimientos donde la diferencia de días entre pago y practicado es menor a 91.

**Precondiciones:**
El usuario tiene acceso y existen datos con diaspas < 91.

**Pasos a seguir:**
1. Ingresar los IDs de ejecutores.
2. Seleccionar el periodo de fechas.
3. Seleccionar 'Sí' en el campo 'Solo < 90 días'.
4. Hacer clic en 'Buscar'.

**Resultado esperado:**
Solo se muestran los registros donde diaspas < 91.

**Datos de prueba:**
{ "varios": "1,2", "vvig": "1", "vrec": "", "vopc": 1, "vfec1": "2024-03-01", "vfec2": "2024-03-31", "vrecaudadora": 0, "vfecP1": null, "vfecP2": null, "vnombre": "", "v90d": "S" }

---

