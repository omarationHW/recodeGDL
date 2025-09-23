# Casos de Prueba: Condonación de Adeudos

## Caso 1: Condonar Adeudos Correctamente
- **Entrada:** Datos completos de local, selección de adeudos, número de oficio válido
- **Acción:** Ejecutar acción 'condonar_adeudos'
- **Esperado:** status=success, los adeudos se mueven a condonados

## Caso 2: Deshacer Condonación
- **Entrada:** Selección de condonados existentes
- **Acción:** Ejecutar acción 'deshacer_condonacion'
- **Esperado:** status=success, los adeudos reaparecen en la lista de adeudos

## Caso 3: Validación de Oficio Vacío
- **Entrada:** Selección de adeudos, campo oficio vacío
- **Acción:** Ejecutar acción 'condonar_adeudos'
- **Esperado:** status=error, mensaje 'Debe ingresar el número de oficio válido'

## Caso 4: Buscar Local Inexistente
- **Entrada:** Datos de local que no existe
- **Acción:** Ejecutar acción 'buscar_local'
- **Esperado:** status=error, mensaje 'No existe el local digitado'

## Caso 5: Listar Adeudos sin Local
- **Entrada:** id_local inválido
- **Acción:** Ejecutar acción 'listar_adeudos'
- **Esperado:** status=error, mensaje de validación
