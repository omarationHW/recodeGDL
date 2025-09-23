## Casos de Prueba para Firma Electrónica

### Prueba 1: Listar Folios Correctamente
- **Entrada:**
  - action: listarFolios
  - modulo: 14
  - fecha: 2024-06-01
- **Esperado:**
  - success: true
  - data: Array con folios (campos: cvereq, fecemi, folio, diligencia, cadena1, cadena2, descripcion)

### Prueba 2: Validación de Parámetros Faltantes
- **Entrada:**
  - action: listarFolios
  - modulo: (no enviado)
  - fecha: 2024-06-01
- **Esperado:**
  - success: false
  - message: 'The modulo field is required.'

### Prueba 3: Generar Firma para Folio Nuevo
- **Entrada:**
  - action: generarFirma
  - modulo: 14
  - tipoformato: 1
  - id: 456
  - fecha: 2024-06-02
  - cadenaoriginal: 'abcdef'
  - ruta: ''
- **Esperado:**
  - success: true
  - data[0].codigo: 0
  - data[0].descripcion: 'Firma generada correctamente'

### Prueba 4: Generar Firma para Folio Ya Firmado
- **Entrada:**
  - action: generarFirma
  - modulo: 14
  - tipoformato: 1
  - id: 456
  - fecha: 2024-06-02
  - cadenaoriginal: 'abcdef'
  - ruta: ''
- **Esperado:**
  - success: true
  - data[0].codigo: 1
  - data[0].descripcion: 'Ya existe firma para este folio'

### Prueba 5: Insertar Firma Electrónica
- **Entrada:**
  - action: insertarFirma
  - secuencia: 789
  - digverificador: 'XYZ12'
  - id_modulo: 456
  - fecha_graba: '2024-06-02'
  - vigencia: 'V'
  - firmante: 'Juan Pérez'
  - cargo: 'Director'
  - validez: '2024-06-02 2025-06-02'
  - fecha_firmado: '2024-06-02'
  - hash: 'abcdef123456'
- **Esperado:**
  - success: true
  - data[0].graba: 1
  - data[0].existe: 0

### Prueba 6: Insertar Firma Ya Existente
- **Entrada:**
  - action: insertarFirma
  - secuencia: 789
  - digverificador: 'XYZ12'
  - id_modulo: 456
  - fecha_graba: '2024-06-02'
  - vigencia: 'V'
  - firmante: 'Juan Pérez'
  - cargo: 'Director'
  - validez: '2024-06-02 2025-06-02'
  - fecha_firmado: '2024-06-02'
  - hash: 'abcdef123456'
- **Esperado:**
  - success: true
  - data[0].graba: 0
  - data[0].existe: 1

### Prueba 7: Listar Firmas Generadas
- **Entrada:**
  - action: listarFirmasGeneradas
  - modulo: 14
  - fecha: 2024-06-02
- **Esperado:**
  - success: true
  - data: Array con firmas generadas (campos: secuencia, digverificador, modulo, id_modulo, fechagraba, firmante, cargo, fecha_firmado, hash)
