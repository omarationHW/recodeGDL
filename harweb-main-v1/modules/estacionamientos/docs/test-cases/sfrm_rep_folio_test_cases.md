# Casos de Prueba para Reporte de Folios

## Caso 1: Reporte de Folios Elaborados (Todos Vigilantes)
- **Entrada:**
  - eRequest: getFoliosReport
  - params: { date: '2024-06-15', vigila: null, mode: 'elaborados' }
- **Esperado:**
  - Respuesta success true
  - Lista de folios con campos: vigilante, inspector, axo, folio, placa, fecha_folio, estado, infraccion, tarifa, descripcion, usu_inicial, usuario

## Caso 2: Reporte de Folios Capturados (Vigilante Específico)
- **Entrada:**
  - eRequest: getFoliosReport
  - params: { date: '2024-06-15', vigila: 5, mode: 'capturados' }
- **Esperado:**
  - Respuesta success true
  - Solo folios capturados por vigilante 5

## Caso 3: Conteo de Folios por Inspector
- **Entrada:**
  - eRequest: getFoliosByInspector
  - params: { date: '2024-06-15' }
- **Esperado:**
  - Respuesta success true
  - Lista de inspectores y número de folios hechos

## Caso 4: Catálogo de Inspectores
- **Entrada:**
  - eRequest: getInspectors
- **Esperado:**
  - Respuesta success true
  - Lista de inspectores con id_esta_persona e inspector

## Caso 5: Catálogo de Usuarios
- **Entrada:**
  - eRequest: getUsuarios
- **Esperado:**
  - Respuesta success true
  - Lista de usuarios con id_usuario, usuario, nombre, estado, id_rec, nivel

## Caso 6: Error por eRequest inválido
- **Entrada:**
  - eRequest: 'noExiste'
- **Esperado:**
  - Respuesta success false
  - Mensaje: 'eRequest not recognized.'
