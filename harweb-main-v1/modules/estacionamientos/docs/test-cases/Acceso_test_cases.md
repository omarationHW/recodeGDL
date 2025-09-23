# Casos de Prueba

## Caso 1: Inicio de sesión exitoso
- **Entrada:** usuario: admin, contraseña: 1234
- **Acción:** POST /api/execute { action: 'login', params: { username: 'admin', password: '1234' } }
- **Esperado:** success: true, user contiene datos, redirección a menú

## Caso 2: Contraseña incorrecta
- **Entrada:** usuario: admin, contraseña: wrongpass
- **Acción:** POST /api/execute { action: 'login', params: { username: 'admin', password: 'wrongpass' } }
- **Esperado:** success: false, error: 'Usuario o contraseña incorrectos'

## Caso 3: Consulta de folios por año y placa
- **Entrada:** year: 2024, placa: 'ABC123'
- **Acción:** POST /api/execute { action: 'getFoliosReport', params: { year: 2024, placa: 'ABC123' } }
- **Esperado:** success: true, folios: [ ... ]

## Caso 4: Registro de folio duplicado
- **Entrada:** year: 2024, folio: 1001, placa: 'XYZ789', ...
- **Acción:** POST /api/execute { action: 'registerFolio', params: { ... } }
- **Esperado:** success: false, message: 'Folio ya existe para el año'

## Caso 5: Consulta de catálogo de infracciones
- **Entrada:** catalog: 'infracciones'
- **Acción:** POST /api/execute { action: 'getCatalog', params: { catalog: 'infracciones' } }
- **Esperado:** success: true, catalog: [ ... ]
