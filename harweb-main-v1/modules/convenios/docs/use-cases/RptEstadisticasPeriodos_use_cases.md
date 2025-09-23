# Casos de Uso - RptEstadisticasPeriodos

**Categoría:** Form

## Caso de Uso 1: Consulta de Estadísticas de Periodos con Detalle

**Descripción:** El usuario desea obtener la estadística de adeudos mayores o iguales a $10,000 para el año de obra 2024, mostrando el detalle de cada contrato.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes.

**Pasos a seguir:**
1. Ingresa a la página 'Estadísticas por Periodo'.
2. Selecciona 'Año de Obra': 2024.
3. Ingresa 'Adeudo mínimo': 10000.
4. Selecciona 'Mostrar Detalle'.
5. Presiona 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los contratos agrupados por plazo y año de firma, incluyendo colonia, calle y folio.

**Datos de prueba:**
{ "axo": 2024, "adeudo": 10000, "opc": 1 }

---

## Caso de Uso 2: Exportar Estadística de Periodos a Excel

**Descripción:** El usuario desea exportar a Excel la estadística de adeudos para el año 2023, sin mostrar detalle.

**Precondiciones:**
El usuario tiene acceso y permisos de exportación.

**Pasos a seguir:**
1. Ingresa a la página 'Estadísticas por Periodo'.
2. Selecciona 'Año de Obra': 2023.
3. Deja 'Adeudo mínimo' en 0.
4. Selecciona 'Solo Totales'.
5. Presiona 'Exportar Excel'.

**Resultado esperado:**
Se descarga un archivo Excel con los totales por plazo y año de firma, sin detalle de colonia/calle/folio.

**Datos de prueba:**
{ "axo": 2023, "adeudo": 0, "opc": 2 }

---

## Caso de Uso 3: Consulta sin resultados

**Descripción:** El usuario consulta estadísticas para un año de obra sin contratos registrados.

**Precondiciones:**
El año de obra 1990 no tiene contratos en la base de datos.

**Pasos a seguir:**
1. Ingresa a la página 'Estadísticas por Periodo'.
2. Selecciona 'Año de Obra': 1990.
3. Presiona 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje indicando que no hay resultados.

**Datos de prueba:**
{ "axo": 1990, "adeudo": 0, "opc": 1 }

---

