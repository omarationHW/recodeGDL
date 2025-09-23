## Casos de Prueba para GFacturacion

### Caso 1: Consulta de Facturación del Periodo Actual
- **Entrada:**
  - Tabla: 3 (Rastro)
  - Periodo: Actual (Año/Mes del sistema)
  - Tipo: Adeudos y Pagos
  - Recargos: Sí
- **Acción:** Consultar
- **Esperado:** Lista de registros con importes, suma total > 0

### Caso 2: Consulta de Solo Pagados de un Periodo Anterior
- **Entrada:**
  - Tabla: 3
  - Periodo: Año 2023, Mes 12
  - Tipo: Solo Pagados
  - Recargos: No (opción deshabilitada)
- **Acción:** Consultar
- **Esperado:** Solo registros pagados, suma total coincide con pagos

### Caso 3: Consulta de Solo Adeudos sin Recargos
- **Entrada:**
  - Tabla: 3
  - Periodo: Actual
  - Tipo: Solo Adeudos
  - Recargos: No
- **Acción:** Consultar
- **Esperado:** Solo registros de adeudos sin recargos, suma total coincide

### Caso 4: Validación de Campos Obligatorios
- **Entrada:**
  - Tabla: (vacío)
- **Acción:** Consultar
- **Esperado:** Mensaje de error "Debe seleccionar una tabla."

### Caso 5: Validación de Año/Mes en Otro Periodo
- **Entrada:**
  - Periodo: Otro
  - Año: (vacío)
  - Mes: (vacío)
- **Acción:** Consultar
- **Esperado:** Mensaje de error por campos requeridos
