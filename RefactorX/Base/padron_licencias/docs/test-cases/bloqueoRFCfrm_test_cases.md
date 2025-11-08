# Casos de Prueba para Bloqueo de RFC

## 1. Alta de bloqueo exitoso
- **Precondición:** RFC no está bloqueado vigente
- **Acción:** Alta con datos válidos
- **Esperado:** Registro insertado, aparece en la tabla

## 2. Alta de bloqueo duplicado
- **Precondición:** RFC ya bloqueado vigente
- **Acción:** Intentar alta de nuevo
- **Esperado:** Error de duplicidad

## 3. Desbloqueo exitoso
- **Precondición:** RFC bloqueado vigente
- **Acción:** Desbloquear
- **Esperado:** Vig cambia a 'C', ya no aparece como vigente

## 4. Edición de motivo
- **Precondición:** RFC bloqueado vigente
- **Acción:** Editar motivo
- **Esperado:** Motivo actualizado, fecha/hora actualizada

## 5. Búsqueda por RFC parcial
- **Acción:** Buscar por parte del RFC
- **Esperado:** Solo aparecen RFCs que contienen el texto

## 6. Exportación a Excel
- **Acción:** Hacer clic en exportar
- **Esperado:** Descarga de archivo CSV con todos los registros

## 7. Validación de campos obligatorios
- **Acción:** Intentar alta sin RFC o sin motivo
- **Esperado:** Error de validación

## 8. Consulta de trámite inexistente
- **Acción:** Buscar trámite con ID inexistente
- **Esperado:** Error 404
