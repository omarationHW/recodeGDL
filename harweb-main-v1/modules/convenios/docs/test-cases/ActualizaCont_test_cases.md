# Casos de Prueba: ActualizaCont

## Prueba 1: Visualización de Diferencias
- **Preparación:**
  - Insertar en ta_17_paso_cont: colonia=101, calle=5, ...
  - Asegurarse que ta_17_calles no tiene colonia=101, calle=5
- **Acción:**
  - Acceder a la página y verificar que la diferencia aparece.
- **Resultado esperado:**
  - Se muestra la fila con colonia=101, calle=5, contratos=1

## Prueba 2: Actualización Exitosa
- **Preparación:**
  - ta_17_paso_cont: 2 registros nuevos, 1 existente (ya en ta_17_calles), 1 con datos inválidos (ej: colonia=null)
- **Acción:**
  - Ejecutar 'Actualizar Contratos'.
- **Resultado esperado:**
  - Totales: adicionados=2, modificados=1, inconsistencias=1, total=4, descuentos=0

## Prueba 3: Sin Diferencias
- **Preparación:**
  - ta_17_paso_cont vacío o todos los registros ya existen en ta_17_calles
- **Acción:**
  - Acceder a la página y ejecutar 'Buscar Diferencias'.
- **Resultado esperado:**
  - Tabla vacía o mensaje 'Sin diferencias encontradas'

## Prueba 4: Error de Base de Datos
- **Preparación:**
  - Simular error de conexión o bloqueo en la base de datos
- **Acción:**
  - Ejecutar cualquier acción
- **Resultado esperado:**
  - Se muestra mensaje de error amigable en el frontend
