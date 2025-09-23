# Casos de Prueba: Actualiza Fecha de Práctica de Empresas

## Caso 1: Carga y actualización masiva exitosa
- **Precondición:** Archivo de texto con 10 folios válidos
- **Pasos:**
  1. Cargar archivo
  2. Seleccionar ejecutor y fecha
  3. Presionar 'Actualizar Todos'
- **Resultado esperado:**
  - 10 folios actualizados
  - 0 errores
  - Resumen correcto

## Caso 2: Error en folios inexistentes
- **Precondición:** Archivo con 5 folios válidos y 3 inválidos
- **Pasos:**
  1. Cargar archivo
  2. Seleccionar ejecutor y fecha
  3. Presionar 'Actualizar Todos'
- **Resultado esperado:**
  - 5 folios actualizados
  - 3 errores reportados en la lista de errores

## Caso 3: Actualización individual
- **Precondición:** Archivo con al menos 1 folio válido
- **Pasos:**
  1. Cargar archivo
  2. Seleccionar ejecutor y fecha
  3. Presionar 'Actualizar' en la fila del folio
- **Resultado esperado:**
  - El folio cambia a estado 'ACTUALIZADO'
  - Resumen actualizado correctamente

## Caso 4: Validación de campos obligatorios
- **Precondición:** No se selecciona archivo o fecha
- **Pasos:**
  1. Intentar actualizar sin archivo o sin fecha
- **Resultado esperado:**
  - Mensaje de error indicando campos obligatorios

## Caso 5: Archivo malformado
- **Precondición:** Archivo de texto con líneas vacías o delimitadores incorrectos
- **Pasos:**
  1. Cargar archivo
  2. Intentar parsear
- **Resultado esperado:**
  - Mensaje de error o líneas ignoradas correctamente
