# Adeudos_Pag

## Propósito Administrativo
Administración y control de adeudos y pagos del sistema de aseo (recolección de basura/limpieza urbana).

## Funcionalidad Principal
Este módulo se clasifica como: **Gestión de Adeudos**

### Descripción
Módulo para registrar el pago de adeudos de contratos de aseo. Permite marcar como pagadas las cuotas normales y exedencias, registrando los datos de la transacción.

## Proceso de Negocio

### ¿Qué hace?
1. Busca adeudos pendientes por número de contrato y período
2. Muestra cuota normal y exedencias pendientes
3. Permite capturar datos del pago (recaudadora, caja, fecha, folios)
4. Actualiza el estatus de los adeudos a "Pagado"
5. Registra información completa de la transacción de pago

### ¿Para qué sirve?
- Registrar pagos realizados por los contribuyentes
- Actualizar el estado de cuenta de los contratos
- Mantener control de caja y recaudación
- Generar histórico de pagos

### ¿Cómo lo hace?
1. Usuario captura número de contrato, tipo de aseo y período
2. Sistema busca adeudos vigentes para ese contrato/período
3. Muestra cuota normal y exedencias (si existen)
4. Indica si ya están pagados o están pendientes
5. Usuario selecciona qué conceptos se pagan
6. Captura datos de pago: recaudadora, caja, consecutivo, folio, fecha
7. Sistema actualiza registros cambiando status de "V" (Vigente) a "P" (Pagado)
8. Guarda información de pago para trazabilidad

### ¿Qué necesita para funcionar?
- Contratos registrados en el sistema
- Adeudos generados (cuotas normales y/o exedencias)
- Catálogo de recaudadoras
- Catálogo de cajas
- Usuario con permisos de captura de pagos

## Datos y Tablas

### Tabla Principal
- **ta_16_pagos**: Tabla principal que maneja este módulo

### Tablas Relacionadas
- **ta_16_contratos**: Tabla relacionada utilizada en el módulo
- **ta_16_operacion**: Tabla relacionada utilizada en el módulo
- **ta_16_unidades**: Tabla relacionada utilizada en el módulo

### Stored Procedures (SP)
- No se identificaron stored procedures explícitos

### Operaciones SQL
Este módulo realiza operaciones: Select, Update

### Tablas que Afecta
Modifica registros en: ta_16_contratos, ta_16_operacion, ta_16_pagos, ta_16_unidades

## Impacto y Repercusiones

### Repercusiones Operativas
- Impacta directamente en la recaudación
- Afecta el estado de cuenta de contribuyentes
- Influye en indicadores de cobranza
- Determina saldos pendientes

### Repercusiones Financieras
- Impacto directo en ingresos municipales
- Afecta cuentas por cobrar
- Influye en flujo de efectivo
- Determina montos de recaudación

### Repercusiones Administrativas
- Genera registros para auditoría
- Mantiene histórico de operaciones
- Facilita generación de reportes gerenciales
- Apoya en indicadores de gestión

## Validaciones y Controles
- Validación de existencia del contrato
- Verificación de adeudos vigentes
- Control de datos de pago completos
- Validación de estatus antes de actualizar
- Control transaccional
- Registro de trazabilidad (usuario, fecha, hora)

## Casos de Uso
1. **Pago en ventanilla**: Contribuyente acude a pagar su cuota mensual, el cajero localiza el adeudo, captura datos de pago y genera recibo
2. **Pago con exedencia**: Contribuyente que tiene tanto cuota normal como exedencias, el cajero puede cobrar ambos conceptos o solo uno
3. **Consulta de adeudos pagados**: Verificación de pagos anteriores revisando fecha, recaudadora y folio

## Usuarios del Sistema
- **Cajeros**: Personal de recaudadora que recibe pagos
- **Supervisores de caja**: Personal que controla operaciones de caja
- **Administrativos de cobranza**: Personal que gestiona adeudos

## Relaciones con Otros Módulos
- **Contratos**: Consulta información del contrato
- **Adeudos**: Actualiza el estatus de los adeudos
- **Recaudadoras**: Utiliza catálogo de recaudadoras
- **Cajas**: Utiliza catálogo de cajas
- **Reportes de pagos**: Información de este módulo alimenta reportes


---
**Nota**: Este documento fue generado mediante análisis automatizado del código fuente. La información presentada se enfoca en aspectos administrativos y de negocio del módulo.
