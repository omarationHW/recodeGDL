# Casos de Uso - RptDesgloceAdeporImporte

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte con parámetros válidos

**Descripción:** El usuario consulta el reporte de adeudos vencidos para el año 2023, periodo 6 (junio), con importe mínimo de $1000.

**Precondiciones:**
Existen locales con adeudos mayores o iguales a $1000 hasta junio de 2023.

**Pasos a seguir:**
1. Ingresar año 2023, periodo 6, importe 1000 en el formulario.
2. Presionar 'Consultar'.
3. Esperar la carga y visualizar la tabla de resultados.

**Resultado esperado:**
Se muestra una tabla con los locales que cumplen el criterio, incluyendo totales por columna.

**Datos de prueba:**
{ year: 2023, period: 6, amount: 1000 }

---

## Caso de Uso 2: Consulta sin resultados

**Descripción:** El usuario consulta el reporte para un importe mínimo muy alto, donde no existen adeudos.

**Precondiciones:**
No existen locales con adeudos mayores o iguales a $1,000,000.

**Pasos a seguir:**
1. Ingresar año 2023, periodo 6, importe 1000000 en el formulario.
2. Presionar 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje de 'No se encontraron resultados para los parámetros indicados.'

**Datos de prueba:**
{ year: 2023, period: 6, amount: 1000000 }

---

## Caso de Uso 3: Error por parámetros insuficientes

**Descripción:** El usuario intenta consultar el reporte sin ingresar el año.

**Precondiciones:**
El campo año está vacío o no es válido.

**Pasos a seguir:**
1. Dejar el campo año vacío.
2. Ingresar periodo 6, importe 1000.
3. Presionar 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando 'Parámetros insuficientes'.

**Datos de prueba:**
{ year: null, period: 6, amount: 1000 }

---

