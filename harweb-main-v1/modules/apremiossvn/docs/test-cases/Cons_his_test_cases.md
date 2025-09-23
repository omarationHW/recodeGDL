## Casos de Prueba para Formulario Cons_his

### Caso 1: Consulta exitosa de folio existente
- **Entrada:** control=123
- **Acción:** Navegar a /cons-his/123
- **Esperado:** Se muestran todos los campos del folio, detalles y referencia (si aplica).

### Caso 2: Consulta de folio con referencia de mercado
- **Entrada:** control=456 (módulo=11, control_otr válido)
- **Acción:** Navegar a /cons-his/456
- **Esperado:** Se muestra la referencia del mercado en datos generales.

### Caso 3: Consulta de folio inexistente
- **Entrada:** control=99999
- **Acción:** Navegar a /cons-his/99999
- **Esperado:** Se muestra mensaje de error "No se encontró información para el control especificado."

### Caso 4: Consulta de folio con referencia de aseo
- **Entrada:** control=789 (módulo=16, control_otr válido)
- **Acción:** Navegar a /cons-his/789
- **Esperado:** Se muestra la referencia de aseo en datos generales.

### Caso 5: Error de parámetros
- **Entrada:** control no enviado
- **Acción:** Navegar a /cons-his/ (sin parámetro)
- **Esperado:** Se muestra mensaje de error "Falta el parámetro control en la URL"
