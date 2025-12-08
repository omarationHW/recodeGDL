# DocumentaciÃ³n TÃ©cnica: Adeudos_Pag

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario Adeudos_Pag (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón de Comunicación:** eRequest/eResponse (JSON), desacoplado de la UI.

## Endpoints
- **POST /api/execute**
  - Entrada: `{ eRequest: { action: string, params: {...} } }`
  - Salida: `{ eResponse: { success: bool, data: any, message: string } }`

## Acciones Soportadas
- `ver_adeudos`: Consulta los adeudos de un contrato/periodo.
- `ejecutar_pago`: Marca como pagado los adeudos seleccionados.
- `cancelar`: Cancela la operación (no realiza cambios).
- `cargar_catalogos`: Devuelve catálogos de tipo de aseo, recaudadoras y cajas.

## Stored Procedures
- Toda la lógica de negocio y validación de reglas se implementa en PostgreSQL.
- Los SPs devuelven tablas o mensajes de éxito/error.

## Seguridad
- El endpoint requiere autenticación JWT (no incluido aquí, pero recomendado).
- Validación de parámetros en backend y frontend.

## Flujo de Trabajo
1. El usuario ingresa contrato, tipo de aseo, año y mes.
2. El frontend llama a `ver_adeudos` y muestra los adeudos encontrados.
3. El usuario selecciona qué adeudos pagar, ingresa datos de pago y ejecuta `ejecutar_pago`.
4. El backend actualiza los registros y responde con éxito o error.

## Validaciones
- No se permite pagar si el adeudo ya está pagado.
- No se permite pagar si el contrato no existe o está cancelado.
- Los importes deben coincidir con los mostrados.

## Catálogos
- Los catálogos se cargan al iniciar la página y se usan para poblar selects.

## Errores
- Todos los errores se devuelven en el campo `message` de la respuesta.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los SPs pueden ser versionados y auditados.

## Notas
- El usuario logueado debe ser pasado como `usuario_id` en las acciones que lo requieran.
- El frontend debe manejar los estados de éxito/error y mostrar mensajes amigables.



## Casos de Prueba

## Casos de Prueba para Adeudos_Pag

### Caso 1: Consulta de Adeudos Existentes
- **Entrada:** contrato=12345, tipo_aseo=4, aso=2024, mes=6
- **Acción:** ver_adeudos
- **Esperado:** Respuesta con datos de cuota normal y/o excedencias, status_vigencia='V' o 'P'.

### Caso 2: Pago Correcto de Cuota Normal
- **Entrada:** contrato=12345, tipo_aseo=4, aso=2024, mes=6, consec_oper=1001, folio_rcbo='RCB123', fecha_pagado='2024-06-15', id_rec=2, caja='A', usuario_id=1, pagar_cn=true, importe_cn=500.00, pagar_exe=false
- **Acción:** ejecutar_pago
- **Esperado:** success=true, message='Pago realizado correctamente.'

### Caso 3: Pago Correcto de Excedencias
- **Entrada:** contrato=12345, tipo_aseo=4, aso=2024, mes=6, consec_oper=1001, folio_rcbo='RCB123', fecha_pagado='2024-06-15', id_rec=2, caja='A', usuario_id=1, pagar_cn=false, pagar_exe=true, importe_exe=150.00
- **Acción:** ejecutar_pago
- **Esperado:** success=true, message='Pago realizado correctamente.'

### Caso 4: Intento de Pago de Adeudo Ya Pagado
- **Entrada:** contrato=12345, tipo_aseo=4, aso=2024, mes=6, consec_oper=1002, folio_rcbo='RCB124', fecha_pagado='2024-06-16', id_rec=2, caja='A', usuario_id=1, pagar_cn=true, pagar_exe=false, importe_cn=500.00
- **Acción:** ejecutar_pago
- **Esperado:** success=false, message='No se encontró adeudo de cuota normal vigente para pagar.'

### Caso 5: Consulta de Adeudos Inexistentes
- **Entrada:** contrato=99999, tipo_aseo=4, aso=2024, mes=6
- **Acción:** ver_adeudos
- **Esperado:** success=false, message='No existen adeudos para el periodo seleccionado.'

### Caso 6: Validación de Parámetros Faltantes
- **Entrada:** contrato=, tipo_aseo=, aso=, mes=
- **Acción:** ver_adeudos
- **Esperado:** success=false, message='El campo contrato es obligatorio.'


## Casos de Uso

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



---
**Componente:** `Adeudos_Pag.vue`
**MÃ³dulo:** `aseo_contratado`

