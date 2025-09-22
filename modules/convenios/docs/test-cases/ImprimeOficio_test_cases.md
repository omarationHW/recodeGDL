## Casos de Prueba para ImprimeOficio

### Caso 1: Búsqueda exitosa de convenio
- **Entrada:** letras='ZC1', numero=123, axo=2024, tipo=1
- **Acción:** Buscar
- **Resultado esperado:** Status 'ok', convenio y firma retornados, botones de impresión habilitados.

### Caso 2: Convenio no existe
- **Entrada:** letras='XXX', numero=9999, axo=2024, tipo=1
- **Acción:** Buscar
- **Resultado esperado:** Status 'not_found', mensaje 'No existe el convenio o no está vigente'.

### Caso 3: Convenio con parcialidades sin desglose
- **Entrada:** letras='ZO2', numero=456, axo=2023, tipo=2
- **Acción:** Buscar
- **Resultado esperado:** Status 'error', mensaje 'Existen parcialidades que no tienen el desglose de cuentas...'.

### Caso 4: Impresión de oficio
- **Precondición:** Convenio válido y sin errores
- **Acción:** Imprimir Oficio
- **Resultado esperado:** Status 'ok', pdf_url retornada, PDF visible en pantalla.

### Caso 5: Impresión de pagaré
- **Precondición:** Convenio válido y sin errores
- **Acción:** Imprimir Pagaré
- **Resultado esperado:** Status 'ok', pdf_url retornada, PDF visible en pantalla.

### Caso 6: Error de parámetros
- **Entrada:** letras='', numero='', axo='', tipo=''
- **Acción:** Buscar
- **Resultado esperado:** Status 'error', mensaje de validación.

### Caso 7: Acceso sin autenticación
- **Acción:** Cualquier operación
- **Resultado esperado:** Status HTTP 401 Unauthorized.
