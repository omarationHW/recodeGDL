# Casos de Uso - RprtSalvadas

**Categoría:** Form

## Caso de Uso 1: Generar reporte de salvadas para el mes actual

**Descripción:** El usuario desea obtener un listado de todas las salvadas registradas durante el mes actual.

**Precondiciones:**
Existen registros en la tabla 'salvadas' para el mes actual.

**Pasos a seguir:**
1. El usuario accede a la página 'Reporte de Salvadas'.
2. Selecciona como fecha de inicio el primer día del mes actual.
3. Selecciona como fecha de fin el último día del mes actual.
4. Hace clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestra una tabla con todas las salvadas registradas en el mes actual, incluyendo fecha, descripción y valor.

**Datos de prueba:**
start_date: 2024-06-01
end_date: 2024-06-30

---

## Caso de Uso 2: Reporte sin resultados

**Descripción:** El usuario solicita un reporte para un rango de fechas donde no existen registros.

**Precondiciones:**
No existen registros en la tabla 'salvadas' para el rango seleccionado.

**Pasos a seguir:**
1. El usuario accede a la página 'Reporte de Salvadas'.
2. Selecciona un rango de fechas sin registros (por ejemplo, 2023-01-01 a 2023-01-31).
3. Hace clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestra un mensaje indicando que no se encontraron resultados para el rango seleccionado.

**Datos de prueba:**
start_date: 2023-01-01
end_date: 2023-01-31

---

## Caso de Uso 3: Error por fechas inválidas

**Descripción:** El usuario intenta generar un reporte ingresando una fecha de inicio posterior a la fecha de fin.

**Precondiciones:**
El formulario permite ingresar fechas manualmente.

**Pasos a seguir:**
1. El usuario accede a la página 'Reporte de Salvadas'.
2. Ingresa como fecha de inicio '2024-07-01' y como fecha de fin '2024-06-01'.
3. Hace clic en 'Generar Reporte'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el rango de fechas es inválido.

**Datos de prueba:**
start_date: 2024-07-01
end_date: 2024-06-01

---

