# Casos de Uso - Adeudos_OpcMult

**Categoría:** Form

## Caso de Uso 1: Caso de Uso 1: Dar de Pagado Adeudos Múltiples

**Descripción:** El usuario busca un contrato vigente, selecciona varios adeudos y los marca como pagados.

**Precondiciones:**
El contrato existe y tiene adeudos vigentes.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. Presiona 'Buscar'.
3. El sistema muestra los datos del contrato y los adeudos vigentes.
4. El usuario selecciona varios adeudos en la tabla.
5. Elige la opción 'P - DAR DE PAGADO', ingresa fecha, recaudadora, caja, consecutivo de operación, folio y observaciones.
6. Presiona 'Ejecutar'.

**Resultado esperado:**
Los adeudos seleccionados cambian su estado a 'P' (Pagado) y desaparecen de la lista de adeudos vigentes.

**Datos de prueba:**
{ "num_contrato": 12345, "ctrol_aseo": 9, "opcion": "P", "fecha": "2024-06-01", "reca": 1, "caja": "A", "operacion": 123456, "folio_rcbo": "RCB123", "obs": "Pago masivo", "usuario": 1 }

---

## Caso de Uso 2: Caso de Uso 2: Condonar Adeudo Individual

**Descripción:** El usuario condona un adeudo específico de un contrato.

**Precondiciones:**
El contrato existe y tiene al menos un adeudo vigente.

**Pasos a seguir:**
1. El usuario busca el contrato.
2. Selecciona un solo adeudo.
3. Elige la opción 'S - CONDONAR', ingresa fecha, recaudadora, caja, folio y observaciones.
4. Presiona 'Ejecutar'.

**Resultado esperado:**
El adeudo seleccionado cambia su estado a 'S' (Condonado).

**Datos de prueba:**
{ "num_contrato": 54321, "ctrol_aseo": 4, "opcion": "S", "fecha": "2024-06-02", "reca": 2, "caja": "B", "operacion": 0, "folio_rcbo": "COND001", "obs": "Condonación por convenio", "usuario": 2 }

---

## Caso de Uso 3: Caso de Uso 3: Cancelar Adeudos con Observaciones

**Descripción:** El usuario cancela varios adeudos y deja una observación.

**Precondiciones:**
El contrato existe y tiene adeudos vigentes.

**Pasos a seguir:**
1. El usuario busca el contrato.
2. Selecciona varios adeudos.
3. Elige la opción 'C - CANCELAR', ingresa fecha, recaudadora, caja, folio y observaciones.
4. Presiona 'Ejecutar'.

**Resultado esperado:**
Los adeudos seleccionados cambian su estado a 'C' (Cancelado) y la observación queda registrada.

**Datos de prueba:**
{ "num_contrato": 67890, "ctrol_aseo": 8, "opcion": "C", "fecha": "2024-06-03", "reca": 3, "caja": "C", "operacion": 0, "folio_rcbo": "CANCEL01", "obs": "Cancelación administrativa", "usuario": 3 }

---

