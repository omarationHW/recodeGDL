# Casos de Prueba: Claves Catastrales Duplicadas

## 1. Consulta sin filtro
- **Acción:** Enviar `{ action: 'getCveCatDupList', params: {} }` a `/api/execute`
- **Esperado:** Respuesta `success: true` y lista de registros

## 2. Consulta con filtro por clave
- **Acción:** Enviar `{ action: 'getCveCatDupList', params: { cvecatnva: 'D6512345678' } }`
- **Esperado:** Solo registros con esa clave

## 3. Agregar registro válido
- **Acción:** Enviar `{ action: 'addCveCatDup', params: { recaud: 5, urbrus: 'U', cuenta: 123456, cvecatnva: 'D6512345678' } }`
- **Esperado:** `success: true`, mensaje de éxito, registro aparece en consulta

## 4. Agregar registro con datos faltantes
- **Acción:** Omitir algún campo obligatorio
- **Esperado:** `success: false`, mensaje de error de validación

## 5. Eliminar registro existente
- **Acción:** Enviar `{ action: 'deleteCveCatDup', params: { recaud: 5, urbrus: 'U', cuenta: 123456, cvecatnva: 'D6512345678' } }`
- **Esperado:** `success: true`, mensaje de éxito, registro ya no aparece en consulta

## 6. Eliminar registro inexistente
- **Acción:** Eliminar un registro que no existe
- **Esperado:** `success: true` (o error controlado), sin afectar otros registros

## 7. Prueba de concurrencia
- **Acción:** Dos usuarios agregan el mismo registro simultáneamente
- **Esperado:** Uno de los inserts falla por restricción de unicidad (si existe)
