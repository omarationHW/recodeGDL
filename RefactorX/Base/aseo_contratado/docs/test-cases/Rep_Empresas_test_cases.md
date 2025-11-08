# Casos de Prueba: Reporte de Empresas

## Caso 1: Reporte por Número de Empresa
- **Entrada:** action: getEmpresasReport, params: { order: 1 }
- **Esperado:** Lista de empresas ordenadas por num_empresa ascendente.
- **Validación:** El primer registro tiene el menor num_empresa.

## Caso 2: Reporte por Tipo de Empresa
- **Entrada:** action: getEmpresasReport, params: { order: 2 }
- **Esperado:** Empresas agrupadas por tipo_empresa, ordenadas alfabéticamente.
- **Validación:** Todos los registros de un tipo aparecen juntos.

## Caso 3: Reporte por Nombre
- **Entrada:** action: getEmpresasReport, params: { order: 3 }
- **Esperado:** Empresas ordenadas por descripcion (nombre).
- **Validación:** El orden alfabético es correcto.

## Caso 4: Reporte por Representante
- **Entrada:** action: getEmpresasReport, params: { order: 4 }
- **Esperado:** Empresas ordenadas por representante.
- **Validación:** El campo representante está en orden alfabético.

## Caso 5: Parámetro inválido
- **Entrada:** action: getEmpresasReport, params: { order: 99 }
- **Esperado:** Lista vacía o error controlado.
- **Validación:** El backend retorna status error o data vacía.

## Caso 6: Opciones de orden
- **Entrada:** action: getReportOptions
- **Esperado:** Lista de opciones con id y label.
- **Validación:** Hay al menos 4 opciones y la primera es 'Número'.
