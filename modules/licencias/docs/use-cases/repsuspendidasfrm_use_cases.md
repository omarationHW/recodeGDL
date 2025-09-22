# Casos de Uso - repsuspendidasfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de licencias suspendidas por año

**Descripción:** El usuario desea obtener un reporte de todas las licencias suspendidas en el año 2023, sin filtrar por tipo de suspensión.

**Precondiciones:**
El usuario tiene acceso al sistema y existen licencias suspendidas en 2023.

**Pasos a seguir:**
1. Ingresar a la página de 'Reporte de Licencias Suspendidas'.
2. Ingresar '2023' en el campo Año.
3. Dejar vacíos los campos de fecha.
4. Seleccionar 'Todas' en tipo de suspensión.
5. Hacer clic en 'Imprimir / Consultar'.

**Resultado esperado:**
Se muestra una tabla con todas las licencias suspendidas en 2023, incluyendo los datos principales y el total de registros.

**Datos de prueba:**
{ "year": 2023, "date_from": null, "date_to": null, "tipo_suspension": 0 }

---

## Caso de Uso 2: Consulta por rango de fechas y tipo de suspensión

**Descripción:** El usuario requiere ver las licencias suspendidas entre el 1 y el 15 de febrero de 2024, solo del tipo 'Suspendida'.

**Precondiciones:**
El usuario tiene acceso y existen licencias suspendidas en ese rango y tipo.

**Pasos a seguir:**
1. Ingresar a la página de reporte.
2. Dejar vacío el campo Año.
3. Seleccionar fecha inicial '2024-02-01' y fecha final '2024-02-15'.
4. Seleccionar 'Suspendida' como tipo de suspensión.
5. Hacer clic en 'Imprimir / Consultar'.

**Resultado esperado:**
Se listan solo las licencias suspendidas entre esas fechas y con tipo 'Suspendida'.

**Datos de prueba:**
{ "year": 0, "date_from": "2024-02-01", "date_to": "2024-02-15", "tipo_suspension": 4 }

---

## Caso de Uso 3: Validación de campos requeridos

**Descripción:** El usuario intenta consultar el reporte sin ingresar año ni fechas.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Ingresar a la página de reporte.
2. Dejar vacíos todos los campos de filtro.
3. Hacer clic en 'Imprimir / Consultar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que debe indicar el año o las fechas.

**Datos de prueba:**
{ "year": 0, "date_from": null, "date_to": null, "tipo_suspension": 0 }

---

