# Casos de Prueba para Formulario ipor

## Caso 1: Asignación Masiva de Requerimientos
- **Entrada:**
  - action: assign_requerimientos
  - params: { tipo: 'predial', ejecutor_id: 123, fecha: '2024-06-10', recaud: 1, folioini: 1000, foliofin: 1100 }
- **Esperado:**
  - eResponse.result contiene asignados > 0 y mensaje de éxito
  - Los registros en reqpredial tienen cveejecut=123 y fecejec='2024-06-10' en el rango de folios

## Caso 2: Impresión de Requerimientos por Ejecutor
- **Entrada:**
  - action: print_requerimientos
  - params: { fecha: '2024-06-10', recaud: 1, tipo_impresion: 'notificacion', ejecutor_id: 123 }
- **Esperado:**
  - eResponse.result contiene lista de requerimientos con secuencia=3, fecejec='2024-06-10', cveejecut=123

## Caso 3: Visualización de Grid de Multas
- **Entrada:**
  - action: get_multas_grid
  - params: { tipo: 'N', recaud: 1, folioini: 2000, foliofin: 2100 }
- **Esperado:**
  - eResponse.result contiene array de objetos con zona_sub, cantidad, ejecutor_id=null, asignar=null

## Caso 4: Filtros de Controles
- **Entrada:**
  - action: filter_controls
  - params: { recaud: 1, fecha_emision: '2024-06-01', ult_impreso_lt_folio_final: true }
- **Esperado:**
  - eResponse.result contiene controles que cumplen los filtros

## Caso 5: Error en Acción No Soportada
- **Entrada:**
  - action: 'accion_inexistente'
- **Esperado:**
  - eResponse.error contiene mensaje 'Acción no soportada: accion_inexistente'
