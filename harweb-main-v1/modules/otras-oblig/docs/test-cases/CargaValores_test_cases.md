## Casos de Prueba: Carga de Valores

### Caso 1: Carga exitosa de un valor
- **Precondición:** Existe al menos una tabla en t34_tablas.
- **Acción:**
  1. Seleccionar tabla '1'.
  2. Ingresar: Ejercicio=2024, Cve Und='A', Cve Oper='X', Descripción='Unidad X', $ Costo=100.50.
  3. Hacer clic en 'Aplicar'.
- **Esperado:** Mensaje de éxito y registro insertado en t34_unidades.

### Caso 2: Intento de carga con fila vacía
- **Acción:**
  1. Seleccionar tabla '1'.
  2. Dejar todos los campos vacíos o $ Costo=0.
  3. Hacer clic en 'Aplicar'.
- **Esperado:** Mensaje de error: 'Debe capturar al menos un valor válido.'

### Caso 3: Carga masiva de varios valores
- **Acción:**
  1. Seleccionar tabla '2'.
  2. Ingresar dos filas:
     - Fila 1: Ejercicio=2024, Cve Und='A', Cve Oper='X', Descripción='Unidad X', $ Costo=100.50
     - Fila 2: Ejercicio=2024, Cve Und='B', Cve Oper='Y', Descripción='Unidad Y', $ Costo=200.00
  3. Hacer clic en 'Aplicar'.
- **Esperado:** Mensaje de éxito y ambos registros insertados en t34_unidades.

### Caso 4: Error de base de datos (simulado)
- **Acción:**
  1. Forzar un error en la base de datos (por ejemplo, duplicar id_34_unidad).
  2. Intentar aplicar valores.
- **Esperado:** Mensaje de error con detalle técnico del fallo.
