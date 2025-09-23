## Casos de Prueba: Condonación de Adeudos

### Caso 1: Condonar un adeudo exitosamente
- **Entrada:** num_contrato=12345, ctrol_aseo=9, aso=2024, mes=06, ctrol_operacion=8, oficio=OF-2024-001
- **Acción:** Ejecutar condonación
- **Esperado:** Respuesta success=true, mensaje de éxito, registro actualizado en ta_16_pagos

### Caso 2: Intentar condonar un adeudo inexistente
- **Entrada:** num_contrato=12345, ctrol_aseo=9, aso=2023, mes=01, ctrol_operacion=8, oficio=OF-2023-002
- **Acción:** Ejecutar condonación
- **Esperado:** Respuesta success=false, mensaje de error, sin cambios en la base de datos

### Caso 3: Validación de campos obligatorios
- **Entrada:** num_contrato vacío, ctrol_aseo vacío, aso=2024, mes=06, ctrol_operacion vacío, oficio vacío
- **Acción:** Ejecutar condonación
- **Esperado:** Mensaje de error en frontend, sin llamada a backend

### Caso 4: Error de base de datos (simulado)
- **Entrada:** Datos válidos pero la base de datos falla
- **Acción:** Ejecutar condonación
- **Esperado:** Respuesta success=false, mensaje de error técnico, sin cambios en la base de datos

### Caso 5: Usuario no autenticado
- **Entrada:** Cualquier
- **Acción:** Ejecutar condonación sin autenticación
- **Esperado:** Respuesta HTTP 401 Unauthorized
