# Casos de Prueba para Solicitud de Número Oficial

## Caso 1: Alta exitosa
- **Entrada:** propietario='JUAN PEREZ', actividad='COMERCIO', ubicacion='AV. JUAREZ 123', zona=1, subzona=2
- **Acción:** create
- **Esperado:** success=true, data.axo=2024, data.folio=auto, data.vigente='V'

## Caso 2: Alta con campos faltantes
- **Entrada:** propietario='', actividad='COMERCIO', ubicacion='AV. JUAREZ 123', zona=1, subzona=2
- **Acción:** create
- **Esperado:** success=false, message='El campo propietario es obligatorio'

## Caso 3: Búsqueda por propietario
- **Entrada:** type='propietario', value='JUAN'
- **Acción:** search
- **Esperado:** success=true, data incluye solicitudes con propietario que contiene 'JUAN'

## Caso 4: Modificación exitosa
- **Entrada:** axo=2024, folio=5, data={propietario:'JUAN LOPEZ', actividad:'SERVICIOS', ubicacion:'AV. JUAREZ 123', zona:1, subzona:2}
- **Acción:** update
- **Esperado:** success=true, data.propietario='JUAN LOPEZ'

## Caso 5: Cancelación exitosa
- **Entrada:** axo=2024, folio=5
- **Acción:** cancel
- **Esperado:** success=true, data.vigente='C'

## Caso 6: Impresión
- **Entrada:** axo=2024, folio=5
- **Acción:** print
- **Esperado:** success=true, data.pdf_url='/pdf/solicnooficial/2024-5.pdf'
