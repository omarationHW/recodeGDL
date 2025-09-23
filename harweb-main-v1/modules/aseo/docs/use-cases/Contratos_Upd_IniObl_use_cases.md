# Casos de Uso - Contratos_Upd_IniObl

**Categoría:** Form

## Caso de Uso 1: Actualizar inicio de obligación de un contrato vigente

**Descripción:** El usuario desea cambiar el periodo de inicio de obligación de un contrato vigente, generando los pagos correspondientes y registrando el documento probatorio.

**Precondiciones:**
El contrato existe y está vigente. El usuario tiene permisos.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. Presiona 'Buscar'.
3. El sistema muestra los datos del contrato.
4. El usuario selecciona el nuevo ejercicio y mes de inicio de obligación, ingresa el documento y descripción.
5. Presiona 'Actualizar'.
6. El sistema ejecuta el proceso y muestra mensaje de éxito.

**Resultado esperado:**
El inicio de obligación del contrato se actualiza, los pagos anteriores se eliminan, se generan nuevos pagos y se registra el documento.

**Datos de prueba:**
{ "num_contrato": 1803, "ctrol_aseo": 8, "ejercicio": 2024, "mes": 7, "documento": "DR/2024/07/001", "descripcion_docto": "Cambio por resolución administrativa", "usuario_id": 5 }

---

## Caso de Uso 2: Intentar actualizar con contrato inexistente

**Descripción:** El usuario intenta actualizar el inicio de obligación de un contrato que no existe o no está vigente.

**Precondiciones:**
El contrato no existe o está cancelado.

**Pasos a seguir:**
1. El usuario ingresa un número de contrato inexistente y tipo de aseo.
2. Presiona 'Buscar'.
3. El sistema muestra mensaje de error.

**Resultado esperado:**
El sistema indica que el contrato no existe o no está vigente.

**Datos de prueba:**
{ "num_contrato": 999999, "ctrol_aseo": 8 }

---

## Caso de Uso 3: Validar campos obligatorios antes de actualizar

**Descripción:** El usuario intenta actualizar sin llenar todos los campos requeridos.

**Precondiciones:**
El contrato existe y está vigente.

**Pasos a seguir:**
1. El usuario busca el contrato correctamente.
2. Deja vacío el campo 'documento' y presiona 'Actualizar'.
3. El sistema muestra mensaje de validación.

**Resultado esperado:**
El sistema no permite la actualización y muestra mensaje de campo obligatorio.

**Datos de prueba:**
{ "num_contrato": 1803, "ctrol_aseo": 8, "ejercicio": 2024, "mes": 7, "documento": "", "descripcion_docto": "", "usuario_id": 5 }

---

