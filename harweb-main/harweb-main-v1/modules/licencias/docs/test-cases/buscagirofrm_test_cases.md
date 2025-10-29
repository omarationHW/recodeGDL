# Casos de Prueba: Buscagiro

## Caso 1: Búsqueda básica por descripción
- **Entrada:** descripcion = 'papelería', tipo = 'L', autoev = false, pacto = false
- **Acción:** POST /api/execute { action: 'buscagiro_list', params: { ... } }
- **Esperado:** Respuesta JSON con lista de giros que contienen 'papelería' en la descripción

## Caso 2: Filtro solo autoevaluación
- **Entrada:** descripcion = '', tipo = 'L', autoev = true, pacto = false
- **Acción:** POST /api/execute { action: 'buscagiro_list', params: { ... } }
- **Esperado:** Solo giros permitidos para autoevaluación

## Caso 3: Sin resultados
- **Entrada:** descripcion = 'zzzzzz', tipo = 'L', autoev = false, pacto = false
- **Acción:** POST /api/execute { action: 'buscagiro_list', params: { ... } }
- **Esperado:** Respuesta JSON con data: []

## Caso 4: Permisos restringidos
- **Entrada:** usuario sin permiso giro_a, tipo = 'L', descripcion = ''
- **Acción:** POST /api/execute { action: 'buscagiro_list', params: { ... } }
- **Esperado:** No aparecen giros tipo A

## Caso 5: Selección de giro
- **Entrada:** id_giro = 1234
- **Acción:** POST /api/execute { action: 'buscagiro_select', params: { id_giro: 1234 } }
- **Esperado:** Respuesta JSON con los datos completos del giro 1234
