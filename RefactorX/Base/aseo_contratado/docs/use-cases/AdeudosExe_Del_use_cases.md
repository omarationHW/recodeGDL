# Casos de Uso - AdeudosExe_Del

**Categoría:** Form

## Caso de Uso 1: Baja Física de Adeudo (Eliminación Definitiva)

**Descripción:** El usuario desea eliminar definitivamente el registro de pago de un contrato para un periodo y tipo de operación específico.

**Precondiciones:**
El contrato y el registro de pago existen y están vigentes (status_vigencia = 'V'). El usuario tiene permisos.

**Pasos a seguir:**
1. El usuario ingresa al formulario de Baja de Adeudos.
2. Selecciona el contrato, tipo de aseo, año, mes y tipo de operación.
3. Selecciona 'Baja Física'.
4. Da clic en 'Ejecutar'.
5. El sistema envía la petición al endpoint /api/execute con action=delete.
6. El backend ejecuta el stored procedure de baja física.
7. El sistema muestra mensaje de éxito o error.

**Resultado esperado:**
El registro de pago es eliminado de la base de datos. El usuario ve un mensaje de éxito.

**Datos de prueba:**
{ "contrato": 12345, "ctrol_aseo": 9, "aso": 2024, "mes": 6, "ctrol_operacion": 3, "usuario_id": 1 }

---

## Caso de Uso 2: Baja Lógica de Adeudo (Marcar como Baja)

**Descripción:** El usuario desea marcar como baja (status_vigencia = 'B') el registro de pago de un contrato para un periodo y tipo de operación específico.

**Precondiciones:**
El contrato y el registro de pago existen y están vigentes. El usuario tiene permisos.

**Pasos a seguir:**
1. El usuario ingresa al formulario de Baja de Adeudos.
2. Selecciona el contrato, tipo de aseo, año, mes y tipo de operación.
3. Ingresa el número de oficio.
4. Selecciona 'Baja Lógica'.
5. Da clic en 'Ejecutar'.
6. El sistema envía la petición al endpoint /api/execute con action=logic_delete.
7. El backend ejecuta el stored procedure de baja lógica.
8. El sistema muestra mensaje de éxito o error.

**Resultado esperado:**
El registro de pago es actualizado con status_vigencia = 'B', usuario y folio_rcbo. El usuario ve un mensaje de éxito.

**Datos de prueba:**
{ "contrato": 12345, "ctrol_aseo": 9, "aso": 2024, "mes": 6, "ctrol_operacion": 3, "oficio": "OF123456", "usuario_id": 1 }

---

## Caso de Uso 3: Consulta de Contrato para Baja de Adeudo

**Descripción:** El usuario desea consultar los datos básicos del contrato antes de realizar la baja.

**Precondiciones:**
El contrato existe.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y tipo de aseo.
2. El sistema consulta los datos del contrato vía /api/execute con action=list.
3. El sistema muestra los datos del contrato.

**Resultado esperado:**
Se muestran los datos básicos del contrato y unidad de recolección.

**Datos de prueba:**
{ "contrato": 12345, "ctrol_aseo": 9 }

---

