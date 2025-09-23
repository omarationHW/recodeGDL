# Casos de Prueba: Trámite de Baja de Anuncio

## Caso 1: Baja exitosa de anuncio sin adeudos
- **Input:** anuncio=12345, motivo="Cierre de negocio", usuario="admin"
- **Acción:** POST /api/execute { action: 'tramitarBaja', params: {...} }
- **Esperado:** success=true, mensaje de éxito, anuncio en estado cancelado, adeudos cancelados, registro en lic_cancel

## Caso 2: Baja de anuncio ya cancelado
- **Input:** anuncio=54321, motivo="Duplicado", usuario="admin"
- **Acción:** POST /api/execute { action: 'tramitarBaja', params: {...} }
- **Esperado:** success=false, mensaje de error "El anuncio ya se encuentra cancelado."

## Caso 3: Baja de anuncio con adeudos y permiso especial
- **Input:** anuncio=67890, motivo="Error administrativo", usuario="supervisor", baja_error=true
- **Acción:** POST /api/execute { action: 'tramitarBaja', params: {...} }
- **Esperado:** success=true, mensaje de éxito, anuncio cancelado, adeudos cancelados, registro en lic_cancel

## Caso 4: Buscar anuncio inexistente
- **Input:** anuncio=99999
- **Acción:** POST /api/execute { action: 'buscarAnuncio', params: { anuncio: 99999 } }
- **Esperado:** success=false, mensaje de error "No se encontró el anuncio"

## Caso 5: Validación de campos obligatorios
- **Input:** anuncio='', motivo='', usuario=''
- **Acción:** POST /api/execute { action: 'tramitarBaja', params: {...} }
- **Esperado:** success=false, mensaje de error de validación
