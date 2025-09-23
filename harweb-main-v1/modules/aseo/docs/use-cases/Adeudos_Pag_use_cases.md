# Casos de Uso - Adeudos_Pag

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos Vigentes para un Contrato

**Descripción:** El usuario desea consultar los adeudos (cuota normal y excedencias) de un contrato específico para un periodo determinado.

**Precondiciones:**
El contrato existe y tiene adeudos vigentes en el periodo solicitado.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato, selecciona el tipo de aseo, año y mes.
2. Presiona el botón 'Ver Adeudos'.
3. El sistema muestra los adeudos encontrados (cuota normal y/o excedencias), indicando si están pagados o no.

**Resultado esperado:**
Se muestran los adeudos vigentes y su estado (pagado/no pagado), permitiendo seleccionar cuáles pagar.

**Datos de prueba:**
{ contrato: 12345, tipo_aseo: 4, aso: 2024, mes: 6 }

---

## Caso de Uso 2: Pago de Cuota Normal y Excedencias

**Descripción:** El usuario realiza el pago de ambos adeudos (cuota normal y excedencias) para un contrato y periodo.

**Precondiciones:**
Existen adeudos vigentes de ambos tipos para el contrato y periodo.

**Pasos a seguir:**
1. El usuario consulta los adeudos como en el caso anterior.
2. Selecciona ambos checkboxes (cuota normal y excedencias).
3. Ingresa los datos de pago: fecha, recaudadora, caja, consecutivo de operación, folio de recibo.
4. Presiona 'Ejecutar Pago'.

**Resultado esperado:**
Ambos adeudos se marcan como pagados, se actualizan los importes y se registra la información de pago.

**Datos de prueba:**
{ contrato: 12345, tipo_aseo: 4, aso: 2024, mes: 6, consec_oper: 1001, folio_rcbo: 'RCB123', fecha_pagado: '2024-06-15', id_rec: 2, caja: 'A', usuario_id: 1, pagar_cn: true, pagar_exe: true, importe_cn: 500.00, importe_exe: 150.00 }

---

## Caso de Uso 3: Intento de Pago de Adeudo Ya Pagado

**Descripción:** El usuario intenta pagar un adeudo que ya está marcado como pagado.

**Precondiciones:**
El adeudo de cuota normal para el contrato y periodo ya está pagado.

**Pasos a seguir:**
1. El usuario consulta los adeudos.
2. El sistema muestra que la cuota normal ya está pagada (checkbox deshabilitado).
3. El usuario intenta ejecutar el pago de la cuota normal nuevamente.

**Resultado esperado:**
El sistema rechaza la operación y muestra un mensaje de error indicando que el adeudo ya está pagado.

**Datos de prueba:**
{ contrato: 12345, tipo_aseo: 4, aso: 2024, mes: 6, consec_oper: 1002, folio_rcbo: 'RCB124', fecha_pagado: '2024-06-16', id_rec: 2, caja: 'A', usuario_id: 1, pagar_cn: true, pagar_exe: false, importe_cn: 500.00 }

---

