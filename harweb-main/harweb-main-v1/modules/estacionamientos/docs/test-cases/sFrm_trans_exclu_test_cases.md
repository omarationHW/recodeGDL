# Casos de Prueba: Transferencia de Exclusivos

## Caso 1: Importación exitosa de archivo plano
- **Entrada**: Archivo plano con 2 líneas válidas.
- **Acción**: Cargar archivo, parsear, importar.
- **Esperado**: Ambos registros insertados en ta_18_exclusivo. Mensaje de éxito.

## Caso 2: Archivo con línea inválida
- **Entrada**: Archivo plano con 1 línea válida y 1 línea con campos vacíos.
- **Acción**: Cargar archivo, parsear, importar.
- **Esperado**: Sólo el registro válido es insertado. Mensaje de error para el inválido.

## Caso 3: Actualización de fecha de vencimiento
- **Entrada**: sector='B', categ='Y', num=5678, fec_venci='2025-01-15'
- **Acción**: Usar formulario de actualización de fechas.
- **Esperado**: El registro correspondiente en ta_15_publicos tiene la fecha actualizada.

## Caso 4: Archivo vacío
- **Entrada**: Archivo plano vacío.
- **Acción**: Cargar archivo, parsear.
- **Esperado**: Mensaje de error 'No se recibió el contenido del archivo' o 'Archivo vacío'.

## Caso 5: Campos fuera de rango
- **Entrada**: Archivo plano con campos numéricos fuera de rango (ej: metros='9999').
- **Acción**: Cargar archivo, parsear, importar.
- **Esperado**: Mensaje de error de validación para esos registros.
