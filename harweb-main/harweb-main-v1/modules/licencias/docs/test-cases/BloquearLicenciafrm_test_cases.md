# Casos de Prueba: BloquearLicenciafrm

## 1. Bloqueo exitoso
- Buscar licencia vigente
- Bloquear con tipo 1 y motivo 'Incumplimiento'
- Verificar que el estado cambia a BLOQUEADO
- Verificar que aparece en el histórico

## 2. Desbloqueo exitoso
- Buscar licencia con bloqueo activo
- Desbloquear seleccionando el bloqueo y motivo 'Cumplió requisitos'
- Verificar que el estado cambia a NO BLOQUEADO o al siguiente bloqueo activo
- Verificar que aparece el movimiento de desbloqueo en el histórico

## 3. Bloqueo duplicado
- Buscar licencia ya bloqueada por tipo 1
- Intentar bloquear de nuevo con tipo 1
- Verificar que el sistema rechaza la operación y muestra mensaje de error

## 4. Desbloqueo sin bloqueos activos
- Buscar licencia sin bloqueos activos
- Intentar desbloquear
- Verificar que el sistema rechaza la operación y muestra mensaje de error

## 5. Validación de campos
- Intentar bloquear sin seleccionar tipo o motivo
- Verificar que el sistema muestra mensaje de error

## 6. Integridad de domicilio bloqueado
- Bloquear licencia y verificar que se inserta en bloqueo_dom si corresponde
- Desbloquear y verificar que se elimina de bloqueo_dom y se guarda en h_bloqueo_dom
