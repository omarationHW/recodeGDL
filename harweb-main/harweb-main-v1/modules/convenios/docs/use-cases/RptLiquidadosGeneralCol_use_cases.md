# Casos de Uso - RptLiquidadosGeneralCol

**Categoría:** Form

## Caso de Uso 1: Consulta de contratos liquidados para una colonia específica

**Descripción:** El usuario desea obtener el listado de contratos vigentes liquidados con saldo menor o igual a $5000 para la colonia 12.

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen contratos en la colonia 12.

**Pasos a seguir:**
1. Ingresar '12' en el campo Colonia.
2. Ingresar '5000' en el campo Importe máximo de saldo.
3. Presionar el botón 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los contratos de la colonia 12 cuyo saldo es menor o igual a $5000, incluyendo totales y conceptos.

**Datos de prueba:**
{ colonia: 12, importe: 5000 }

---

## Caso de Uso 2: Consulta sin resultados (colonia sin contratos liquidados)

**Descripción:** El usuario consulta una colonia que no tiene contratos liquidados con saldo menor o igual al importe indicado.

**Precondiciones:**
La colonia 99 existe pero no tiene contratos liquidados con saldo <= $1000.

**Pasos a seguir:**
1. Ingresar '99' en el campo Colonia.
2. Ingresar '1000' en el campo Importe máximo de saldo.
3. Presionar el botón 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje indicando que no se encontraron registros.

**Datos de prueba:**
{ colonia: 99, importe: 1000 }

---

## Caso de Uso 3: Validación de parámetros obligatorios

**Descripción:** El usuario intenta consultar el reporte sin ingresar todos los parámetros requeridos.

**Precondiciones:**
El usuario accede a la página del reporte.

**Pasos a seguir:**
1. Dejar vacío el campo Colonia o Importe.
2. Presionar el botón 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que los parámetros son obligatorios.

**Datos de prueba:**
{ colonia: '', importe: '' }

---

