# Casos de Uso - RptFacturaEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de Factura de Energía para un Mercado Específico

**Descripción:** El usuario desea obtener el reporte de consumo y facturación de energía eléctrica para una oficina y mercado en un periodo y año determinados.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce los valores de oficina, mercado, año y periodo.

**Pasos a seguir:**
1. El usuario accede a la página 'Factura Energía'.
2. Ingresa los valores: Oficina=1, Mercado=2, Año=2024, Periodo=6 (Junio).
3. Presiona el botón 'Consultar'.
4. El sistema consulta el API y muestra el reporte tabular con los datos correspondientes.

**Resultado esperado:**
Se muestra el reporte con los locales, consumos, importes y totales globales para los parámetros seleccionados.

**Datos de prueba:**
{ "oficina": 1, "mercado": 2, "axo": 2024, "periodo": 6 }

---

## Caso de Uso 2: Validación de Parámetros Faltantes

**Descripción:** El usuario intenta consultar el reporte sin ingresar todos los parámetros requeridos.

**Precondiciones:**
El usuario accede a la página pero omite uno o más campos obligatorios.

**Pasos a seguir:**
1. El usuario deja vacío el campo 'Mercado'.
2. Presiona 'Consultar'.
3. El sistema valida y muestra un mensaje de error.

**Resultado esperado:**
El sistema no realiza la consulta y muestra un mensaje indicando los parámetros faltantes.

**Datos de prueba:**
{ "oficina": 1, "mercado": null, "axo": 2024, "periodo": 6 }

---

## Caso de Uso 3: Reporte sin Resultados

**Descripción:** El usuario consulta un periodo/año/mercado/oficina para el cual no existen datos.

**Precondiciones:**
No existen registros en la base de datos para los parámetros dados.

**Pasos a seguir:**
1. El usuario ingresa Oficina=99, Mercado=99, Año=2020, Periodo=1.
2. Presiona 'Consultar'.
3. El sistema consulta el API y recibe un arreglo vacío.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no hay datos para los parámetros seleccionados.

**Datos de prueba:**
{ "oficina": 99, "mercado": 99, "axo": 2020, "periodo": 1 }

---

