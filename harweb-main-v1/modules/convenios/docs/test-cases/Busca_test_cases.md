# Casos de Prueba para Formulario Busca

## Caso 1: Búsqueda por Nombre
- **Entrada:** nombre = 'JUAN PEREZ'
- **Acción:** searchByNombre
- **Esperado:** Lista de convenios donde el nombre contiene 'JUAN PEREZ'.
- **Validación:** Todos los resultados contienen 'JUAN PEREZ' (case-insensitive).

## Caso 2: Búsqueda por Domicilio
- **Entrada:** calle = 'AV. INDEPENDENCIA', num_exterior = 123
- **Acción:** searchByDomicilio
- **Esperado:** Lista de convenios con esa calle y número exterior.
- **Validación:** Todos los resultados tienen calle 'AV. INDEPENDENCIA' y num_exterior = 123.

## Caso 3: Búsqueda por Licencia de Giro
- **Entrada:** licencia = 456789
- **Acción:** searchByLicencia
- **Esperado:** Lista de convenios asociados a la licencia 456789.
- **Validación:** Todos los resultados tienen licencia = 456789.

## Caso 4: Búsqueda por Multa (Error de Parámetro)
- **Entrada:** dependencia = '', axo_acta = '', num_acta = ''
- **Acción:** searchByMulta
- **Esperado:** Error de validación (campos requeridos).
- **Validación:** eResponse.status = 'error', message indica campos requeridos.

## Caso 5: Búsqueda por Cuenta (Sin resultados)
- **Entrada:** rec = 99, ur = 'X', cuenta = 999999
- **Acción:** searchByCuenta
- **Esperado:** Lista vacía.
- **Validación:** eResponse.status = 'success', data = [].
