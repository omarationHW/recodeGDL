# Casos de Uso - RptCuentaPublica

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte para oficina central en año actual

**Descripción:** El usuario desea obtener el reporte de cuentas por cobrar para la oficina central en el año fiscal actual.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos para la oficina central en el año actual.

**Pasos a seguir:**
1. Ingresar a la página de Reporte Cuenta Pública.
2. Seleccionar el año fiscal actual (ej: 2024).
3. Ingresar el número de oficina correspondiente a la oficina central (ej: 1).
4. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra el reporte tabular con los conceptos, saldos, altas, movimientos y bajas correspondientes a la oficina central para el año seleccionado.

**Datos de prueba:**
{ "axo": 2024, "oficina": 1 }

---

## Caso de Uso 2: Consulta de reporte para oficina inexistente

**Descripción:** El usuario intenta consultar el reporte para una oficina que no existe o no tiene datos.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Ingresar a la página de Reporte Cuenta Pública.
2. Seleccionar un año fiscal válido (ej: 2024).
3. Ingresar un número de oficina inexistente (ej: 9999).
4. Hacer clic en 'Consultar'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no se encontraron datos para los parámetros seleccionados.

**Datos de prueba:**
{ "axo": 2024, "oficina": 9999 }

---

## Caso de Uso 3: Error por parámetros faltantes

**Descripción:** El usuario intenta consultar el reporte sin ingresar todos los parámetros requeridos.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Ingresar a la página de Reporte Cuenta Pública.
2. Dejar vacío el campo de año fiscal o de oficina.
3. Hacer clic en 'Consultar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que los parámetros son requeridos.

**Datos de prueba:**
{ "axo": null, "oficina": 1 }

---

