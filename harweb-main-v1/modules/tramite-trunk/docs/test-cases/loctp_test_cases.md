# Casos de Prueba para loctp

## Caso 1: Búsqueda de Escritura Existente
- **Entrada:**
  - notaria: 12
  - municipio: 5
  - escrituras: 12345
- **Acción:** search
- **Esperado:**
  - eResponse.actos contiene al menos un registro
  - eResponse.detalle contiene datos de la cuenta

## Caso 2: Edición de Observación
- **Entrada:**
  - folio: 1001
  - observacion: "Nueva observación de prueba"
- **Acción:** update_observacion
- **Esperado:**
  - eResponse.success == true
  - El campo documentosotros de actostransm.folio=1001 se actualiza

## Caso 3: Búsqueda sin Resultados
- **Entrada:**
  - notaria: 99
  - municipio: 99
  - escrituras: 99999
- **Acción:** search
- **Esperado:**
  - eResponse.actos es array vacío
  - eResponse.detalle es array vacío
  - Mensaje en frontend: 'No se localizó la escritura.'

## Caso 4: Catálogo de Municipios
- **Acción:** municipios
- **Esperado:**
  - eResponse.municipios es un array con al menos un municipio

## Caso 5: Detalle de Cuenta
- **Entrada:**
  - cvecuenta: 123456
- **Acción:** detalle
- **Esperado:**
  - eResponse.detalle contiene los campos recaud, urbrus, cuenta
