# Casos de Prueba para Contratos_Upd_IniObl

## 1. Actualización exitosa
- **Entrada:** Contrato vigente, ejercicio y mes válidos, documento y descripción válidos.
- **Acción:** POST /api/execute { action: 'update', ... }
- **Esperado:** Respuesta success=true, mensaje de éxito, pagos actualizados en BD.

## 2. Contrato inexistente o no vigente
- **Entrada:** Contrato no existente o status_vigencia != 'V'.
- **Acción:** POST /api/execute { action: 'update', ... }
- **Esperado:** Respuesta success=false, mensaje 'No existe contrato vigente...'.

## 3. Fecha de inicio igual a la actual
- **Entrada:** Fecha de inicio igual a la ya registrada en el contrato.
- **Acción:** POST /api/execute { action: 'update', ... }
- **Esperado:** Respuesta success=false, mensaje 'La fecha de inicio de obligación es igual a la actual'.

## 4. Campos obligatorios faltantes
- **Entrada:** Falta documento, ejercicio, mes, etc.
- **Acción:** POST /api/execute { action: 'update', ... }
- **Esperado:** Respuesta success=false, mensaje de validación.

## 5. Carga de catálogos
- **Acción:** POST /api/execute { action: 'catalogs' }
- **Esperado:** Respuesta success=true, data con tiposAseo y meses.

## 6. Búsqueda de contrato
- **Entrada:** Contrato y tipo de aseo válidos.
- **Acción:** POST /api/execute { action: 'search', ... }
- **Esperado:** Respuesta success=true, data con detalles del contrato.

## 7. Búsqueda de contrato inexistente
- **Entrada:** Contrato y tipo de aseo no existentes.
- **Acción:** POST /api/execute { action: 'search', ... }
- **Esperado:** Respuesta success=false, mensaje de error.
