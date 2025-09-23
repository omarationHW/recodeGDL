## Casos de Prueba para Gen_Individual

### Caso 1: Añadir por placa válida
- **Entrada**: opcion=0, placa='JBB3322', axo='', folio='', remesa='ayt_gdl_r100'
- **Acción**: add
- **Esperado**: Registros de la placa se añaden a la remesa, aparecen en la tabla.

### Caso 2: Añadir por placa y folios
- **Entrada**: opcion=1, placa='JBB3322', axo='', folio='123,124', remesa='ayt_gdl_r100'
- **Acción**: add
- **Esperado**: Sólo los folios 123 y 124 de la placa se añaden.

### Caso 3: Añadir por año y folios
- **Entrada**: opcion=2, placa='', axo=2023, folio='1001,1002', remesa='ayt_gdl_r100'
- **Acción**: add
- **Esperado**: Sólo los folios 1001 y 1002 del año 2023 se añaden.

### Caso 4: Ejecutar remesa
- **Entrada**: remesa='ayt_gdl_r100'
- **Acción**: execute
- **Esperado**: Se graba en bitácora, contadores actualizados.

### Caso 5: Generar archivo de remesa
- **Entrada**: remesa='ayt_gdl_r100'
- **Acción**: generate_file
- **Esperado**: Archivo de texto generado, descargable, con los registros de la remesa.

### Caso 6: Consultar remesa
- **Entrada**: remesa='ayt_gdl_r100'
- **Acción**: consult
- **Esperado**: Se listan los registros de la remesa.

### Caso 7: Eliminar remesa
- **Entrada**: remesa='ayt_gdl_r100'
- **Acción**: delete_remesa
- **Esperado**: Todos los registros de la remesa son eliminados.

### Caso 8: Error por placa inexistente
- **Entrada**: opcion=0, placa='ZZZ9999', axo='', folio='', remesa='ayt_gdl_r100'
- **Acción**: add
- **Esperado**: No se añaden registros, mensaje de error o tabla vacía.

### Caso 9: Error por folio no numérico
- **Entrada**: opcion=1, placa='JBB3322', axo='', folio='abc', remesa='ayt_gdl_r100'
- **Acción**: add
- **Esperado**: Error de validación, mensaje adecuado.
