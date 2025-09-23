# Casos de Prueba: RprtListaxRegAseo

## Caso 1: Consulta básica por oficina y tipo de aseo
- **Entrada:** id_rec=1, tipo_aseo='H', clave_practicado='todas', vigencia='todas'
- **Esperado:** Lista de registros para oficina 1 y tipo 'H', sin filtrar por clave ni vigencia.

## Caso 2: Filtro por clave practicado
- **Entrada:** id_rec=1, tipo_aseo='H', clave_practicado='B', vigencia='todas'
- **Esperado:** Solo registros con clave_practicado='B'.

## Caso 3: Filtro por vigencia vencida/parcial
- **Entrada:** id_rec=1, tipo_aseo='H', clave_practicado='todas', vigencia='2'
- **Esperado:** Solo registros con vigencia='2' o vigencia='P'.

## Caso 4: Sin resultados
- **Entrada:** id_rec=99, tipo_aseo='Z', clave_practicado='X', vigencia='1'
- **Esperado:** Mensaje de "No hay datos para los filtros seleccionados".

## Caso 5: Exportar CSV
- **Acción:** Realizar búsqueda con resultados, presionar 'Exportar CSV'.
- **Esperado:** Descarga de archivo CSV con los datos mostrados.

## Caso 6: Error de parámetros
- **Entrada:** id_rec=null, tipo_aseo=null
- **Esperado:** Error de validación o mensaje de error en la respuesta.
