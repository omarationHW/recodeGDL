# Casos de Uso - EstadisticasContratos

**Categoría:** Form

## Caso de Uso 1: Consulta de Estadísticas de Contratos por Año y Fondo

**Descripción:** El usuario desea obtener un reporte de estadísticas de contratos para el año 2023 y fondo Ramo 33.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Ingresa a la página de Estadísticas Contratos.
2. Selecciona 'Estadística' como tipo de listado.
3. Selecciona 'Ramo 33' como fondo.
4. Ingresa '2023' como año de obra.
5. Presiona 'Ejecutar'.

**Resultado esperado:**
Se muestra una tabla con las estadísticas de contratos para el año 2023 y fondo Ramo 33.

**Datos de prueba:**
{ "eRequest": { "action": "getEstadisticasContratos", "params": { "anio_obra": 2023, "fondo": 16 } } }

---

## Caso de Uso 2: Exportar Adeudos Vencidos a Excel

**Descripción:** El usuario requiere exportar a Excel los adeudos vencidos del año 2022 para Obra Directa.

**Precondiciones:**
El usuario está autenticado y existen datos de adeudos para 2022 y fondo 15.

**Pasos a seguir:**
1. Ingresa a la página de Estadísticas Contratos.
2. Selecciona 'Adeudos Fecha Actual' como tipo de listado.
3. Selecciona 'Obra Directa' como fondo.
4. Ingresa '2022' como año de obra.
5. Presiona 'Ejecutar'.
6. Presiona 'Exportar a Excel'.

**Resultado esperado:**
Se descarga un archivo CSV/Excel con los adeudos vencidos correspondientes.

**Datos de prueba:**
{ "eRequest": { "action": "getAdeudosVencidos", "params": { "anio_obra": 2022, "fondo": 15 } } }

---

## Caso de Uso 3: Consulta de Estadísticas por Periodo con Detalle

**Descripción:** El usuario desea ver estadísticas de contratos por periodo para el año 2021, con adeudo mínimo de $5000 y detalle.

**Precondiciones:**
El usuario está autenticado y existen contratos con adeudo >= $5000 en 2021.

**Pasos a seguir:**
1. Ingresa a la página de Estadísticas Contratos.
2. Selecciona 'Estadísticas por Periodo' como tipo de listado.
3. Ingresa '2021' como año de obra.
4. Ingresa '5000' como adeudo mínimo.
5. Marca 'Imprimir Detalle'.
6. Presiona 'Ejecutar'.

**Resultado esperado:**
Se muestra una tabla detallada de contratos por periodo con adeudo >= $5000.

**Datos de prueba:**
{ "eRequest": { "action": "getEstadisticasPeriodos", "params": { "anio_obra": 2021, "adeudo_min": 5000, "detalle": true } } }

---

