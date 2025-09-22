# Casos de Prueba: GirosDconAdeudo

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC01 | Consulta exitosa con datos | year: 2022 | Respuesta success=true, data con registros, message='Datos encontrados.' |
| TC02 | Consulta sin datos | year: 1999 | Respuesta success=true, data vacía, message='No se encontraron licencias...' |
| TC03 | Año inválido (menor a 1900) | year: 1800 | Respuesta success=false, error='Ingrese un año válido.' |
| TC04 | Año inválido (mayor a 2100) | year: 2200 | Respuesta success=false, error='Ingrese un año válido.' |
| TC05 | Sin parámetro year | (no year) | Respuesta success=false, error='El año del adeudo es requerido.' |
| TC06 | eRequest no soportado | eRequest: 'UnknownRequest' | Respuesta success=false, error='eRequest no soportado.' |
| TC07 | Error de base de datos | year: 'texto' | Respuesta success=false, error interno del servidor |

**Notas:**
- Todos los casos deben probarse tanto desde el frontend como vía API directa.
- Para TC01 y TC02, verificar que los datos coincidan con la base de datos real.
- Para TC03 y TC04, la validación debe ocurrir en frontend y backend.
- Para TC06, probar con un eRequest inexistente.
