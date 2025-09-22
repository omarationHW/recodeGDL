# Casos de Uso - ActCont_CR

**Categoría:** Form

## Caso de Uso 1: Consulta de contratos por tipo de aseo: Zona Centro

**Descripción:** El usuario desea ver todos los contratos de recolección correspondientes al tipo 'Zona Centro' (valor 9).

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen contratos con tipo_aseo = 9 en la tabla ta.

**Pasos a seguir:**
1. El usuario accede a la página 'Actualiza Contratos en Cantidad de Recolección'.
2. Selecciona '9 .- Zona Centro' en el selector de tipo de aseo.
3. Presiona el botón 'Consultar Contratos'.
4. El sistema consulta la API y muestra los contratos filtrados.

**Resultado esperado:**
Se muestra una tabla con todos los contratos cuyo tipo de aseo es 9.

**Datos de prueba:**
En la tabla ta, existen registros con tipo_aseo = 9.

---

## Caso de Uso 2: Consulta de contratos por tipo de aseo: Ordinarios

**Descripción:** El usuario consulta los contratos de tipo 'Ordinarios' (valor 8).

**Precondiciones:**
El usuario tiene acceso y existen contratos con tipo_aseo = 8.

**Pasos a seguir:**
1. Acceder a la página.
2. Seleccionar '8 .- Ordinarios'.
3. Hacer clic en 'Consultar Contratos'.

**Resultado esperado:**
Se listan los contratos con tipo_aseo = 8.

**Datos de prueba:**
En la tabla ta, existen registros con tipo_aseo = 8.

---

## Caso de Uso 3: Consulta sin resultados para tipo de aseo: Hospitalarios

**Descripción:** El usuario consulta contratos para 'Hospitalarios' (valor 4), pero no existen registros.

**Precondiciones:**
No existen contratos con tipo_aseo = 4 en la tabla ta.

**Pasos a seguir:**
1. Acceder a la página.
2. Seleccionar '4 .- Hospitalarios'.
3. Hacer clic en 'Consultar Contratos'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no se encontraron contratos.

**Datos de prueba:**
La tabla ta no contiene registros con tipo_aseo = 4.

---

