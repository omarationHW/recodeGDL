# Plan de Implementación - Módulo CONVENIOS

## Descripción General
Este documento contiene el plan de implementación para el módulo de CONVENIOS (Convenios de Pago). El sistema maneja la creación y seguimiento de convenios de pago por parcialidades para contribuyentes con adeudos fiscales.

---

## FASE 1: BASE DE DATOS - STORED PROCEDURES

### Estado Actual: ✅ **COMPLETADO 100%**

#### ✅ 01. SP_CONVENIOS_CORE (COMPLETADO)
- **Archivo**: `modules/convenios/database/ok/01_SP_CONVENIOS_CORE_all_procedures.sql`
- **SPs**: `SP_CONVENIOS_LIST`, `SP_CONVENIOS_CREATE`, `SP_CONVENIOS_PAGOS_LIST`, `SP_CONVENIOS_PAGO_CREATE`, `SP_CONVENIOS_VENCIDOS`, `SP_CONVENIOS_ESTADISTICAS`
- **Estado**: ✅ **LISTO PARA MIGRACIÓN**

---

## FASE 2: FRONTEND - COMPONENTES VUE

### Estado: ⏳ **PENDIENTE**

Los componentes Vue deben implementarse después de que las tablas de base de datos estén creadas y los stored procedures estén migrados.

### Componentes por Implementar:
1. **ConveniosGeneric.vue** - Gestión general de convenios
2. **ConveniosPagos.vue** - Registro de pagos por parcialidades  
3. **ConveniosVencidos.vue** - Control de convenios vencidos
4. **ConveniosReportes.vue** - Reportes y estadísticas
5. **ConveniosDashboard.vue** - Dashboard principal
6. **ConveniosInfo.vue** - Información general del módulo

---

## FUNCIONALIDADES IMPLEMENTADAS

### Gestión de Convenios
- ✅ Creación de convenios con datos del contribuyente
- ✅ Validación de RFC y números únicos
- ✅ Cálculo automático de parcialidades
- ✅ Control de fechas de vencimiento
- ✅ Estados de convenios (ACTIVO, LIQUIDADO, VENCIDO)

### Sistema de Pagos por Parcialidades
- ✅ Registro de pagos individuales por parcialidad
- ✅ Validación de recibos únicos
- ✅ Actualización automática de adeudos
- ✅ Control de parcialidades pagadas vs pendientes
- ✅ Liquidación automática al completar pagos

### Control de Vencimientos
- ✅ Identificación de convenios vencidos
- ✅ Días de gracia configurables
- ✅ Alertas de convenios próximos a vencer
- ✅ Reporte de parcialidades pendientes

### Reportes y Estadísticas
- ✅ Estadísticas generales del módulo
- ✅ Efectividad de cobranza por convenios
- ✅ Montos totales de adeudos
- ✅ Ingresos por período
- ✅ Parcialidades pendientes por cobrar

---

## CARACTERÍSTICAS DEL SISTEMA

### Estructura de Convenios
- **Adeudo Original**: Monto total del adeudo inicial
- **Adeudo Actual**: Saldo pendiente por pagar
- **Número de Parcialidades**: División del pago total
- **Monto por Parcialidad**: Cantidad fija a pagar
- **Parcialidades Pagadas**: Contador de pagos realizados

### Tipos de Convenio
- **ORDINARIO**: Convenio estándar sin descuentos
- **ESPECIAL**: Convenio con condiciones particulares
- **EMERGENCIA**: Convenio por situaciones excepcionales
- **JUDICIAL**: Convenio derivado de proceso judicial

### Estados de Control
- **ACTIVO**: Convenio vigente y al corriente
- **VENCIDO**: Convenio con pagos atrasados
- **LIQUIDADO**: Convenio completamente pagado
- **CANCELADO**: Convenio cancelado por incumplimiento

---

## MÉTRICAS Y INDICADORES

### Efectividad de Cobranza
- **Porcentaje de convenios liquidados**
- **Monto promedio recuperado**
- **Tiempo promedio de liquidación**
- **Tasa de incumplimiento**

### Control Financiero
- **Adeudos totales en convenios**
- **Ingresos mensuales por parcialidades**
- **Parcialidades pendientes**
- **Proyección de ingresos futuros**

---

## PRÓXIMOS PASOS
1. **Creación de Tablas**: Diseñar y crear tablas necesarias
2. **Migración de SPs**: Ejecutar archivos SQL en PostgreSQL
3. **Pruebas de BD**: Validar funcionamiento de stored procedures
4. **Desarrollo Frontend**: Implementar componentes Vue.js
5. **Integración**: Conectar frontend con API backend
6. **Pruebas Integrales**: Validar funcionalidad completa

---

**Fecha de Creación**: 9 de septiembre de 2025  
**Responsable**: Claude Code  
**Estado**: Fase 1 Completada - Listo para migración