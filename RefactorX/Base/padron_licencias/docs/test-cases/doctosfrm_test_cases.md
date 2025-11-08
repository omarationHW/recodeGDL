# Casos de Prueba para doctosfrm

## Caso 1: Guardar selección de documentos
- **Entrada:**
  - tramite_id: 123
  - documentos: ["fotofachada", "recibopredial"]
  - otro: "Carta de recomendación"
- **Acción:** POST /api/execute { action: 'save', data: ... }
- **Esperado:**
  - Respuesta success: true
  - Mensaje: "Documentos guardados"
  - En base de datos, la fila para tramite_id=123 contiene los documentos y el campo otro

## Caso 2: Obtener selección de documentos
- **Entrada:**
  - tramite_id: 123
- **Acción:** POST /api/execute { action: 'get', data: ... }
- **Esperado:**
  - Respuesta success: true
  - Devuelve documentos: ["fotofachada", "recibopredial"] y otro: "Carta de recomendación"

## Caso 3: Limpiar selección
- **Entrada:**
  - tramite_id: 123
- **Acción:** POST /api/execute { action: 'clear', data: ... }
- **Esperado:**
  - Respuesta success: true
  - Mensaje: "Selección limpiada"
  - En base de datos, la fila para tramite_id=123 tiene documentos = [] y otro = null

## Caso 4: Eliminar documento específico
- **Entrada:**
  - tramite_id: 123
  - documento: "recibopredial"
- **Acción:** POST /api/execute { action: 'delete', data: ... }
- **Esperado:**
  - Respuesta success: true
  - Mensaje: "Documento eliminado"
  - En base de datos, el array documentos ya no contiene "recibopredial"

## Caso 5: Listar catálogo de documentos
- **Entrada:**
  - Sin parámetros
- **Acción:** POST /api/execute { action: 'list', data: {} }
- **Esperado:**
  - Respuesta success: true
  - Devuelve lista de documentos con código y descripción
