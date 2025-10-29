# Casos de Prueba para CallesMntto

## 1. Alta de Calle Exitosa
- **Entrada:** Todos los campos válidos (ver datos de prueba del caso de uso 1)
- **Acción:** POST /api/execute { action: 'insertCalle', params: ... }
- **Esperado:** success=true, message='Calle insertada correctamente', la calle aparece en la consulta

## 2. Edición de Calle Existente
- **Entrada:** Todos los campos válidos, colonia/calle existente (ver datos de prueba del caso de uso 2)
- **Acción:** POST /api/execute { action: 'updateCalle', params: ... }
- **Esperado:** success=true, message='Calle actualizada correctamente', los cambios reflejados en la consulta

## 3. Validación de Campos Requeridos
- **Entrada:** Falta campo obligatorio (desc_calle='')
- **Acción:** POST /api/execute { action: 'insertCalle', params: ... }
- **Esperado:** success=false, message='The desc_calle field is required.'

## 4. Consulta de Catálogos
- **Acción:** POST /api/execute { action: 'getCatalogs' }
- **Esperado:** success=true, data.colonias/servicios/tipos/cuentas no vacíos

## 5. Consulta de Calle Específica
- **Acción:** POST /api/execute { action: 'getCalle', params: { colonia: 1, calle: 101 } }
- **Esperado:** success=true, data contiene la calle buscada

## 6. Error de Actualización (Calle no existe)
- **Entrada:** colonia/calle inexistente
- **Acción:** POST /api/execute { action: 'updateCalle', params: ... }
- **Esperado:** success=false, message='No se encontró la calle para actualizar'
