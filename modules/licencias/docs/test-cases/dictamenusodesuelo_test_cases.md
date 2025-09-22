# Casos de Prueba para Dictamen de Uso de Suelo

## 1. Alta de constancia exitosa
- **Entrada:** Datos completos y válidos
- **Acción:** POST /api/execute { action: 'create', data: {...} }
- **Resultado esperado:** success=true, folio incrementado, constancia visible en listado

## 2. Alta de constancia con licencia inexistente
- **Entrada:** id_licencia no existe
- **Acción:** POST /api/execute { action: 'create', data: {..., id_licencia: 999999} }
- **Resultado esperado:** success=false, error de integridad referencial

## 3. Cancelación de constancia vigente
- **Entrada:** axo y folio de constancia vigente
- **Acción:** POST /api/execute { action: 'cancel', data: {...} }
- **Resultado esperado:** success=true, vigente='C', observacion actualizado

## 4. Cancelación de constancia ya cancelada
- **Entrada:** axo y folio de constancia con vigente='C'
- **Acción:** POST /api/execute { action: 'cancel', data: {...} }
- **Resultado esperado:** success=false, error "Ya está cancelada"

## 5. Impresión de constancia vigente
- **Entrada:** axo y folio de constancia vigente
- **Acción:** POST /api/execute { action: 'print', data: {...} }
- **Resultado esperado:** success=true, data contiene pdf_url

## 6. Impresión de constancia cancelada
- **Entrada:** axo y folio de constancia con vigente='C'
- **Acción:** POST /api/execute { action: 'print', data: {...} }
- **Resultado esperado:** success=false, error "Constancia cancelada, no se puede imprimir"

## 7. Listado filtrado por licencia
- **Entrada:** licencia existente
- **Acción:** POST /api/execute { action: 'listado', data: { licencia: 1001 } }
- **Resultado esperado:** success=true, listado solo de esa licencia
