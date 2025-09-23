# Casos de Uso - ConsultaGeneral

**Categoría:** Form

## Caso de Uso 1: Búsqueda de Local Existente

**Descripción:** El usuario busca un local existente ingresando todos los parámetros requeridos.

**Precondiciones:**
El local existe en la base de datos con los parámetros proporcionados.

**Pasos a seguir:**
1. El usuario ingresa los datos de recaudadora, mercado, categoría, sección, local, letra y bloque.
2. Presiona el botón 'Buscar'.
3. El sistema envía la petición a /api/execute con eRequest 'buscar_local'.
4. El backend retorna el local encontrado.

**Resultado esperado:**
El local aparece en la tabla de resultados y puede consultarse su detalle.

**Datos de prueba:**
{ "oficina": 1, "num_mercado": 10, "categoria": 2, "seccion": "SS", "local": 5, "letra_local": null, "bloque": null }

---

## Caso de Uso 2: Consulta de Detalle de Local

**Descripción:** El usuario selecciona un local de la lista y consulta su detalle.

**Precondiciones:**
El local fue previamente encontrado en la búsqueda.

**Pasos a seguir:**
1. El usuario hace clic en 'Detalle' de un local.
2. El sistema envía la petición a /api/execute con eRequest 'detalle_local' y el id_local.
3. El backend retorna los datos completos del local.

**Resultado esperado:**
Se muestra la información completa del local, incluyendo mercado, nombre, arrendatario, domicilio, sector, zona, descripción, superficie, giro, fechas, vigencia, usuario y renta.

**Datos de prueba:**
{ "id_local": 123 }

---

## Caso de Uso 3: Visualización de Adeudos, Pagos y Requerimientos

**Descripción:** El usuario navega entre las pestañas de Adeudos, Pagos y Requerimientos para un local.

**Precondiciones:**
El usuario está visualizando el detalle de un local.

**Pasos a seguir:**
1. El usuario selecciona la pestaña 'Adeudos'.
2. El sistema solicita los adeudos vía /api/execute eRequest 'adeudos_local'.
3. El usuario selecciona la pestaña 'Pagos'.
4. El sistema solicita los pagos vía /api/execute eRequest 'pagos_local'.
5. El usuario selecciona la pestaña 'Requerimientos'.
6. El sistema solicita los requerimientos vía /api/execute eRequest 'requerimientos_local'.

**Resultado esperado:**
Se muestran correctamente los datos de cada sección.

**Datos de prueba:**
{ "id_local": 123 }

---

