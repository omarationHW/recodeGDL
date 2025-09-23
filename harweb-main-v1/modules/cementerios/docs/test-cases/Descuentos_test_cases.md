## Casos de Prueba para Descuentos

### Caso 1: Alta de descuento exitoso
- **Entrada**: folio=1234, adeudo axo_adeudo=2024, tipo_descto='A', porcentaje=10
- **Acción**: Aplicar descuento
- **Esperado**: Respuesta ok=true, mensaje 'Descuento dado de alta correctamente', descuento aparece en la lista

### Caso 2: Alta de descuento duplicado
- **Entrada**: folio=1234, adeudo axo_adeudo=2024, tipo_descto='A', porcentaje=10 (ya existe descuento para ese año)
- **Acción**: Aplicar descuento
- **Esperado**: Respuesta ok=false, mensaje 'Ya tiene descuento para el adeudo del año seleccionado, verifique'

### Caso 3: Baja de descuento
- **Entrada**: folio=1234, descuento axo_descto=2024, tipo_descto='A'
- **Acción**: Borrar descuento
- **Esperado**: Respuesta ok=true, mensaje 'Descuento dado de baja correctamente', descuento desaparece de la lista

### Caso 4: Reactivar descuento
- **Entrada**: folio=1234, tipo_descto='A', axo=2025
- **Acción**: Reactivar descuento
- **Esperado**: Respuesta ok=true, mensaje 'Descuento reactivado correctamente', descuento aparece para el año siguiente

### Caso 5: Consulta de folio inexistente
- **Entrada**: folio=999999
- **Acción**: Buscar folio
- **Esperado**: Respuesta ok=false, mensaje 'Registro de fosa no encontrado'
