## Casos de Prueba Liga Pago Diverso a Transmisión

### Caso 1: Ligar pago completo exitoso
- **Entrada:** fecha=2024-06-01, recaud=1, caja='A', folio=123, folio_transmision=5555, tipo=22
- **Acción:** Buscar pago, buscar transmisión, ligar pago tipo completo
- **Esperado:** status=ok, message='Pago ligado correctamente', transmisión actualizada

### Caso 2: Ligar pago como diferencia
- **Entrada:** fecha=2024-06-01, recaud=1, caja='A', folio=124, folio_transmision=5556, tipo=2
- **Acción:** Buscar pago, buscar transmisión, ligar pago tipo diferencia
- **Esperado:** status=ok, message='Pago ligado correctamente', diferencias_glosa y transmisión actualizadas

### Caso 3: Error por pago inexistente
- **Entrada:** fecha=2024-06-01, recaud=1, caja='A', folio=99999, folio_transmision=5555, tipo=22
- **Acción:** Buscar pago, intentar ligar
- **Esperado:** status=error, message='No existe el pago a ligar'

### Caso 4: Error por transmisión inexistente
- **Entrada:** fecha=2024-06-01, recaud=1, caja='A', folio=123, folio_transmision=99999, tipo=22
- **Acción:** Buscar pago, buscar transmisión, intentar ligar
- **Esperado:** status=error, message='No existe el folio de transmisión'

### Caso 5: Validación de campos obligatorios
- **Entrada:** falta algún campo requerido
- **Acción:** Intentar ligar
- **Esperado:** status=error, message='El campo X es requerido'
