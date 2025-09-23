# Casos de Prueba para sfrm_prop_exclusivo

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|--------------------|
| 1 | Alta exitosa de persona física | sociedad: F, rfc: XEXX010101000, propietario: MARIA LOPEZ, domicilio: CALLE 10 #100, ... | Registro creado, mensaje de éxito |
| 2 | Alta con RFC duplicado | sociedad: F, rfc: TOHI691108LFA (ya existe), ... | Error: 'Este RFC ya está registrado.' |
| 3 | Edición exitosa de persona moral | id: 2, sociedad: M, rfc: AAA010101AAA, ... | Registro actualizado, mensaje de éxito |
| 4 | Edición con ID inexistente | id: 9999, ... | Error: 'No existe el registro.' |
| 5 | Alta con RFC menor a 9 caracteres | sociedad: F, rfc: ABC123, ... | Error de validación en frontend y backend |
| 6 | Alta con campos obligatorios vacíos | sociedad: F, rfc: '', propietario: '', domicilio: '', ... | Error de validación en frontend |
| 7 | Consulta por RFC existente | rfc: TOHI691108LFA | Devuelve datos del propietario |
| 8 | Consulta por RFC inexistente | rfc: ZZZ999999ZZZ | Devuelve lista vacía |
