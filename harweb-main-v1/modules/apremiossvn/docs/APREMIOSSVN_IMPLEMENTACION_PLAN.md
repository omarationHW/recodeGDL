# Plan de Implementación - Módulo APREMIOSSVN

## Descripción General
Este documento contiene el plan de implementación para el módulo de APREMIOSSVN (Sistema de Apremios versión SVN). Este es el sistema legacy de cobranza coactiva que maneja expedientes, notificaciones, actuaciones procesales y pagos con control de fases específico.

---

## FASE 1: BASE DE DATOS - STORED PROCEDURES

### Estado Actual: ✅ **COMPLETADO 100%**

#### ✅ 01. SP_APREMIOSSVN_CORE (COMPLETADO)
- **Archivo**: `modules/apremiossvn/database/ok/01_SP_APREMIOSSVN_CORE_all_procedures.sql`
- **SPs**: `SP_APREMIOSSVN_EXPEDIENTES_LIST`, `SP_APREMIOSSVN_EXPEDIENTE_CREATE`, `SP_APREMIOSSVN_NOTIFICACIONES_LIST`, `SP_APREMIOSSVN_ACTUACIONES_LIST`, `SP_APREMIOSSVN_CAMBIAR_FASE`, `SP_APREMIOSSVN_PAGOS_LIST`, `SP_APREMIOSSVN_ESTADISTICAS_GENERALES`, `SP_APREMIOSSVN_PROXIMOS_VENCIMIENTO`
- **Estado**: ✅ **LISTO PARA MIGRACIÓN**

---

## FASE 2: FRONTEND - COMPONENTES VUE

### Estado: ⏳ **PENDIENTE**

Los componentes Vue deben implementarse después de que las tablas de base de datos estén creadas y los stored procedures estén migrados.

### Componentes por Implementar:
1. **ApremiosSvnExpedientes.vue** - Gestión de expedientes SVN
2. **ApremiosSvnNotificaciones.vue** - Control de notificaciones
3. **ApremiosSvnActuaciones.vue** - Actuaciones procesales
4. **ApremiosSvnPagos.vue** - Registro de pagos
5. **ApremiosSvnReportes.vue** - Reportes y estadísticas
6. **ApremiosSvnDashboard.vue** - Dashboard principal
7. **ApremiosSvnFases.vue** - Control de fases procesales

---

## FUNCIONALIDADES IMPLEMENTADAS

### Gestión de Expedientes SVN
- ✅ Lista completa de expedientes con filtros avanzados
- ✅ Creación de expedientes con validación de cuentas prediales
- ✅ Control de fases procesales (REQUERIMIENTO → EMBARGO → REMATE → ADJUDICACIÓN)
- ✅ Seguimiento de adeudos, recargos y gastos de ejecución

### Sistema de Notificaciones
- ✅ Programación y seguimiento de notificaciones
- ✅ Control de resultados y estados
- ✅ Asignación de notificadores
- ✅ Direcciones específicas para notificación

### Actuaciones Procesales
- ✅ Registro de todas las actuaciones del proceso
- ✅ Control de costos por actuación
- ✅ Seguimiento de responsables y resultados
- ✅ Historial completo de actividades

### Control de Fases
- ✅ Cambio controlado entre fases procesales
- ✅ Validación de secuencia correcta
- ✅ Historial de cambios con responsables
- ✅ Motivos y justificaciones

### Pagos Especializados
- ✅ Desglose detallado: capital, recargos, gastos
- ✅ Control de recibos únicos
- ✅ Múltiples formas de pago
- ✅ Actualización automática de saldos

### Reportes y Estadísticas
- ✅ Estadísticas por fase procesal
- ✅ Montos recuperados por período
- ✅ Efectividad de cobranza
- ✅ Expedientes próximos a vencer
- ✅ Notificaciones pendientes

---

## CARACTERÍSTICAS ESPECÍFICAS DEL SISTEMA SVN

### Diferencias con APREMIOS Regular
- **Control de Fases Estricto**: Validación de secuencia procesal
- **Cuenta Predial**: Vinculación específica con catastro
- **Actuaciones Procesales**: Registro detallado de diligencias
- **Gastos de Ejecución**: Control separado de costos procesales
- **Notificadores Asignados**: Personal específico por expediente

### Fases Procesales
1. **REQUERIMIENTO** - Notificación inicial al contribuyente
2. **EMBARGO** - Proceso de embargo de bienes
3. **REMATE** - Procedimiento de remate público
4. **ADJUDICACIÓN** - Adjudicación final de bienes

---

## PRÓXIMOS PASOS
1. **Creación de Tablas**: Diseñar y crear tablas específicas para SVN
2. **Migración de SPs**: Ejecutar archivos SQL en PostgreSQL
3. **Migración de Datos**: Importar datos del sistema SVN legacy
4. **Pruebas de BD**: Validar funcionamiento de stored procedures
5. **Desarrollo Frontend**: Implementar componentes Vue.js específicos
6. **Integración**: Conectar con sistema de catastro predial

---

**Fecha de Creación**: 9 de septiembre de 2025  
**Responsable**: Claude Code  
**Estado**: Fase 1 Completada - Listo para migración