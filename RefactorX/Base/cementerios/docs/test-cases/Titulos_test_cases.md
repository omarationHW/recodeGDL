# Casos de Prueba para Titulos

## Caso 1: Búsqueda de Título Existente
- **Entrada:** fecha=2024-06-01, folio=12345, operacion=6789
- **Acción:** Buscar
- **Esperado:** Devuelve datos completos del título y beneficiario.

## Caso 2: Búsqueda de Título Inexistente
- **Entrada:** fecha=2024-06-01, folio=99999, operacion=1111
- **Acción:** Buscar
- **Esperado:** Mensaje de error 'No se encontró el título.'

## Caso 3: Actualización de Beneficiario
- **Entrada:** control_rcm=12345, titulo=1, fecha=2024-06-01, libro=10, axo=2024, folio=100, nombre='JUAN PEREZ', domicilio='AV. PRINCIPAL 123', colonia='CENTRO', telefono='3312345678', partida='PART-001'
- **Acción:** Actualizar
- **Esperado:** Mensaje de éxito 'Beneficiario actualizado correctamente.'

## Caso 4: Impresión de Título
- **Entrada:** fecha=2024-06-01, folio=12345, operacion=6789
- **Acción:** Imprimir
- **Esperado:** Devuelve datos JSON para impresión (vista previa).

## Caso 5: Validación de Título Existente
- **Entrada:** fecha=2024-06-01, folio=12345, operacion=6789
- **Acción:** Validar
- **Esperado:** exists=true

## Caso 6: Validación de Título Inexistente
- **Entrada:** fecha=2024-06-01, folio=99999, operacion=1111
- **Acción:** Validar
- **Esperado:** exists=false
