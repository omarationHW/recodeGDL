## Casos de Prueba para Contratos_Upd_Und

### 1. Actualización exitosa
- **Entrada**: Contrato vigente, cantidad válida (>0), documento válido.
- **Acción**: Ejecutar acción 'actualizar_unidades' con datos correctos.
- **Esperado**: Respuesta success=true, message='Actualización exitosa.'

### 2. Contrato no existe o no vigente
- **Entrada**: Contrato inexistente o cancelado.
- **Acción**: Ejecutar acción 'buscar_contrato' con número inválido.
- **Esperado**: Respuesta success=false, message='No existe contrato vigente con esos datos.'

### 3. Cantidad inválida
- **Entrada**: cantidad=0
- **Acción**: Ejecutar acción 'actualizar_unidades' con cantidad=0
- **Esperado**: Respuesta success=false, message='Cantidad inválida.'

### 4. Documento vacío
- **Entrada**: documento=''
- **Acción**: Ejecutar acción 'actualizar_unidades' sin documento
- **Esperado**: Respuesta success=false, message='Documento requerido.'

### 5. Ejercicio sin costo de unidad
- **Entrada**: ejercicio sin registro en ta_16_unidades
- **Acción**: Ejecutar acción 'actualizar_unidades' con ejercicio inexistente
- **Esperado**: Respuesta success=false, message='No existe costo de unidad para el ejercicio actual.'

### 6. Catálogo de tipos de aseo
- **Entrada**: acción 'catalogo_tipo_aseo'
- **Esperado**: Lista de tipos de aseo

### 7. Catálogo de unidades
- **Entrada**: acción 'catalogo_unidades', ejercicio=2024
- **Esperado**: Lista de unidades para el ejercicio 2024
