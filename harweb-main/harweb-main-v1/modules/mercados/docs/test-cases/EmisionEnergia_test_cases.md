# Casos de Prueba: Emisión de Recibos de Energía Eléctrica

## Caso 1: Consulta de Emisión
- **Entrada:** { oficina: 1, mercado: 1, axo: 2024, periodo: 6 }
- **Acción:** getEmisionEnergia
- **Esperado:** Respuesta status 'ok', data con lista de locales y detalles de emisión.

## Caso 2: Grabar Emisión (Primera vez)
- **Entrada:** { oficina: 1, mercado: 1, axo: 2024, periodo: 6, usuario: 5 }
- **Acción:** grabarEmisionEnergia
- **Esperado:** Respuesta status 'ok', message 'La Emisión de Energía Eléctrica se grabó correctamente'.

## Caso 3: Grabar Emisión (Duplicado)
- **Entrada:** { oficina: 1, mercado: 1, axo: 2024, periodo: 6, usuario: 5 }
- **Acción:** grabarEmisionEnergia
- **Esperado:** Respuesta status 'error', message 'La Emisión de Energía Eléctrica ya está grabada, NO puedes volver a grabar'.

## Caso 4: Facturación
- **Entrada:** { oficina: 1, mercado: 1, axo: 2024, periodo: 6 }
- **Acción:** facturarEmisionEnergia
- **Esperado:** Respuesta status 'ok', data con información de facturación.

## Caso 5: Validación de Campos Vacíos
- **Entrada:** { oficina: '', mercado: '', axo: '', periodo: '' }
- **Acción:** getEmisionEnergia
- **Esperado:** Respuesta status 'error', message indicando campos requeridos.
