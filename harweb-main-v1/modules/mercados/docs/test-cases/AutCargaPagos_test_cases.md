# Casos de Prueba: AutCargaPagos

## 1. Crear autorización válida
- **Entrada:** Todos los campos requeridos completos y válidos
- **Acción:** POST /api/execute { action: 'create', params: {...} }
- **Esperado:** success: true, data contiene la autorización creada

## 2. Crear autorización con campo faltante
- **Entrada:** Falta 'fecha_limite'
- **Acción:** POST /api/execute { action: 'create', params: { ...sin fecha_limite... } }
- **Esperado:** success: false, message indica campo requerido

## 3. Modificar autorización existente
- **Entrada:** Cambiar fecha_limite y comentarios
- **Acción:** POST /api/execute { action: 'update', params: {...} }
- **Esperado:** success: true, data contiene la autorización actualizada

## 4. Consultar lista de autorizaciones
- **Entrada:** action: 'list', params: {}
- **Acción:** POST /api/execute
- **Esperado:** success: true, data es un array de autorizaciones

## 5. Consultar detalle de autorización
- **Entrada:** action: 'show', params: { fecha_ingreso, oficina }
- **Acción:** POST /api/execute
- **Esperado:** success: true, data contiene los detalles

## 6. Validar seguridad
- **Entrada:** Usuario no autenticado
- **Acción:** POST /api/execute
- **Esperado:** HTTP 401 Unauthorized

## 7. Validar integridad de datos
- **Entrada:** 'autorizar' con valor inválido ('X')
- **Acción:** POST /api/execute { action: 'create', params: {..., autorizar: 'X', ...} }
- **Esperado:** success: false, message indica valor inválido
