## Casos de Prueba para Descuentos Autorizados

### 1. Alta de Descuento - Porcentaje permitido
- **Entrada:** Folio vigente, practicado, porcentaje <= tope autorizado
- **Acción:** Alta
- **Esperado:** Descuento registrado, porcentaje actualizado, mensaje éxito

### 2. Alta de Descuento - Porcentaje mayor al permitido
- **Entrada:** Folio vigente, practicado, porcentaje > tope autorizado
- **Acción:** Alta
- **Esperado:** Error: 'Porcentaje de Descuento es mayor al permitido por quien autoriza'

### 3. Modificación de Descuento
- **Entrada:** Folio con descuento vigente, nuevo porcentaje válido
- **Acción:** Modificar
- **Esperado:** Descuento actualizado, porcentaje modificado, mensaje éxito

### 4. Baja de Descuento
- **Entrada:** Folio con descuento vigente
- **Acción:** Baja
- **Esperado:** Descuento cancelado, porcentaje multa en folio = 100, mensaje éxito

### 5. Búsqueda de Folio inexistente
- **Entrada:** Folio no existente
- **Acción:** Buscar
- **Esperado:** Mensaje: 'No existe el folio o no se encuentra practicado o vigente'

### 6. Catálogo de Quién Autoriza según permisos
- **Entrada:** Usuario con y sin permiso especial
- **Acción:** Cargar catálogo
- **Esperado:** Lista correcta de autorizadores según permisos
