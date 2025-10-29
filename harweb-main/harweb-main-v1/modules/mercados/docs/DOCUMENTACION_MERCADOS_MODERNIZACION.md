# Documentación - Modernización del Módulo de Mercados

## Resumen Ejecutivo

El presente documento detalla los módulos excluidos del sistema actual de mercados y las nuevas funcionalidades requeridas para la modernización del sistema, conforme a las especificaciones del área encargada.

## Estado Actual del Sistema de Mercados

### Funcionalidades Implementadas y Operativas

El sistema actual cuenta con múltiples componentes funcionales desarrollados que incluyen gestión básica de mercados, consultas y administración de comerciantes.

## Funciones a Excluir del Sistema Actual

Los siguientes módulos no se requieren y se excluyen debido a que el área responsable indica que su funcionalidad se encuentra **obsoleta** y requiere modernización e implementación de funciones más óptimas:

### Lista de Funciones Obsoletas a Remover

1. **Claves de diferencias** - Sistema de diferenciación obsoleto
2. **Autorizar fecha para carga de pagos** - Proceso manual innecesario
3. **Tianguis cultural** - Funcionalidad descontinuada
4. **Carga por mercado** - Método de carga obsoleto
5. **Carga pagos de diversos** - Sistema de pagos anticuado
6. **Carga individual** - Proceso individual ineficiente
7. **Salir del módulo** - Función de navegación obsoleta
8. **Paso pagos de mercados** - Transferencia manual obsoleta
9. **Paso pagos de energía** - Sistema de energía anticuado
10. **Paso adeudos** - Gestión de adeudos obsoleta

## Nuevas Funcionalidades Requeridas

### Sistema Integral de Convenios para Mercados

La administración de convenios requiere un sistema completo que incluya:

#### 1. ABC del Catálogo de Intereses
- **Descripción**: Gestión completa de tasas de interés aplicables
- **Funcionalidad**:
  - Altas, Bajas y Cambios de tipos de interés
  - Configuración de tasas por tipo de comercio
  - Vigencias y actualizaciones automáticas
- **Beneficio**: Control preciso de intereses según normativa vigente

#### 2. ABC del Convenio
- **Datos Generales**: Información completa del convenio de pago
- **Importes**: Cálculo automático para generar parcialidades
- **Funcionalidad**:
  - Registro de comerciantes y tipos de comercio
  - Definición de montos y plazos
  - Generación automática de calendarios de pago

#### 3. Desglose de Parcialidades
- **Descripción**: Sistema detallado de parcialidades con rubros específicos
- **Funcionalidad**:
  - Desglose por conceptos (renta, servicios, mantenimiento)
  - Rubros correspondientes para cobro en caja
  - Cálculo automático de intereses moratorios
  - Actualización de saldos en tiempo real

#### 4. ABC de Pagos
- **Registro de Pagos**: Control completo de abonos realizados
- **Aplicación**: Asignación automática a parcialidades correspondientes
- **Funcionalidad**:
  - Múltiples formas de pago (efectivo, transferencia, cheque)
  - Validación automática de importes
  - Generación de recibos oficiales

#### 5. Impresión del Convenio
- **Oficio del Convenio**: Documento oficial con términos y condiciones
- **Pagaré**: Documento legal de respaldo
- **Funcionalidad**:
  - Generación automática en formato PDF
  - Inclusión de datos del comerciante y términos
  - Firma digital o espacio para firma física
  - Logos y membrete oficial

#### 6. Consulta General del Convenio
- **Datos Generales**: Vista completa del convenio
- **Incluye**:
  - Información del comerciante
  - Detalles del convenio (monto, plazo, interés)
  - Historial completo de pagos realizados
  - Saldo actual y próximos vencimientos
  - Estado del convenio (vigente, vencido, liquidado)

#### 7. Reportes Integrales
- **Reporte del Padrón de Convenios**:
  - Lista completa de convenios activos
  - Filtros por fecha, estado, comerciante
  - Exportación a Excel y PDF

- **Reporte de Adeudos**:
  - Convenios con pagos vencidos
  - Montos de mora e intereses
  - Alertas de riesgo por días de atraso

- **Reporte de Pagos**:
  - Historial de pagos por período
  - Análisis de recaudación
  - Proyecciones de ingresos

- **Opciones Avanzadas**:
  - Personalización de filtros de fecha
  - Segmentación por tipo de comercio
  - Comparativos mensuales y anuales

## Plan de Transición e Integración

### Estrategia de Modernización

La modernización se realizará eliminando las funciones obsoletas y agregando el sistema integral de convenios:

#### Fase 1: Eliminación de Funciones Obsoletas
- **Tiempo Estimado**: 1 semana
- **Actividades**:
  - Identificación de componentes obsoletos
  - Backup de datos relevantes
  - Desactivación de funciones obsoletas
  - Actualización de navegación

#### Fase 2: Implementación de Sistema de Convenios
- **Tiempo Estimado**: 8 semanas
- **Actividades**:
  - Desarrollo del ABC de intereses (1 semana)
  - Implementación de ABC de convenios (2 semanas)
  - Sistema de parcialidades (2 semanas)
  - ABC de pagos (1 semana)
  - Sistema de impresión (1 semana)
  - Consultas y reportes (1 semana)

### Cronograma de Implementación

| Fase | Componente | Tiempo Estimado | Dependencias |
|------|------------|-----------------|--------------|
| 1.1  | Eliminación funciones obsoletas | 1 semana | Backup de datos |
| 2.1  | ABC Catálogo de Intereses | 1 semana | Base de datos |
| 2.2  | ABC de Convenios | 2 semanas | Catálogo intereses |
| 2.3  | Sistema de Parcialidades | 2 semanas | ABC convenios |
| 2.4  | ABC de Pagos | 1 semana | Sistema parcialidades |
| 2.5  | Sistema de Impresión | 1 semana | ABC convenios |
| 2.6  | Consultas y Reportes | 1 semana | Todos los anteriores |

## Estado de Implementación

- **Fecha de Documentación**: 19 de Septiembre, 2025
- **Estado Actual**: Planificación de modernización
- **Módulo Principal**: Mercados
- **Funciones a Remover**: 10 componentes obsoletos
- **Funciones a Agregar**: Sistema integral de convenios (7 componentes)
- **Responsable Técnico**: Equipo de Desarrollo

## Consideraciones Técnicas

### Arquitectura
- Frontend: Vue.js con componentes especializados
- Backend: Laravel/PHP con stored procedures optimizados
- Base de Datos: Nuevas tablas para convenios y relaciones

### Seguridad
- Control de acceso granular por tipo de usuario
- Auditoría completa de cambios en convenios
- Validación de pagos y generación segura de documentos

### Integración
- Compatibilidad con sistema actual de mercados
- Integración con módulo de recaudación
- Conexión con sistema de impresión oficial

## Próximos Pasos

1. Aprobación de requerimientos por área usuaria
2. Backup y análisis de datos existentes
3. Desarrollo incremental por fases
4. Pruebas integrales con usuarios
5. Capacitación y migración a producción

---

**Nota**: Este documento serve como evidencia de los requerimientos especificados por el área usuaria para la modernización del módulo de mercados, incluyendo tanto las funciones a eliminar como las nuevas funcionalidades integrales requeridas.