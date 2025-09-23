# Casos de Prueba: Cruces

| Caso | Descripción | Entrada | Acción | Resultado Esperado |
|------|-------------|---------|--------|-------------------|
| TC01 | Búsqueda exitosa de dos calles | Calle1: 'INDE', Calle2: 'JUAR' | Buscar y seleccionar ambas, presionar 'Aceptar' | Se muestran los datos completos de ambas calles |
| TC02 | Búsqueda sin resultados | Calle1: 'ZZZZ', Calle2: 'XXXX' | Buscar en ambos campos | No se muestran resultados en las listas |
| TC03 | Selección de solo una calle | Calle1: 'INDE', Calle2: '' | Seleccionar solo una, presionar 'Aceptar' | Se muestra solo la información de la calle seleccionada, la otra como N/A |
| TC04 | Selección de ninguna calle | Calle1: '', Calle2: '' | Presionar 'Aceptar' | Se muestra mensaje de error: 'Debe seleccionar al menos una calle en cada lista.' |
| TC05 | Calle escondida | Calle1: nombre de una calle escondida | Buscar | No aparece en la lista de resultados |
| TC06 | Sensibilidad a mayúsculas/minúsculas | Calle1: 'independencia', Calle2: 'Juarez' | Buscar | Se muestran resultados correctamente |
