## Casos de Prueba: Actualización de Unidades de Recolección

### Caso 1: Actualización exitosa
- **Entrada:**
  - contrato: 1803
  - ctrol_aseo: 8
  - nueva_cantidad: 12
  - ejercicio: 2024
  - mes: 6
  - documento: 'DR/2024/06/01'
  - descripcion_docto: 'Cambio por ampliación de servicio'
- **Acción:** Ejecutar acción 'actualizarUnidades' vía API.
- **Esperado:**
  - Respuesta success: true
  - Mensaje: 'Unidades actualizadas correctamente.'
  - En base de datos, la cantidad y pagos futuros reflejan el cambio.

### Caso 2: Cantidad inválida
- **Entrada:**
  - nueva_cantidad: 0
- **Acción:** Ejecutar acción 'actualizarUnidades'.
- **Esperado:**
  - Respuesta success: false
  - Mensaje: 'La cantidad debe ser mayor a cero.'

### Caso 3: Documento vacío
- **Entrada:**
  - documento: ''
- **Acción:** Ejecutar acción 'actualizarUnidades'.
- **Esperado:**
  - Respuesta success: false
  - Mensaje: 'Debe proporcionar un documento probatorio.'

### Caso 4: Contrato no vigente
- **Entrada:**
  - contrato_id: (contrato cancelado)
- **Acción:** Ejecutar acción 'actualizarUnidades'.
- **Esperado:**
  - Respuesta success: false
  - Mensaje: 'Contrato no encontrado o no vigente.'

### Caso 5: Listar tipos de aseo
- **Acción:** Ejecutar acción 'listarTiposAseo'.
- **Esperado:**
  - Respuesta success: true
  - Lista de tipos de aseo no vacía.

### Caso 6: Buscar contrato inexistente
- **Entrada:**
  - contrato: 999999
  - ctrol_aseo: 8
- **Acción:** Ejecutar acción 'buscarContrato'.
- **Esperado:**
  - Respuesta success: false
  - Mensaje: 'No existe contrato vigente con esos datos.'
