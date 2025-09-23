# Casos de Prueba: Histórico de Bloqueo de Domicilios

## Caso 1: Consulta general
- **Acción:** listar
- **Entrada:** { "action": "listar", "params": { "order": "calle,num_ext" } }
- **Resultado esperado:** Respuesta contiene todos los registros de la tabla h_bloqueo_dom ordenados por calle y número exterior.

## Caso 2: Filtrado por calle
- **Acción:** filtrar
- **Entrada:** { "action": "filtrar", "params": { "campo": "calle", "valor": "AVENIDA", "order": "calle,num_ext" } }
- **Resultado esperado:** Respuesta contiene solo los registros donde el campo calle contiene 'AVENIDA'.

## Caso 3: Exportar a Excel
- **Acción:** exportar
- **Entrada:** { "action": "exportar", "params": { "order": "fecha DESC, hora DESC" } }
- **Resultado esperado:** Respuesta contiene los datos en formato adecuado para exportar a Excel.

## Caso 4: Imprimir PDF
- **Acción:** imprimir
- **Entrada:** { "action": "imprimir", "params": { "order": "modifico,fecha_mov DESC" } }
- **Resultado esperado:** Respuesta contiene los datos en formato adecuado para impresión PDF.

## Caso 5: Detalle de registro
- **Acción:** detalle
- **Entrada:** { "action": "detalle", "params": { "id": 123 } }
- **Resultado esperado:** Respuesta contiene el registro con id=123 de la tabla h_bloqueo_dom.
