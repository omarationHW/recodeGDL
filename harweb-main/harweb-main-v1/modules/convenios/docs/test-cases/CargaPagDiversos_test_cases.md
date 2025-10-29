# Casos de Prueba para CargaPagDiversos

## 1. Búsqueda exitosa de pagos diversos
- **Entradas**: fecha_desde=2024-06-01, fecha_hasta=2024-06-10, recaudadora=3
- **Acción**: POST /api/execute { action: 'buscarPagosDiversos', params: { ... } }
- **Resultado esperado**: Lista de pagos diversos pendientes (array no vacío)

## 2. Carga exitosa de pagos seleccionados
- **Entradas**: pagos=[{fecing:..., recing:..., ...}]
- **Acción**: POST /api/execute { action: 'grabarPagosDiversos', params: { pagos: [...] } }
- **Resultado esperado**: success=true, message='Carga de Pagos de Diversos ejecutada satisfactoriamente.'

## 3. Error por contrato inexistente
- **Entradas**: pagos=[{colonia:999, obra:999, numero:999, ...}]
- **Acción**: POST /api/execute { action: 'grabarPagosDiversos', params: { pagos: [...] } }
- **Resultado esperado**: success=false, errors contiene mensaje 'No existe el contrato para Colonia: 999...'

## 4. Error de autorización por recaudadora
- **Entradas**: usuario nivel=2, recaudadora=1 (usuario tiene recaudadora=2)
- **Acción**: POST /api/execute { action: 'buscarPagosDiversos', params: { ... } }
- **Resultado esperado**: success=false, message='No tienes autorización para cargar pagos de otra recaudadora.'

## 5. Validación de parámetros requeridos
- **Entradas**: falta fecha_desde
- **Acción**: POST /api/execute { action: 'buscarPagosDiversos', params: { fecha_hasta:..., recaudadora:... } }
- **Resultado esperado**: success=false, errors contiene 'fecha_desde' requerido
