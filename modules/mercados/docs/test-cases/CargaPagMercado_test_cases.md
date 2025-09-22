# Casos de Prueba para CargaPagMercado

## Caso 1: Carga Correcta
- **Entradas:**
  - oficina: 1
  - mercado: 10
  - categoria: 2
  - seccion: 'A'
  - local: 123
  - fecha_pago: '2024-06-10'
  - oficina_pago: 1
  - caja: '01'
  - operacion: 1001
  - usuario_id: 5
  - pagos: [{id_local: 123, axo: 2024, periodo: 6, importe: 1000, partida: 'P001'}]
- **Acción:** POST /api/execute {action: 'insertPagosMercado', params: ...}
- **Esperado:**
  - HTTP 200, success: true, message: 'Pagos cargados correctamente'
  - El adeudo del local 123, año 2024, periodo 6, desaparece de la tabla de adeudos

## Caso 2: Importe Excedido
- **Entradas:**
  - pagos: suma de importes mayor al ingreso disponible
- **Acción:** POST /api/execute {action: 'insertPagosMercado', params: ...}
- **Esperado:**
  - HTTP 200, success: false, message: 'El Importe total (...) de locales a capturar es mayor al importe por capturar'
  - No se graba ningún pago

## Caso 3: Partidas Vacías
- **Entradas:**
  - pagos: algunos con partida vacía o cero
- **Acción:** POST /api/execute {action: 'insertPagosMercado', params: ...}
- **Esperado:**
  - HTTP 200, success: true
  - Solo se graban los pagos con partida válida
  - Los adeudos correspondientes se eliminan

## Caso 4: Validación de Campos Obligatorios
- **Entradas:**
  - Falta algún campo obligatorio en params
- **Acción:** POST /api/execute {action: 'insertPagosMercado', params: ...}
- **Esperado:**
  - HTTP 200, success: false, message: 'Completa todos los campos para buscar.'

## Caso 5: Consulta de Adeudos
- **Entradas:**
  - oficina, mercado, categoria, seccion, local
- **Acción:** POST /api/execute {action: 'getAdeudosLocal', params: ...}
- **Esperado:**
  - HTTP 200, success: true, data: [ ...adeudos... ]
