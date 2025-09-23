# Casos de Prueba

## Caso 1: Agregar un nuevo adeudo válido
- **Entrada:** id_licencia=1, id_anuncio=2, axo=2024, derechos=1000, derechos2=100, forma=500
- **Acción:** POST /api/execute { action: 'add', data: {...} }
- **Esperado:** Registro creado, saldos recalculados, respuesta success=true

## Caso 2: Agregar un adeudo con año vacío
- **Entrada:** id_licencia=1, id_anuncio=2, axo=null, derechos=1000, derechos2=100, forma=500
- **Acción:** POST /api/execute { action: 'add', data: {...} }
- **Esperado:** Error de validación, success=false, mensaje 'El campo axo es obligatorio'

## Caso 3: Modificar un adeudo existente
- **Entrada:** id=5, id_licencia=1, id_anuncio=2, axo=2024, derechos=1200, derechos2=100, forma=500
- **Acción:** POST /api/execute { action: 'edit', data: {...} }
- **Esperado:** Registro actualizado, saldos recalculados, success=true

## Caso 4: Eliminar un adeudo
- **Entrada:** id=5, id_licencia=1
- **Acción:** POST /api/execute { action: 'delete', data: {...} }
- **Esperado:** Registro eliminado, saldos recalculados, success=true

## Caso 5: Listar adeudos de una licencia/anuncio
- **Entrada:** id_licencia=1, id_anuncio=2
- **Acción:** POST /api/execute { action: 'list', data: {...} }
- **Esperado:** Lista de registros, success=true

## Caso 6: Obtener saldos de licencia
- **Entrada:** id_licencia=1
- **Acción:** POST /api/execute { action: 'get_saldos', data: {...} }
- **Esperado:** Objeto con saldos, success=true
