## Casos de Prueba MantPagosContratos

### Caso 1: Alta de Pago Correcto
- **Entrada:** Todos los campos válidos, contrato existe.
- **Acción:** agregar_pago
- **Esperado:** status=success, message='Pago agregado correctamente'.

### Caso 2: Alta de Pago con Contrato Inexistente
- **Entrada:** colonia/calle/folio no existen.
- **Acción:** agregar_pago
- **Esperado:** status=error, message='No existe el contrato especificado'.

### Caso 3: Modificación de Pago Existente
- **Entrada:** Llaves de pago existentes, nuevo importe.
- **Acción:** modificar_pago
- **Esperado:** status=success, message='Pago modificado correctamente'.

### Caso 4: Modificación de Pago Inexistente
- **Entrada:** Llaves de pago inexistentes.
- **Acción:** modificar_pago
- **Esperado:** status=error, message='No se encontró el pago para modificar'.

### Caso 5: Borrado de Pago Existente
- **Entrada:** Llaves de pago existentes.
- **Acción:** borrar_pago
- **Esperado:** status=success, message='Pago eliminado correctamente'.

### Caso 6: Borrado de Pago Inexistente
- **Entrada:** Llaves de pago inexistentes.
- **Acción:** borrar_pago
- **Esperado:** status=error, message='No se encontró el pago para borrar'.

### Caso 7: Listar Recaudadoras
- **Acción:** listar_recaudadoras
- **Esperado:** status=success, data=[...]

### Caso 8: Listar Cajas de Recaudadora
- **Acción:** listar_cajas, data: { oficina_pago: 1 }
- **Esperado:** status=success, data=[...]
