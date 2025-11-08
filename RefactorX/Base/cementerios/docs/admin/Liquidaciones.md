# Liquidaciones - Liquidación Total de Adeudos

## Propósito Administrativo
Módulo especializado para procesar pagos totales que liquidan completamente todos los adeudos pendientes de un espacio funerario, aplicando automáticamente descuentos, bonificaciones y recargos vigentes.

## Funcionalidad Principal
Permite realizar la liquidación completa de todos los adeudos acumulados de mantenimiento anual de un folio RCM, calculando el monto total considerando recargos por mora, descuentos autorizados y bonificaciones aplicables, y generando el pago total en una sola operación.

## Proceso de Negocio

### ¿Qué hace?
Procesa liquidaciones totales de adeudos:
- Consulta todos los adeudos pendientes del folio
- Calcula recargos por mora según tabla oficial
- Aplica descuentos autorizados automáticamente
- Considera bonificaciones pendientes de aplicar
- Calcula descuento del 10% por pronto pago si aplica
- Genera monto total neto a pagar
- Registra pago de liquidación completa
- Actualiza todos los adeudos como pagados
- Actualiza último año pagado del registro

### ¿Para qué sirve?
Facilita el cobro total de adeudos acumulados:
- Regularización de concesionarios con años de atraso
- Liquidación previa a cesión de derechos
- Pago previo a traslados de restos
- Cobro antes de emisión de título
- Campañas de regularización masiva
- Liquidación por sucesión o herencia

### ¿Cómo lo hace?
1. El cajero captura datos del pago:
   - Fecha de pago
   - Recaudadora
   - Caja
   - Número de operación
   - Folio RCM a liquidar
2. El sistema verifica que el pago exista en ingresos
3. Consulta todos los adeudos pendientes del folio (vigencia="V")
4. Por cada adeudo calcula:
   - Importe base del adeudo
   - Recargos según tabla ta_13_recargosrcm
   - Descuentos autorizados (si aplica)
   - Descuento 10% pronto pago si es año actual y antes de marzo
   - Bonificaciones pendientes (si existen)
5. Suma total de todos los conceptos
6. Valida que el monto del ingreso sea suficiente para liquidar
7. Con autorización especial, permite liquidar con monto diferente
8. Registra pago en ta_13_pagosrcm con observación "LIQUIDACION"
9. Actualiza cada adeudo:
   - Asigna id_pago al adeudo
   - Registra descuentos aplicados
   - Marca como vigencia="P" (pagado)
10. Actualiza último año pagado en ta_13_datosrcm
11. Genera recibo de liquidación para entrega

### ¿Qué necesita para funcionar?
- Pago registrado en sistema de ingresos
- Folio RCM válido con adeudos pendientes
- Tabla de recargos actualizada
- Descuentos y bonificaciones configurados (si aplican)
- Autorización para liquidaciones especiales
- Permisos de usuario para procesar liquidaciones

## Datos y Tablas

### Tabla Principal
**ta_13_adeudosrcm** - Adeudos pendientes a liquidar

### Tablas Relacionadas
- **ta_13_datosrcm** - Registro del espacio (actualiza último año pagado)
- **ta_13_pagosrcm** - Registro del pago de liquidación
- **ta_13_recargosrcm** - Tabla de recargos por mora
- **ta_13_descuentos** - Descuentos autorizados aplicables
- **ta_13_bonifrcm** - Bonificaciones pendientes
- **ta_ingresos** - Validación del pago registrado

### Stored Procedures (SP)
Similar a ABCPagos, puede usar:
- **StrdPrcABpago** o proceso similar para aplicar liquidación completa

### Tablas que Afecta
**Inserta:**
- ta_13_pagosrcm (pago de liquidación)

**Actualiza:**
- ta_13_adeudosrcm (marca todos como pagados)
- ta_13_datosrcm (actualiza último año pagado al año más reciente)
- ta_13_bonifrcm (actualiza importe bonificado)

## Impacto y Repercusiones

### Repercusiones Operativas
- Agiliza regularización de cuentas atrasadas
- Reduce cartera vencida
- Facilita trámites posteriores
- Un solo movimiento liquida todo el historial

### Repercusiones Financieras
- Recuperación inmediata de cartera vencida
- Ingresos significativos por recargos acumulados
- Aplicación de descuentos y bonificaciones reduce monto
- Mejora indicadores de cobranza
- Impacto positivo en flujo de efectivo

### Repercusiones Administrativas
- Regularización de registros
- Limpieza de cartera antigua
- Cumplimiento de requisitos para trámites
- Facilita cierres contables
- Mejora estadísticas de cobranza

## Validaciones y Controles
- Verifica existencia del folio RCM
- Valida que existan adeudos pendientes
- Verifica que el pago esté registrado en ingresos
- Calcula correctamente recargos según tabla oficial
- Aplica descuentos solo si están vigentes
- Considera bonificaciones pendientes correctamente
- Valida que monto de pago cubra total calculado
- Requiere autorización para montos distintos
- Control transaccional completo (todo o nada)
- Impide liquidaciones parciales

## Casos de Uso
1. **Regularización de 5 años atrasados**: Cliente paga todo su adeudo histórico
2. **Liquidación previa a cesión**: Requisito para tramitar cesión de derechos
3. **Pago con descuento especial**: Liquidación aplicando 50% de descuento autorizado
4. **Liquidación por herencia**: Herederos liquidan adeudos del difunto
5. **Campaña de regularización**: Liquidación masiva con bonificación especial
6. **Requisito para título**: Liquidar antes de emitir título de propiedad
7. **Liquidación con pronto pago**: Aplicar 10% de descuento adicional

## Usuarios del Sistema
- **Cajeros Especializados**: Procesar liquidaciones
- **Supervisores de Caja**: Autorización de casos especiales
- **Personal de Títulos**: Validar liquidación antes de título
- **Personal de Traslados**: Verificar liquidación antes de traslado

## Relaciones con Otros Módulos
- **ABCementer/ABCFolio**: Consulta datos del registro
- **ABCPagos**: Proceso similar pero para pagos parciales
- **Descuentos**: Aplica descuentos registrados
- **Bonificaciones**: Considera bonificaciones pendientes
- **ABCRecargos**: Usa tabla de recargos para cálculo de mora
- **Títulos**: Requisito previo para emisión de título
- **Traslados**: Requisito previo para autorizar traslado
- **Rep_a_Cobrar**: Muestra quiénes requieren liquidación
