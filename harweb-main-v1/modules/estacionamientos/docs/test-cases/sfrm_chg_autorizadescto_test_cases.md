# Casos de Prueba: sfrm_chg_autorizadescto

## Caso 1: Búsqueda exitosa de folios históricos
- **Entrada:** placa = 'ABC1234'
- **Acción:** Buscar
- **Esperado:** Se muestran todos los folios históricos de la placa entre 2013-10-01 y 2014-12-31.

## Caso 2: Placa inexistente
- **Entrada:** placa = 'ZZZ9999'
- **Acción:** Buscar
- **Esperado:** Se muestra mensaje 'No se encontraron folios para la placa ingresada.'

## Caso 3: Visualización de descuentos otorgados
- **Entrada:** Seleccionar folio axo=2014, folio=5678
- **Acción:** Ver detalles
- **Esperado:** Se muestran los descuentos otorgados para ese folio.

## Caso 4: Cambio exitoso a 'Tesorero'
- **Entrada:** axo=2014, folio=5678 (obs != 'Tesorero')
- **Acción:** Cambiar a Tesorero
- **Esperado:** El campo obs cambia a 'Tesorero' y se muestra mensaje de éxito.

## Caso 5: Cambio a 'Tesorero' en registro inexistente
- **Entrada:** axo=2020, folio=9999 (no existe)
- **Acción:** Cambiar a Tesorero
- **Esperado:** Se muestra mensaje de error indicando que no se actualizó ningún registro.

## Caso 6: Error de base de datos
- **Simulación:** Desconectar la base de datos
- **Acción:** Buscar o cambiar a Tesorero
- **Esperado:** Se muestra mensaje de error de comunicación con el servidor.
