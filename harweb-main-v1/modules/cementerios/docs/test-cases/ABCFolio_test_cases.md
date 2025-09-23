# Casos de Prueba ABCFolio

## 1. Consulta de Folio Existente
- **Entrada:** { "eRequest": { "action": "get", "folio": 12345 } }
- **Esperado:** eResponse.success = true, eResponse.data.folio.control_rcm = 12345

## 2. Consulta de Folio Inexistente
- **Entrada:** { "eRequest": { "action": "get", "folio": 99999 } }
- **Esperado:** eResponse.success = false, eResponse.message = "Folio no encontrado"

## 3. Modificación de Datos Correcta
- **Entrada:** { "eRequest": { "action": "update", "folio": 12345, "nombre": "JUAN PEREZ", ... } }
- **Esperado:** eResponse.success = true, eResponse.message = "Registro actualizado"

## 4. Modificación de Datos Adicionales (Insert)
- **Entrada:** { "eRequest": { "action": "updateAdicional", "folio": 12345, "telefono": "3312345678", "rfc": "PEPJ800101XXX", "curp": "PEPJ800101HJCXXX01", "clave_ife": "ABC123456789" } }
- **Esperado:** eResponse.success = true, eResponse.message = "Datos adicionales actualizados"

## 5. Baja Lógica de Folio
- **Entrada:** { "eRequest": { "action": "delete", "folio": 12345 } }
- **Esperado:** eResponse.success = true, eResponse.message = "Registro dado de baja"

## 6. Eliminación de Datos Adicionales
- **Entrada:** { "eRequest": { "action": "deleteAdicional", "folio": 12345 } }
- **Esperado:** eResponse.success = true, eResponse.message = "Registro adicional eliminado"

## 7. Validación de Campos Obligatorios
- **Entrada:** { "eRequest": { "action": "update", "folio": 12345, "nombre": "" } }
- **Esperado:** eResponse.success = false, eResponse.message contiene "nombre es obligatorio"

## 8. Seguridad: Acceso sin token
- **Entrada:** Sin autenticación
- **Esperado:** HTTP 401 Unauthorized
