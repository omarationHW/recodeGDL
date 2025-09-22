# Casos de Uso - RptPagosLocales

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos locales por recaudadora y fechas

**Descripción:** El usuario desea obtener el listado de pagos realizados en una recaudadora específica durante un rango de fechas.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar la recaudadora.

**Pasos a seguir:**
- Acceder a la página de Reporte de Pagos Locales.
- Seleccionar la recaudadora 'Zona Centro'.
- Seleccionar fecha desde '2024-06-01' y fecha hasta '2024-06-30'.
- Hacer clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestra una tabla con todos los pagos realizados en la recaudadora 'Zona Centro' entre el 1 y el 30 de junio de 2024, incluyendo datos de local, importe, usuario, etc.

**Datos de prueba:**
{ "fecha_desde": "2024-06-01", "fecha_hasta": "2024-06-30", "oficina": 1 }

---

## Caso de Uso 2: Validación de parámetros obligatorios

**Descripción:** El usuario intenta generar el reporte sin seleccionar la recaudadora.

**Precondiciones:**
El usuario está en la página de Reporte de Pagos Locales.

**Pasos a seguir:**
- Seleccionar fecha desde y hasta, pero dejar la recaudadora vacía.
- Hacer clic en 'Generar Reporte'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que la recaudadora es obligatoria.

**Datos de prueba:**
{ "fecha_desde": "2024-06-01", "fecha_hasta": "2024-06-30", "oficina": "" }

---

## Caso de Uso 3: Exportación y suma de importes

**Descripción:** El usuario genera el reporte y verifica el total de importes pagados.

**Precondiciones:**
Existen pagos registrados en el rango de fechas y recaudadora seleccionados.

**Pasos a seguir:**
- Generar el reporte con los filtros deseados.
- Verificar que la suma de la columna 'Importe' coincida con el total mostrado.

**Resultado esperado:**
La suma de los importes individuales coincide con el total mostrado en la interfaz.

**Datos de prueba:**
{ "fecha_desde": "2024-06-01", "fecha_hasta": "2024-06-30", "oficina": 3 }

---

