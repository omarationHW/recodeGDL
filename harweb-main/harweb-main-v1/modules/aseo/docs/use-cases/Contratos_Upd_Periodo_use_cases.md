# Casos de Uso - Contratos_Upd_Periodo

**Categoría:** Form

## Caso de Uso 1: Consulta de Contrato para Actualización de Periodo

**Descripción:** El usuario consulta un contrato existente para visualizar su periodo de inicio de obligación actual.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta. El contrato existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de actualización de periodo de obligación.
2. Ingresa el número de contrato y selecciona el tipo de aseo.
3. Presiona el botón 'Buscar'.
4. El sistema muestra los datos del contrato, incluyendo el periodo de inicio de obligación.

**Resultado esperado:**
Se muestran correctamente los datos del contrato y el periodo de inicio de obligación actual.

**Datos de prueba:**
{ "num_contrato": 1803, "ctrol_aseo": 8 }

---

## Caso de Uso 2: Actualización Exitosa del Periodo de Inicio de Obligación

**Descripción:** El usuario actualiza el periodo de inicio de obligación de un contrato, registrando el documento y la descripción justificativa.

**Precondiciones:**
El usuario está autenticado y tiene permisos de actualización. El contrato existe y el nuevo periodo es diferente al actual.

**Pasos a seguir:**
1. El usuario consulta el contrato como en el caso anterior.
2. Ingresa el nuevo año y mes, el documento y la descripción.
3. Presiona el botón 'Actualizar Periodo'.
4. El sistema valida los datos y ejecuta la actualización.
5. El sistema muestra un mensaje de éxito.

**Resultado esperado:**
El periodo de inicio de obligación se actualiza correctamente y se registra en el histórico.

**Datos de prueba:**
{ "control_contrato": 5678, "anio": 2024, "mes": "03", "documento": "DR/14/2024", "descripcion": "Cambio por resolución administrativa" }

---

## Caso de Uso 3: Intento de Actualización con el Mismo Periodo

**Descripción:** El usuario intenta actualizar el periodo de inicio de obligación al mismo periodo actual.

**Precondiciones:**
El usuario está autenticado. El contrato existe y el periodo ingresado es igual al actual.

**Pasos a seguir:**
1. El usuario consulta el contrato.
2. Ingresa el mismo año y mes que el periodo actual.
3. Ingresa documento y descripción.
4. Presiona 'Actualizar Periodo'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el periodo es igual al actual y no realiza cambios.

**Datos de prueba:**
{ "control_contrato": 5678, "anio": 2023, "mes": "01", "documento": "DR/14/2023", "descripcion": "Intento sin cambio" }

---

