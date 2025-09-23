# Casos de Prueba: BusquedaActividadFrm

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC01 | Búsqueda básica por SCIAN | scian=561110, descripcion='' | Lista de actividades vigentes con SCIAN 561110 |
| TC02 | Búsqueda por SCIAN y descripción parcial | scian=561110, descripcion='RESTAURANTE' | Solo actividades que contienen 'RESTAURANTE' en la descripción |
| TC03 | Búsqueda sin resultados | scian=561110, descripcion='ZZZZZZ' | Tabla vacía, mensaje 'No se encontraron actividades.' |
| TC04 | Selección de actividad | Seleccionar fila y presionar 'Aceptar' | Evento emitido con datos de la actividad seleccionada |
| TC05 | Error por SCIAN faltante | scian no enviado | Error en frontend, no se realiza búsqueda |
| TC06 | Error de backend | API responde con error | Mensaje de error visible en frontend |
