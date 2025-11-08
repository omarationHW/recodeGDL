# Casos de Prueba: Actualización de Periodo de Inicio de Obligación

## Caso 1: Consulta de Contrato Existente
- **Entrada:** num_contrato=1803, ctrol_aseo=8
- **Acción:** buscarContrato
- **Esperado:** Devuelve datos completos del contrato, incluyendo aso_mes_oblig

## Caso 2: Actualización Exitosa
- **Entrada:** control_contrato=5678, anio=2024, mes="03", documento="DR/14/2024", descripcion="Cambio por resolución administrativa"
- **Acción:** actualizarPeriodoObligacion
- **Esperado:** status=0, message indica éxito, periodo actualizado en base de datos y registro en histórico

## Caso 3: Actualización con Mismo Periodo
- **Entrada:** control_contrato=5678, anio=2023, mes="01", documento="DR/14/2023", descripcion="Intento sin cambio"
- **Acción:** actualizarPeriodoObligacion
- **Esperado:** status=3, message indica que el periodo es igual al actual, no hay cambios

## Caso 4: Faltan Parámetros
- **Entrada:** control_contrato=5678, anio=2024, mes="03", documento="", descripcion=""
- **Acción:** actualizarPeriodoObligacion
- **Esperado:** status=1, message indica falta de documento

## Caso 5: Contrato No Existe
- **Entrada:** num_contrato=999999, ctrol_aseo=8
- **Acción:** buscarContrato
- **Esperado:** success=false, message indica que no existe contrato
