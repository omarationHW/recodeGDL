## Casos de Prueba para Liquidaciones

### Caso 1: Cálculo correcto de liquidación para fosa existente
- **Entrada:** cementerio='G', anio_desde=2018, anio_hasta=2023, metros=3.125, tipo='F', nuevo=false, mes=6
- **Acción:** calculate_liquidation
- **Esperado:**
  - Respuesta success=true
  - Tabla con 6 filas (2018-2023), cada una con manten, recargos, total
  - Totales correctos

### Caso 2: Liquidación para nuevo (recargos en cero)
- **Entrada:** cementerio='A', anio_desde=2024, anio_hasta=2024, metros=1.0, tipo='U', nuevo=true, mes=6
- **Acción:** calculate_liquidation
- **Esperado:**
  - Respuesta success=true
  - Solo un año (2024), recargos=0

### Caso 3: Error por metros vacíos
- **Entrada:** cementerio='G', anio_desde=2020, anio_hasta=2022, metros=0, tipo='F', nuevo=false, mes=6
- **Acción:** calculate_liquidation
- **Esperado:**
  - Respuesta success=false
  - Mensaje: 'metros debe tener información' o similar

### Caso 4: Listado de cementerios
- **Acción:** list_cemeteries
- **Esperado:**
  - Respuesta success=true
  - Lista de cementerios con campos cementerio, nombre, domicilio

### Caso 5: Validación de años fuera de rango
- **Entrada:** cementerio='G', anio_desde=1990, anio_hasta=2022, metros=3.0, tipo='F', nuevo=false, mes=6
- **Acción:** calculate_liquidation
- **Esperado:**
  - Respuesta success=false
  - Mensaje de error por año fuera de rango
