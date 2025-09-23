# Casos de Uso - Prenomina

**Categoría:** Form

## Caso de Uso 1: Generar prenómina para todas las recaudadoras en un mes

**Descripción:** El usuario desea obtener el reporte de prenómina de ejecutores para todas las recaudadoras durante el mes de junio 2024.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos de pagos en junio 2024.

**Pasos a seguir:**
1. Acceder a la página Prenómina.
2. Seleccionar Fecha Desde: 2024-06-01.
3. Seleccionar Fecha Hasta: 2024-06-30.
4. Seleccionar opción 'Todas' en recaudadora.
5. Hacer clic en 'Procesar'.

**Resultado esperado:**
Se muestra una tabla con los ejecutores, sus gastos y folios pagados para todas las recaudadoras en junio 2024.

**Datos de prueba:**
fecha_desde: 2024-06-01
fecha_hasta: 2024-06-30
recaudadora_tipo: 'todas'

---

## Caso de Uso 2: Generar prenómina para una recaudadora específica

**Descripción:** El usuario requiere el reporte de prenómina solo para la recaudadora 3 en un rango de fechas.

**Precondiciones:**
El usuario tiene acceso y la recaudadora 3 tiene datos en el rango.

**Pasos a seguir:**
1. Acceder a la página Prenómina.
2. Seleccionar Fecha Desde: 2024-05-01.
3. Seleccionar Fecha Hasta: 2024-05-31.
4. Seleccionar opción 'Determinada' y elegir recaudadora 3.
5. Hacer clic en 'Procesar'.

**Resultado esperado:**
Se muestra la prenómina solo para la recaudadora 3.

**Datos de prueba:**
fecha_desde: 2024-05-01
fecha_hasta: 2024-05-31
recaudadora_tipo: 'determinada'
recaudadora: 3

---

## Caso de Uso 3: Validación de parámetros: fechas inválidas

**Descripción:** El usuario intenta procesar el reporte sin seleccionar fechas.

**Precondiciones:**
El usuario accede a la página pero deja los campos de fecha vacíos.

**Pasos a seguir:**
1. Acceder a la página Prenómina.
2. Dejar vacíos los campos de fecha.
3. Hacer clic en 'Procesar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que las fechas son obligatorias.

**Datos de prueba:**
fecha_desde: ''
fecha_hasta: ''

---

