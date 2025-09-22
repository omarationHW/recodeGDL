# Casos de Prueba: Carga de Carteras

## Caso 1: Carga exitosa
- **Preparación:**
  - Insertar registros en `t34_unidades` para tabla '3' y ejercicio 2024.
- **Ejecución:**
  - Seleccionar tabla '3', ejercicio 2024.
  - Presionar 'Aplicar'.
- **Resultado esperado:**
  - Mensaje: "Cartera generada correctamente para tabla 3 y ejercicio 2024"
  - status = 0

## Caso 2: Sin unidades
- **Preparación:**
  - Asegurarse que no existan registros en `t34_unidades` para tabla '5' y ejercicio 2022.
- **Ejecución:**
  - Seleccionar tabla '5', ejercicio 2022.
- **Resultado esperado:**
  - Botón 'Aplicar' deshabilitado.
  - Mensaje: "No existen unidades para la tabla y ejercicio seleccionados."

## Caso 3: Error en SP
- **Preparación:**
  - Simular error en el SP (ejemplo: lanzar excepción en el código PL/pgSQL).
- **Ejecución:**
  - Seleccionar tabla y ejercicio válidos.
  - Presionar 'Aplicar'.
- **Resultado esperado:**
  - Mensaje de error: "Error al generar cartera: ..."
  - status = 2
