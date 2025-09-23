# Casos de Uso - Rep_Tipos_Aseo

**Categoría:** Form

## Caso de Uso 1: Consulta de Tipos de Aseo ordenados por Control

**Descripción:** El usuario desea ver el listado de tipos de aseo ordenados por número de control.

**Precondiciones:**
El usuario está autenticado y tiene acceso al módulo de reportes.

**Pasos a seguir:**
1. Acceder a la página '/rep-tipos-aseo'.
2. Seleccionar la opción 'Control' en el grupo de ordenamiento.
3. Pulsar el botón 'Vista Previa'.

**Resultado esperado:**
Se muestra una tabla con todos los tipos de aseo ordenados ascendentemente por el campo 'ctrol_aseo'.

**Datos de prueba:**
Tabla ta_16_tipo_aseo con al menos 3 registros distintos.

---

## Caso de Uso 2: Consulta de Tipos de Aseo ordenados por Descripción

**Descripción:** El usuario requiere ver los tipos de aseo ordenados alfabéticamente por descripción.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Acceder a '/rep-tipos-aseo'.
2. Seleccionar 'Descripción' como criterio de orden.
3. Pulsar 'Vista Previa'.

**Resultado esperado:**
La tabla muestra los tipos de aseo ordenados alfabéticamente por el campo 'descripcion'.

**Datos de prueba:**
ta_16_tipo_aseo: {ctrol_aseo: 1, tipo_aseo: 'O', descripcion: 'Ordinario'}, {ctrol_aseo: 2, tipo_aseo: 'H', descripcion: 'Hospitalario'}

---

## Caso de Uso 3: Manejo de error por parámetro inválido

**Descripción:** El usuario o el frontend envía un parámetro de orden inválido.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Realizar una petición POST a /api/execute con {action: 'getTiposAseoReport', params: {order: 99}}.

**Resultado esperado:**
El backend responde con success: false y un mensaje de error indicando que el parámetro es inválido.

**Datos de prueba:**
order=99

---

