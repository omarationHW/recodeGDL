# Casos de Prueba para Búsqueda Catastral

## 1. Búsqueda por Nombre (Éxito)
- **Entrada:** nombre = 'JUAN PEREZ'
- **Acción:** buscar_por_nombre
- **Esperado:** Lista de cuentas catastrales con propietarios que contienen 'JUAN PEREZ'.

## 2. Búsqueda por Nombre (Sin Resultados)
- **Entrada:** nombre = 'ZZZZZZZZ'
- **Acción:** buscar_por_nombre
- **Esperado:** Respuesta con data vacía y mensaje 'No se encontraron resultados.'

## 3. Búsqueda por Ubicación (Calle y Número)
- **Entrada:** calle = 'AV. JUAREZ', exterior = '123'
- **Acción:** buscar_por_ubicacion
- **Esperado:** Lista de cuentas catastrales que coinciden con la dirección.

## 4. Búsqueda por Clave Catastral (Zona/Manzana/Predio/Subpredio)
- **Entrada:** zona = 'D65J1', manzana = '345', predio = '12', subpredio = '1'
- **Acción:** buscar_por_clave_catastral
- **Esperado:** Lista de cuentas catastrales que coinciden con la clave.

## 5. Búsqueda por RFC (Éxito)
- **Entrada:** rfc = 'PEPJ800101'
- **Acción:** buscar_por_rfc
- **Esperado:** Lista de cuentas catastrales con ese RFC.

## 6. Búsqueda por RFC (Sin Resultados)
- **Entrada:** rfc = 'XXXX000000'
- **Acción:** buscar_por_rfc
- **Esperado:** Respuesta con data vacía y mensaje 'No se encontraron resultados.'

## 7. Búsqueda por Cuenta (Recaud/URBRUS/Cuenta)
- **Entrada:** recaud = 1, urbrus = 'U', cuenta = 123456
- **Acción:** buscar_por_cuenta
- **Esperado:** Lista de cuentas catastrales que coinciden con los datos.

## 8. Validación de Parámetros (Error)
- **Entrada:** nombre = ''
- **Acción:** buscar_por_nombre
- **Esperado:** Error de validación 'Nombre requerido para búsqueda.'

## 9. Límite de Resultados
- **Entrada:** nombre = 'A'
- **Acción:** buscar_por_nombre
- **Esperado:** Máximo 300 resultados en la respuesta.
