# Casos de Prueba para Alta de Folios

## Caso 1: Alta Exitosa de Folio
- **Entrada:**
  - folio: 1234567
  - placa: ABC1234
  - fecha: 2024-06-10
  - vigilante: 1
  - clave: 1
  - estado: 1
  - zona: 1
  - espacio: 1
  - hora: 08:00
- **Acción:**
  - El usuario llena el formulario y presiona 'Aceptar'.
- **Resultado Esperado:**
  - El folio se inserta correctamente y se muestra mensaje de éxito.

## Caso 2: Folio Existente en Adeudo
- **Entrada:**
  - folio: 1000001 (ya existe en ta14_folios_adeudo)
  - placa: XYZ9876
- **Acción:**
  - El usuario intenta grabar el folio.
- **Resultado Esperado:**
  - El sistema muestra 'Folio ya está capturado vigente...' y no permite grabar.

## Caso 3: Folio Existente en Histórico
- **Entrada:**
  - folio: 2000002 (existe en ta14_folios_histo con codigo_movto <> 1)
  - placa: DEF5678
- **Acción:**
  - El usuario intenta grabar el folio.
- **Resultado Esperado:**
  - El sistema muestra 'Folio Pagado o sin efecto...' y no permite grabar.

## Caso 4: Placa No Existente
- **Entrada:**
  - folio: 3000003
  - placa: NOEXISTE
- **Acción:**
  - El usuario ingresa la placa y el sistema no muestra datos de vehículo.
- **Resultado Esperado:**
  - El sistema no muestra datos de vehículo ni calcomanía.

## Caso 5: Validación de Campos Obligatorios
- **Entrada:**
  - Dejar campos requeridos vacíos.
- **Acción:**
  - El usuario intenta grabar.
- **Resultado Esperado:**
  - El sistema muestra mensajes de error de validación y no permite grabar.
