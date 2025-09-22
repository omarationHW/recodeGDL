# Casos de Uso - CuentaPublica

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos por Mercado y Mes

**Descripción:** El usuario desea consultar el resumen de adeudos de una recaudadora específica para un año y mes determinados.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página 'Cuenta Pública'.
2. Selecciona la recaudadora (por ejemplo, '1 - Zona Centro').
3. Selecciona el año (por ejemplo, 2024) y el mes (por ejemplo, 6).
4. Presiona el botón 'Consultar'.
5. El sistema muestra la tabla de adeudos por mercado y mes, y la tabla de totales por recaudadora y mes.

**Resultado esperado:**
Se muestran correctamente los datos de adeudos agregados por mercado y mes, y los totales, sin errores.

**Datos de prueba:**
{ "oficina": 1, "axo": 2024, "periodo": 6 }

---

## Caso de Uso 2: Generación de Reporte Imprimible de Cuenta Pública

**Descripción:** El usuario desea generar un reporte imprimible/exportable de la cuenta pública para una recaudadora y año seleccionados.

**Precondiciones:**
El usuario está autenticado y ha realizado una consulta previa.

**Pasos a seguir:**
1. El usuario realiza una consulta de adeudos como en el caso anterior.
2. Presiona el botón 'Imprimir'.
3. El sistema llama al SP de reporte y genera el archivo (PDF/Excel).

**Resultado esperado:**
El usuario recibe el archivo generado correctamente, listo para impresión o exportación.

**Datos de prueba:**
{ "oficina": 1, "axo": 2024, "periodo": 6 }

---

## Caso de Uso 3: Validación de Parámetros y Seguridad

**Descripción:** El sistema debe rechazar consultas con parámetros inválidos o usuarios no autenticados.

**Precondiciones:**
El usuario no está autenticado o envía parámetros inválidos.

**Pasos a seguir:**
1. El usuario intenta consultar sin autenticarse o con parámetros fuera de rango (por ejemplo, año 1800).
2. El sistema valida la sesión y los parámetros.

**Resultado esperado:**
El sistema responde con un error adecuado y no ejecuta la consulta.

**Datos de prueba:**
{ "oficina": 1, "axo": 1800, "periodo": 6 }

---

