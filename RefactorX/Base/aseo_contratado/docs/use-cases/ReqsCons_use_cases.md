# Casos de Uso - ReqsCons

**Categoría:** Form

## Caso de Uso 1: Consulta de Requerimientos de un Contrato Vigente

**Descripción:** El usuario consulta los requerimientos (apremios) asociados a un contrato vigente.

**Precondiciones:**
El contrato existe y tiene status_vigencia = 'V'.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Requerimientos.
2. Ingresa el número de contrato y selecciona el tipo de aseo.
3. Presiona 'Buscar'.
4. El sistema muestra los datos del contrato y la lista de apremios asociados.

**Resultado esperado:**
Se muestran los apremios del contrato, incluyendo folio, importes y fechas.

**Datos de prueba:**
{ "contrato": 12345, "ctrol_aseo": 9 }

---

## Caso de Uso 2: Registro de Pago de un Apremio

**Descripción:** El usuario registra el pago de un apremio seleccionado.

**Precondiciones:**
El apremio está vigente (vigencia = '1') y no ha sido pagado.

**Pasos a seguir:**
1. El usuario busca el contrato y selecciona un apremio de la lista.
2. Presiona 'Pagar'.
3. Completa los datos de pago (fecha, recaudadora, caja, operación, folio).
4. Presiona 'Ejecutar Pago'.

**Resultado esperado:**
El apremio se marca como pagado y se actualiza la lista.

**Datos de prueba:**
{ "contrato": 12345, "ctrol_aseo": 9, "apremio_id": 1001, "pago": { "fecha": "2024-06-01", "id_rec": 1, "caja": "01", "operacion": 123, "folio_rcbo": "RCB123", "importe_gastos": 500.00 } }

---

## Caso de Uso 3: Consulta de Convenio Asociado a un Contrato

**Descripción:** El usuario consulta si un contrato tiene convenio asociado.

**Precondiciones:**
El contrato tiene status_vigencia = 'N' y existe convenio.

**Pasos a seguir:**
1. El usuario busca el contrato.
2. El sistema detecta status_vigencia = 'N' y consulta el convenio.
3. Se muestra el convenio en la interfaz.

**Resultado esperado:**
Se muestra el convenio asociado al contrato.

**Datos de prueba:**
{ "contrato": 54321, "ctrol_aseo": 8 }

---

