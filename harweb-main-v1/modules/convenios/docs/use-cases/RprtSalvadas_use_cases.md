# Casos de Uso - RprtSalvadas

**Categoría:** Form

## Caso de Uso 1: Generar reporte de salvadas para todos los usuarios en un rango de fechas

**Descripción:** El usuario desea obtener un listado de todas las salvadas realizadas entre el 1 y el 30 de junio de 2024.

**Precondiciones:**
Existen registros en la tabla 'salvadas' con fechas dentro del rango especificado.

**Pasos a seguir:**
1. Ingresar a la página de Reporte Salvadas.
2. Dejar el campo 'Usuario' vacío.
3. Seleccionar 'Desde': 2024-06-01.
4. Seleccionar 'Hasta': 2024-06-30.
5. Hacer clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestra una tabla con todas las salvadas realizadas entre el 1 y el 30 de junio de 2024, de todos los usuarios.

**Datos de prueba:**
user_id: null, date_from: '2024-06-01', date_to: '2024-06-30'

---

## Caso de Uso 2: Generar reporte de salvadas para un usuario específico

**Descripción:** El usuario desea ver todas las salvadas realizadas por el usuario con ID 5 durante el mes de mayo de 2024.

**Precondiciones:**
Existen registros en 'salvadas' con user_id=5 y fechas en mayo 2024.

**Pasos a seguir:**
1. Ingresar a la página de Reporte Salvadas.
2. Escribir '5' en el campo 'Usuario'.
3. Seleccionar 'Desde': 2024-05-01.
4. Seleccionar 'Hasta': 2024-05-31.
5. Hacer clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestra una tabla con todas las salvadas del usuario 5 en mayo de 2024.

**Datos de prueba:**
user_id: 5, date_from: '2024-05-01', date_to: '2024-05-31'

---

## Caso de Uso 3: Generar reporte sin resultados

**Descripción:** El usuario busca salvadas de un usuario inexistente o en un rango de fechas sin registros.

**Precondiciones:**
No existen registros que cumplan los criterios.

**Pasos a seguir:**
1. Ingresar a la página de Reporte Salvadas.
2. Escribir '9999' en el campo 'Usuario'.
3. Seleccionar 'Desde': 2023-01-01.
4. Seleccionar 'Hasta': 2023-01-31.
5. Hacer clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestra un mensaje indicando que no se encontraron resultados.

**Datos de prueba:**
user_id: 9999, date_from: '2023-01-01', date_to: '2023-01-31'

---

