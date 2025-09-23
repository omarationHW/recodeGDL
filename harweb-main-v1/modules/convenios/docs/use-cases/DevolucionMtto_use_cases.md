# Casos de Uso - DevolucionMtto

**Categoría:** Form

## Caso de Uso 1: Alta de devolución de pago para contrato vigente

**Descripción:** El usuario busca un contrato vigente y registra una nueva devolución de pago.

**Precondiciones:**
El contrato existe y está vigente. El usuario tiene permisos.

**Pasos a seguir:**
1. Ingresar colonia, calle y folio válidos.
2. Pulsar 'Buscar'.
3. Verificar que aparecen los datos del contrato y devoluciones existentes.
4. Llenar el formulario de nueva devolución (remesa, oficio, folio, fecha, importe, etc).
5. Pulsar 'Agregar'.

**Resultado esperado:**
La devolución se agrega y aparece en la lista. Mensaje de éxito.

**Datos de prueba:**
{ "colonia": 1, "calle": 2, "folio": 123, "remesa": "R-2024-01", "oficio": "OF-123", "folio_dev": "F-001", "fecha_solicitud": "2024-06-01", "rfc": "XAXX010101000", "importe": 1500.00, "observacion": "Devolución por saldo a favor" }

---

## Caso de Uso 2: Modificación de devolución existente

**Descripción:** El usuario edita una devolución ya registrada para corregir el importe.

**Precondiciones:**
Existe al menos una devolución para el contrato.

**Pasos a seguir:**
1. Buscar contrato y visualizar devoluciones.
2. Pulsar 'Editar' en la devolución deseada.
3. Cambiar el importe y/o campos requeridos.
4. Pulsar 'Modificar'.

**Resultado esperado:**
La devolución se actualiza correctamente. Mensaje de éxito.

**Datos de prueba:**
{ "id_devolucion": 5, "remesa": "R-2024-01", "oficio": "OF-123", "folio": "F-001", "fecha_solicitud": "2024-06-01", "rfc": "XAXX010101000", "importe": 2000.00, "observacion": "Corrección de importe" }

---

## Caso de Uso 3: Eliminación de devolución

**Descripción:** El usuario elimina una devolución registrada por error.

**Precondiciones:**
Existe al menos una devolución para el contrato.

**Pasos a seguir:**
1. Buscar contrato y visualizar devoluciones.
2. Pulsar 'Eliminar' en la devolución deseada.
3. Confirmar la eliminación.

**Resultado esperado:**
La devolución desaparece de la lista. Mensaje de éxito.

**Datos de prueba:**
{ "id_devolucion": 5 }

---

