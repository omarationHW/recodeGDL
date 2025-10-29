# Casos de Uso - Prueba

**Categoría:** Form

## Caso de Uso 1: Consulta de Contratos por Control de Aseo

**Descripción:** El usuario ingresa un valor de control de aseo y obtiene la lista de contratos y tipos de aseo asociados.

**Precondiciones:**
El usuario tiene acceso a la aplicación y permisos para consultar.

**Pasos a seguir:**
1. El usuario accede a la página Prueba.
2. Ingresa el valor '9' en el campo Control Aseo.
3. Presiona el botón 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los contratos cuyo ctrol_aseo=9 y num_contrato>=2120.

**Datos de prueba:**
parCtrol: 9

---

## Caso de Uso 2: Consulta de Licencia de Giro para un Contrato

**Descripción:** El usuario consulta la licencia de giro asociada a un contrato específico desde la tabla de resultados.

**Precondiciones:**
Se ha realizado una consulta previa y hay resultados en la tabla.

**Pasos a seguir:**
1. El usuario presiona el botón 'Consultar Licencia' en la fila deseada.

**Resultado esperado:**
Se muestra el resultado del stored procedure (mensaje de éxito o error según si existe relación de licencia).

**Datos de prueba:**
p_tipo: 'O', p_numero: 2125

---

## Caso de Uso 3: Error por Falta de Parámetro

**Descripción:** El usuario intenta consultar sin ingresar el parámetro requerido.

**Precondiciones:**
El usuario accede a la página Prueba.

**Pasos a seguir:**
1. El usuario deja el campo Control Aseo vacío.
2. Presiona el botón 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que falta el parámetro.

**Datos de prueba:**
parCtrol: ''

---

