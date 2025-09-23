# Casos de Prueba: ConsultaDatosEnergia

## Caso 1: Consulta exitosa de energía
- **Entrada:** id_local = 12345
- **Acción:** Buscar
- **Esperado:**
  - Se muestran los datos generales de energía.
  - Se muestran requerimientos si existen.
  - Se muestran adeudos por mes con recargos.
  - El resumen total es correcto.

## Caso 2: Local sin energía
- **Entrada:** id_local = 99999 (no existe en ta_11_energia)
- **Acción:** Buscar
- **Esperado:**
  - Se muestra mensaje de error: "No se encontró información de energía para el local."

## Caso 3: Visualización de pagos
- **Entrada:** id_local = 12345
- **Acción:** Buscar, luego 'Ver Pagos'
- **Esperado:**
  - Se muestra la tabla de pagos con los campos año, mes, fecha, importe, usuario.

## Caso 4: Visualización de condonaciones
- **Entrada:** id_local = 12345
- **Acción:** Buscar, luego 'Ver Condonaciones'
- **Esperado:**
  - Se muestra la tabla de condonaciones con año, mes, importe, observación, usuario.

## Caso 5: Cálculo de recargos
- **Entrada:** id_local = 12345 (con adeudos en varios años/meses)
- **Acción:** Buscar
- **Esperado:**
  - Los recargos por mes se calculan correctamente según el porcentaje de la tabla ta_12_recargos.
