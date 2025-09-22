## Casos de Prueba para AdeudosExe_Del

### 1. Baja Física Exitosa
- **Entrada:**
  - contrato: 12345
  - ctrol_aseo: 9
  - aso: 2024
  - mes: 6
  - ctrol_operacion: 3
  - usuario_id: 1
  - action: delete
- **Esperado:**
  - Respuesta success: true
  - Mensaje: "Baja física realizada"
  - El registro es eliminado de ta_16_pagos

### 2. Baja Lógica Exitosa
- **Entrada:**
  - contrato: 12345
  - ctrol_aseo: 9
  - aso: 2024
  - mes: 6
  - ctrol_operacion: 3
  - oficio: "OF123456"
  - usuario_id: 1
  - action: logic_delete
- **Esperado:**
  - Respuesta success: true
  - Mensaje: "Baja lógica realizada"
  - El registro es actualizado con status_vigencia = 'B', usuario y folio_rcbo

### 3. Contrato No Encontrado
- **Entrada:**
  - contrato: 99999
  - ctrol_aseo: 9
  - action: list
- **Esperado:**
  - Respuesta success: false
  - Mensaje: "Contrato no encontrado"

### 4. Baja Física con Registro Inexistente
- **Entrada:**
  - contrato: 12345
  - ctrol_aseo: 9
  - aso: 2024
  - mes: 6
  - ctrol_operacion: 99
  - usuario_id: 1
  - action: delete
- **Esperado:**
  - Respuesta success: true
  - data.deleted = 0
  - Mensaje: "Baja física realizada"

### 5. Validación de Campos Obligatorios
- **Entrada:**
  - contrato: null
  - ctrol_aseo: null
  - action: delete
- **Esperado:**
  - Respuesta success: false
  - Mensaje de error de validación
