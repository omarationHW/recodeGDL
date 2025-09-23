# Casos de Uso - constpat

**Categoría:** Form

## Caso de Uso 1: Consulta de transmisión patrimonial por folio

**Descripción:** El usuario ingresa un folio específico y obtiene los datos completos de la transmisión patrimonial asociada.

**Precondiciones:**
El folio existe en la base de datos y el usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página de consulta de transmisiones patrimoniales.
2. Ingresa el número de folio en el campo correspondiente.
3. Presiona el botón 'Buscar'.
4. El sistema envía la petición al endpoint `/api/execute` con eRequest 'consultarTransmisionPorFolio'.
5. El backend ejecuta el SP y retorna los datos.
6. El frontend muestra los datos en la tabla.

**Resultado esperado:**
Se muestran todos los campos de la transmisión patrimonial para el folio ingresado.

**Datos de prueba:**
{ "folio": 12345 }

---

## Caso de Uso 2: Consulta de transmisiones pagadas por rango de fechas (detalle)

**Descripción:** El usuario consulta todas las transmisiones patrimoniales pagadas entre dos fechas, visualizando el detalle de cada una.

**Precondiciones:**
Existen transmisiones pagadas en el rango de fechas seleccionado.

**Pasos a seguir:**
1. El usuario accede a la página de consulta.
2. Selecciona las fechas 'desde' y 'hasta'.
3. Selecciona la opción 'Folio x Folio'.
4. Presiona 'Buscar'.
5. El sistema consulta los SP correspondientes y muestra los resultados en tabla.

**Resultado esperado:**
Se muestra una tabla con el detalle de cada transmisión y el total de folios en el rango.

**Datos de prueba:**
{ "desde": "2024-01-01", "hasta": "2024-01-31" }

---

## Caso de Uso 3: Consulta de totales de transmisiones por día

**Descripción:** El usuario consulta el total de transmisiones patrimoniales pagadas agrupadas por día en un rango de fechas.

**Precondiciones:**
Existen transmisiones pagadas en el rango de fechas seleccionado.

**Pasos a seguir:**
1. El usuario accede a la página de consulta.
2. Selecciona las fechas 'desde' y 'hasta'.
3. Selecciona la opción 'Totales por Día'.
4. Presiona 'Buscar'.
5. El sistema consulta los SP correspondientes y muestra los resultados agrupados por fecha.

**Resultado esperado:**
Se muestra una tabla con la fecha y el total de transmisiones por cada día, y el total general.

**Datos de prueba:**
{ "desde": "2024-01-01", "hasta": "2024-01-31" }

---

