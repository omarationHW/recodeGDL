# Casos de Uso - ConsGral

**Categoría:** Form

## Caso de Uso 1: Consulta de folios por placa existente

**Descripción:** El usuario ingresa una placa válida que existe en la base de datos y consulta los folios asociados.

**Precondiciones:**
La placa 'ABC1234' existe en las tablas ta14_datos_edo y/o ta14_datos_mpio.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta General de Placas.
2. Ingresa 'ABC1234' en el campo de placa.
3. Presiona el botón 'Buscar'.
4. El sistema consulta ambos SP y muestra los resultados en la tabla.

**Resultado esperado:**
Se muestran todos los folios asociados a la placa 'ABC1234', incluyendo información de ambos orígenes.

**Datos de prueba:**
placa: 'ABC1234'

---

## Caso de Uso 2: Consulta de placa inexistente

**Descripción:** El usuario ingresa una placa que no existe en la base de datos.

**Precondiciones:**
La placa 'ZZZ9999' no existe en ninguna de las tablas consultadas.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta General de Placas.
2. Ingresa 'ZZZ9999' en el campo de placa.
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
El sistema muestra la tabla vacía o un mensaje de 'Sin resultados'.

**Datos de prueba:**
placa: 'ZZZ9999'

---

## Caso de Uso 3: Validación de campo requerido

**Descripción:** El usuario intenta buscar sin ingresar ningún valor en el campo de placa.

**Precondiciones:**
El usuario está en la página de Consulta General de Placas.

**Pasos a seguir:**
1. El usuario deja el campo de placa vacío.
2. Presiona el botón 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el campo placa es requerido.

**Datos de prueba:**
placa: ''

---

