## Casos de Prueba para formabuscolonia

| # | Descripción | Entrada | Acción | Resultado Esperado |
|---|-------------|---------|--------|--------------------|
| 1 | Listado inicial de colonias | filtro: "" | Cargar página | Se muestran todas las colonias de c_mnpio=39 |
| 2 | Filtrado por texto existente | filtro: "CENTRO" | Escribir en campo filtro | Solo aparecen colonias con 'CENTRO' en el nombre |
| 3 | Filtrado por texto inexistente | filtro: "XYZ" | Escribir en campo filtro | Tabla muestra 'No se encontraron colonias' |
| 4 | Selección de colonia y confirmación | filtro: "CENTRO", seleccionar 'CENTRO', click 'Aceptar' | Seleccionar y aceptar | Se muestra nombre y código postal de 'CENTRO' |
| 5 | Selección sin elegir colonia | filtro: "CENTRO", no seleccionar, click 'Aceptar' | Click 'Aceptar' | No ocurre nada, botón deshabilitado |
| 6 | Sensibilidad a mayúsculas/minúsculas | filtro: "centro" | Escribir en campo filtro | Coincide igual que 'CENTRO' |
| 7 | Filtro con espacios | filtro: "  CENTRO  " | Escribir en campo filtro | Coincide igual que 'CENTRO' |
