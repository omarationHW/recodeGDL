## Casos de Prueba GastosTransmision

### Caso 1: Consulta de Folio Existente
- **Entrada:** { "action": "consulta_foliotransm", "params": { "folio": 12345, "opc": "T" } }
- **Esperado:** Respuesta success=true, data con importes y estatus=0.

### Caso 2: Consulta de Folio Inexistente
- **Entrada:** { "action": "consulta_foliotransm", "params": { "folio": 999999, "opc": "T" } }
- **Esperado:** Respuesta success=false, mensaje 'Folio no encontrado', código 404.

### Caso 3: Aplicar Gastos Correctamente
- **Entrada:** { "action": "afecta_gastostransm", "params": { "folio": 12345, "gastos": 500.00, "opc": "T" } }
- **Esperado:** Respuesta success=true, mensaje 'Gastos aplicados correctamente'.

### Caso 4: Aplicar Gastos a Folio Inexistente
- **Entrada:** { "action": "afecta_gastostransm", "params": { "folio": 999999, "gastos": 100.00, "opc": "T" } }
- **Esperado:** Respuesta success=false, mensaje 'Folio no encontrado'.

### Caso 5: Aplicar Gastos con Monto Negativo
- **Entrada:** { "action": "afecta_gastostransm", "params": { "folio": 12345, "gastos": -10.00, "opc": "T" } }
- **Esperado:** Respuesta success=false, mensaje de validación.

### Caso 6: Aplicar Gastos con Tipo de Módulo Inválido
- **Entrada:** { "action": "afecta_gastostransm", "params": { "folio": 12345, "gastos": 100.00, "opc": "X" } }
- **Esperado:** Respuesta success=false, mensaje 'Tipo de módulo inválido'.
