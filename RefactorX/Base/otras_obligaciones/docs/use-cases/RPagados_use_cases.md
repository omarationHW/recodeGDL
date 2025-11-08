# Casos de Uso - RPagados

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos realizados para un ID de control válido

**Descripción:** El usuario ingresa un ID de control existente y obtiene la lista de pagos realizados asociados.

**Precondiciones:**
El ID de control existe en la base de datos y tiene pagos registrados con status válidos.

**Pasos a seguir:**
1. Ingresar el ID de control en el campo correspondiente.
2. Presionar el botón 'Buscar'.
3. Esperar la respuesta y visualizar la tabla de pagos.

**Resultado esperado:**
Se muestra una tabla con todos los pagos realizados para ese ID de control.

**Datos de prueba:**
p_Control = 1001 (debe existir en t34_pagos con status 'P', 'S', 'R' o 'D')

---

## Caso de Uso 2: Consulta con un ID de control inexistente

**Descripción:** El usuario ingresa un ID de control que no existe o no tiene pagos asociados.

**Precondiciones:**
El ID de control no existe en la base de datos o no tiene pagos con status válidos.

**Pasos a seguir:**
1. Ingresar el ID de control inexistente.
2. Presionar el botón 'Buscar'.

**Resultado esperado:**
Se muestra un mensaje informando que no se encontraron registros.

**Datos de prueba:**
p_Control = 999999 (no existe en t34_pagos)

---

## Caso de Uso 3: Error por parámetro faltante

**Descripción:** El usuario intenta consultar sin ingresar el ID de control.

**Precondiciones:**
El campo de ID de control está vacío.

**Pasos a seguir:**
1. Dejar el campo de ID de control vacío.
2. Presionar el botón 'Buscar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que el parámetro es requerido.

**Datos de prueba:**
p_Control = '' (vacío)

---

