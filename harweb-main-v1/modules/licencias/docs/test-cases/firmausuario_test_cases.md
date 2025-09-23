## Casos de Prueba para FirmaUsuario

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|--------------------|
| 1 | Validación exitosa | usuario: 'jdoe', firma: 'abc123' | success: true, message: 'Firma validada correctamente.' |
| 2 | Firma incorrecta | usuario: 'jdoe', firma: 'wrongpass' | success: false, message: 'Usuario o firma incorrectos.' |
| 3 | Usuario inexistente | usuario: 'ghost', firma: 'cualquier' | success: false, message: 'Usuario o firma incorrectos.' |
| 4 | Campos vacíos | usuario: '', firma: '' | success: false, errors: usuario y firma obligatorios |
| 5 | Usuario vacío | usuario: '', firma: 'abc123' | success: false, errors: usuario obligatorio |
| 6 | Firma vacía | usuario: 'jdoe', firma: '' | success: false, errors: firma obligatoria |
| 7 | SQL Injection intento | usuario: "' OR '1'='1", firma: 'abc123' | success: false, message: 'Usuario o firma incorrectos.' |
