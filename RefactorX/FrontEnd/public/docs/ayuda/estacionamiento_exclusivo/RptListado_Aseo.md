# Reporte: Lista de Adeudos de Aseo

## Propósito Administrativo
Módulo de generación de reportes impresos de adeudos de contratos de aseo. Produce documentos oficiales con periodos adeudados y montos para gestión de cobro.

## Funcionalidad Principal
Genera formatos impresos de listados de adeudos de aseo, mostrando periodos vencidos, importes, recargos calculados y totales por contrato.

## Proceso de Negocio

### ¿Qué hace?
Produce documentos de adeudos de aseo con formato oficial, calculando recargos automáticamente y mostrando información completa del contrato y empresa.

### ¿Para qué sirve?
- Generar listados de adeudos de aseo
- Calcular recargos por morosidad
- Planear emisión de requerimientos
- Documentar cartera vencida por empresa

### ¿Cómo lo hace?
1. Recibe parámetros del módulo Listados_Ade
2. Calcula recargos según normativa
3. Genera formato con datos del contrato
4. Totaliza por contrato
5. Produce documento oficial

## Datos y Tablas
Dataset de ta_16_adeudos_aseo con ta_16_contratos_aseo.

## Usuarios del Sistema
Invocado por el módulo Listados_Ade.

## Relaciones con Otros Módulos
- **Listados_Ade**: Módulo invocador
- **CMultEmision**: Usa estos listados
