# Casos de Uso - girosVigentesCteXgirofrm

**Categoría:** Form

## Caso de Uso 1: Consulta de giros vigentes por año y clasificación

**Descripción:** El usuario desea obtener un reporte de los giros vigentes en el año 2024, filtrando solo los de clasificación 'A', ordenados por concurrencias.

**Precondiciones:**
El usuario está autenticado y tiene acceso al módulo de reportes.

**Pasos a seguir:**
1. Accede a la página de 'Reporte de Giros Vigentes'.
2. Selecciona 'Año de alta' = 2024.
3. Selecciona 'Filtrado por' = Vigentes.
4. Selecciona 'Clasificación' = Solo A.
5. Selecciona 'Ordenado por' = Número de concurrencias.
6. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los giros vigentes del año 2024, solo clasificación A, agrupados y ordenados por concurrencias.

**Datos de prueba:**
{ "year": 2024, "vigente": "V", "clasificacion": "A", "order_by": "cuantos" }

---

## Caso de Uso 2: Reporte de giros cancelados en un rango de fechas

**Descripción:** El usuario requiere un listado de giros cancelados entre el 01/01/2023 y el 31/03/2023, de cualquier clasificación, ordenados por descripción.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Accede a la página de reporte.
2. Deja vacío el campo 'Año'.
3. Selecciona 'Fecha desde' = 2023-01-01 y 'Fecha hasta' = 2023-03-31.
4. Selecciona 'Filtrado por' = Cancelados.
5. Selecciona 'Clasificación' = Todas.
6. Selecciona 'Ordenado por' = Descripción.
7. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra la lista de giros cancelados en el rango de fechas, agrupados y ordenados por descripción.

**Datos de prueba:**
{ "date_from": "2023-01-01", "date_to": "2023-03-31", "vigente": "C", "clasificacion": "", "order_by": "descripcion" }

---

## Caso de Uso 3: Impresión del reporte de giros vigentes

**Descripción:** El usuario desea imprimir el reporte actual de giros vigentes filtrados por año 2022 y clasificación B.

**Precondiciones:**
El usuario ya realizó una búsqueda y tiene resultados en pantalla.

**Pasos a seguir:**
1. Realiza la búsqueda con año 2022, vigente, clasificación B.
2. Da clic en 'Imprimir'.

**Resultado esperado:**
Se genera un PDF o vista de impresión con el reporte mostrado.

**Datos de prueba:**
{ "year": 2022, "vigente": "V", "clasificacion": "B", "order_by": "cuantos" }

---

