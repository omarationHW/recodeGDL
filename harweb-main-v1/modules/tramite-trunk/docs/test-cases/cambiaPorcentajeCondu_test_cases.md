## Casos de Prueba para CambiaPorcentajeCondu

### 1. Consulta de propietarios
- **Entrada:** action: getPropietarios, cvecuenta=12345, cveregprop=1
- **Esperado:** Lista de propietarios, cada uno con cvecont, nombre_completo, encabeza, porcentaje, descripcion

### 2. Consulta de calidades
- **Entrada:** action: getCalidades
- **Esperado:** Lista de calidades (cvereg, descripcion)

### 3. Actualización exitosa
- **Entrada:** action: updatePorcentajes, cvecuenta=12345, cveregprop=1, propietarios=[{cvecont:1,porcentaje:60,encabeza:'S',descripcion:'PROPIETARIO'},{cvecont:2,porcentaje:40,encabeza:'N',descripcion:'COPROPIETARIO'}]
- **Esperado:** success=true, message='Actualización exitosa.'

### 4. Error por suma incorrecta
- **Entrada:** action: updatePorcentajes, cvecuenta=12345, cveregprop=1, propietarios=[{cvecont:1,porcentaje:50,encabeza:'S',descripcion:'PROPIETARIO'},{cvecont:2,porcentaje:40,encabeza:'N',descripcion:'COPROPIETARIO'}]
- **Esperado:** success=false, message='El total de porcentaje debe ser 100.'

### 5. Error por más de un encabeza
- **Entrada:** action: updatePorcentajes, cvecuenta=12345, cveregprop=1, propietarios=[{cvecont:1,porcentaje:50,encabeza:'S',descripcion:'PROPIETARIO'},{cvecont:2,porcentaje:50,encabeza:'S',descripcion:'COPROPIETARIO'}]
- **Esperado:** success=false, message='Debe haber exactamente un contribuyente que encabece.'

### 6. Error por calidad no válida
- **Entrada:** action: updatePorcentajes, cvecuenta=12345, cveregprop=1, propietarios=[{cvecont:1,porcentaje:100,encabeza:'S',descripcion:'NOEXISTE'}]
- **Esperado:** success=false, message='Calidad no válida para NOEXISTE'
