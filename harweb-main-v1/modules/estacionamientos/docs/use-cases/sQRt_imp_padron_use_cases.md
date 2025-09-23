# Casos de Uso - sQRt_imp_padron

**Categoría:** Form

## Caso de Uso 1: Consulta de Padrón Vehicular por Rango de IDs

**Descripción:** El usuario ingresa un rango de IDs y obtiene el listado de vehículos registrados en ese rango.

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen registros en la tabla ta_padron con IDs dentro del rango.

**Pasos a seguir:**
1. Acceder a la página de Padrón Vehicular.
2. Ingresar un valor para 'ID Inicial' (por ejemplo, 100).
3. Ingresar un valor para 'ID Final' (por ejemplo, 110).
4. Presionar el botón 'Buscar'.
5. Visualizar la tabla con los registros encontrados.

**Resultado esperado:**
Se muestra una tabla con los vehículos cuyo ID está entre 100 y 110, inclusive.

**Datos de prueba:**
id1: 100, id2: 110

---

## Caso de Uso 2: Consulta sin Resultados

**Descripción:** El usuario ingresa un rango de IDs para el cual no existen registros.

**Precondiciones:**
El usuario tiene acceso a la aplicación y el rango de IDs no corresponde a ningún registro.

**Pasos a seguir:**
1. Acceder a la página de Padrón Vehicular.
2. Ingresar 'ID Inicial' = 999999.
3. Ingresar 'ID Final' = 1000000.
4. Presionar 'Buscar'.

**Resultado esperado:**
Se muestra un mensaje indicando que no hay resultados para mostrar.

**Datos de prueba:**
id1: 999999, id2: 1000000

---

## Caso de Uso 3: Error por Parámetros Faltantes

**Descripción:** El usuario intenta consultar el reporte sin ingresar uno de los parámetros requeridos.

**Precondiciones:**
El usuario tiene acceso a la aplicación.

**Pasos a seguir:**
1. Acceder a la página de Padrón Vehicular.
2. Dejar vacío el campo 'ID Inicial'.
3. Ingresar 'ID Final' = 200.
4. Presionar 'Buscar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que faltan parámetros.

**Datos de prueba:**
id1: '', id2: 200

---

