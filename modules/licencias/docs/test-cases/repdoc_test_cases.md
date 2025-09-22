# Casos de Prueba para Formulario repdoc

## Caso 1: Consulta de requisitos para giro existente
- **Entrada:** id_giro=1201
- **Acción:** getRequisitosByGiro
- **Esperado:** Lista de requisitos no vacía, cada requisito tiene descripción.

## Caso 2: Consulta de requisitos para giro inexistente
- **Entrada:** id_giro=999999
- **Acción:** getRequisitosByGiro
- **Esperado:** Lista vacía.

## Caso 3: Búsqueda de giros por texto
- **Entrada:** actividad='farmacia'
- **Acción:** getGiros + filtro frontend
- **Esperado:** Solo giros con 'farmacia' en descripción.

## Caso 4: Impresión de requisitos
- **Acción:** printRequisitos con id_giro válido
- **Esperado:** Se genera reporte con encabezado, giro, tipo, actividad y requisitos.

## Caso 5: Selección de giro y actualización de requisitos
- **Acción:** Seleccionar un giro diferente
- **Esperado:** Se actualiza la información de giro y la lista de requisitos.
