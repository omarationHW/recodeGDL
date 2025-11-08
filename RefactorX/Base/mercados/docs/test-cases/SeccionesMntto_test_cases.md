# Casos de Prueba para SeccionesMntto

| Caso | Acción | Datos de Entrada | Resultado Esperado |
|------|--------|------------------|-------------------|
| 1 | Alta válida | {"seccion": "AB", "descripcion": "ABASTOS"} | Sección agregada, mensaje de éxito |
| 2 | Alta duplicada | {"seccion": "AB", "descripcion": "DUPLICADO"} | Error: La sección ya existe |
| 3 | Modificación válida | {"seccion": "AB", "descripcion": "ABASTOS CENTRO"} | Descripción actualizada, mensaje de éxito |
| 4 | Modificación inexistente | {"seccion": "ZZ", "descripcion": "NO EXISTE"} | Error: La sección no existe |
| 5 | Consulta general | - | Lista de secciones mostrada |
| 6 | Consulta específica | {"seccion": "AB"} | Sección 'AB' mostrada |
| 7 | Validación campos vacíos | {"seccion": "", "descripcion": ""} | Error de validación |
| 8 | Validación longitud | {"seccion": "ABC", "descripcion": "D".repeat(31)} | Error de validación |
