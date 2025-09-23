# Casos de Uso - List_Mov

**Categoría:** Form

## Caso de Uso 1: Consulta de movimientos por rango de fechas y recaudadora

**Descripción:** El usuario desea obtener el listado de movimientos de cementerios registrados entre dos fechas específicas para una recaudadora determinada.

**Precondiciones:**
El usuario está autenticado y tiene permisos para consultar movimientos.

**Pasos a seguir:**
- El usuario accede a la página 'Listado de Movimientos de Cementerios'.
- Selecciona la fecha inicial y final.
- Ingresa el número de recaudadora (si corresponde).
- Presiona el botón 'Procesar'.

**Resultado esperado:**
Se muestra una tabla con los movimientos encontrados en el rango de fechas y recaudadora seleccionados.

**Datos de prueba:**
{ "fecha1": "2024-01-01", "fecha2": "2024-01-31", "reca": 2 }

---

## Caso de Uso 2: Generación de reporte de movimientos

**Descripción:** El usuario desea generar un reporte imprimible de los movimientos consultados.

**Precondiciones:**
El usuario ya realizó una consulta exitosa de movimientos.

**Pasos a seguir:**
- El usuario presiona el botón 'Imprimir Reporte'.

**Resultado esperado:**
El sistema genera un reporte (simulado) y muestra un mensaje de éxito.

**Datos de prueba:**
{ "fecha1": "2024-01-01", "fecha2": "2024-01-31", "reca": 2 }

---

## Caso de Uso 3: Validación de campos obligatorios

**Descripción:** El usuario intenta consultar movimientos sin completar todos los campos obligatorios.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
- El usuario deja vacío el campo 'fecha desde' y presiona 'Procesar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que los campos son obligatorios.

**Datos de prueba:**
{ "fecha1": "", "fecha2": "2024-01-31", "reca": 2 }

---

