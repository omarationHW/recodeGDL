# Casos de Prueba: ConsGral

| # | Descripción | Entrada | Acción | Resultado Esperado |
|---|-------------|---------|--------|-------------------|
| 1 | Consulta placa existente | placa: 'ABC1234' | Buscar | Tabla muestra folios de aFolios y/o bFolios con datos |
| 2 | Consulta placa inexistente | placa: 'ZZZ9999' | Buscar | Tabla vacía o mensaje 'Sin resultados' |
| 3 | Campo placa vacío | placa: '' | Buscar | Mensaje de error 'El campo placa es requerido.' |
| 4 | Placa con caracteres minúsculos | placa: 'abc1234' | Buscar | Se convierte a mayúsculas y busca correctamente |
| 5 | Placa con espacios | placa: '  ABC1234  ' | Buscar | Se trimea y busca correctamente |
| 6 | Navegación Salir | - | Click en 'Salir' | Redirige a página de inicio |
| 7 | Error de red/API | placa: 'ABC1234' | Buscar (API caída) | Mensaje de error 'Error de red.' |
