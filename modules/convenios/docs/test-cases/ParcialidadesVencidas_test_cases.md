# Casos de Prueba - Parcialidades Vencidas

## Caso 1: Consulta exitosa de convenios con parcialidades vencidas
- **Precondición:** Hay al menos 3 convenios con parcialidades vencidas en la base de datos.
- **Pasos:**
  1. Acceder a la página.
  2. Hacer clic en 'Buscar'.
- **Resultado esperado:**
  - Se muestran los convenios con todos los campos requeridos.

## Caso 2: Exportación a Excel/CSV
- **Precondición:** Hay datos en la tabla.
- **Pasos:**
  1. Hacer clic en 'Exportar Excel'.
- **Resultado esperado:**
  - Se descarga un archivo CSV con los mismos datos de la tabla.

## Caso 3: Sin datos disponibles
- **Precondición:** No hay convenios con parcialidades vencidas.
- **Pasos:**
  1. Hacer clic en 'Buscar'.
- **Resultado esperado:**
  - Se muestra el mensaje 'No hay datos para mostrar.'

## Caso 4: Error de backend (stored procedure no existe)
- **Precondición:** El stored procedure fue renombrado o eliminado.
- **Pasos:**
  1. Hacer clic en 'Buscar'.
- **Resultado esperado:**
  - Se muestra un mensaje de error claro al usuario.

## Caso 5: Validación de formato de moneda y fechas
- **Precondición:** Hay datos con diferentes montos y fechas.
- **Pasos:**
  1. Hacer clic en 'Buscar'.
- **Resultado esperado:**
  - Los montos se muestran en formato moneda MXN y las fechas en formato local.
