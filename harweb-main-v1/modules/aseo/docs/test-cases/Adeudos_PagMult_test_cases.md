# Casos de Prueba: Adeudos_PagMult

## Caso 1: Pago múltiple exitoso
- Buscar contrato existente con adeudos vigentes
- Seleccionar varios adeudos
- Llenar todos los datos de pago
- Ejecutar pago
- Verificar en la base de datos que los registros cambian a status 'P' y los campos de pago se actualizan

## Caso 2: Intento de pago sin selección
- Buscar contrato con adeudos vigentes
- No seleccionar ningún adeudo
- Llenar datos de pago
- Ejecutar pago
- Verificar que el sistema muestra mensaje de error y no realiza ningún cambio en la base de datos

## Caso 3: Intento de pago con datos incompletos
- Buscar contrato con adeudos vigentes
- Seleccionar uno o más adeudos
- Omitir algún campo obligatorio de pago (ejemplo: consecutivo)
- Ejecutar pago
- Verificar que el sistema muestra mensaje de error y no realiza ningún cambio en la base de datos

## Caso 4: Contrato inexistente
- Ingresar un número de contrato que no existe
- Buscar
- Verificar que el sistema muestra mensaje de error 'Contrato no encontrado'

## Caso 5: Integridad de transacción
- Simular error en la base de datos durante el pago
- Verificar que ningún adeudo cambia de estado y se revierte la transacción
