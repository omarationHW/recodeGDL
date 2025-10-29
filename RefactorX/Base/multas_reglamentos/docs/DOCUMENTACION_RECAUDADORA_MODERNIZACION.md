# Documentación - Modernización del Módulo de Recaudadora

## Resumen Ejecutivo

El presente documento detalla los módulos excluidos del sistema actual de recaudadora y las nuevas funcionalidades requeridas para la modernización del sistema, conforme a las especificaciones del área encargada.

## Estado Actual del Sistema de Recaudadora

### Funcionalidades Implementadas y Operativas

El sistema actual cuenta con múltiples componentes funcionales desarrollados que incluyen gestión básica de recaudación, consultas y administración de pagos y contribuyentes.

## Funciones a Excluir del Sistema Actual

Los siguientes módulos no se requieren y se excluyen debido a que el área responsable indica que su funcionalidad se encuentra **obsoleta** y requiere modernización e implementación de funciones más óptimas:

### Lista de Funciones Obsoletas a Remover

1. **Captura y consulta** - Sistema de captura manual obsoleto
2. **Captura de pagos en centros de recaudación** - Proceso manual descontinuado
3. **Consulta de AS400** - Sistema legacy que será reemplazado
4. **Seguimiento de multas** - Funcionalidad integrada en nuevo sistema
5. **Consulta de requerimientos del AS400** - Interfaz obsoleta del sistema anterior

## Nuevas Funcionalidades Requeridas

### Sistema Integral de Convenios para Recaudadora

La administración de convenios requiere un sistema completo que incluya:

#### 1. ABC del Catálogo de Intereses
- **Descripción**: Gestión completa de tasas de interés aplicables
- **Funcionalidad**:
  - Altas, Bajas y Cambios de tipos de interés
  - Configuración de tasas por tipo de contribuyente
  - Vigencias y actualizaciones automáticas
- **Beneficio**: Control preciso de intereses según normativa vigente

#### 2. ABC del Convenio
- **Descripción**: Administración integral de convenios de pago
- **Funcionalidad**:
  - Datos generales del convenio
  - Importes a generar para parcialidades
  - Generación automática de parcialidades
- **Beneficio**: Gestión eficiente de acuerdos de pago

#### 3. Desglose de Parcialidades
- **Descripción**: Administración detallada de parcialidades
- **Funcionalidad**:
  - Desglose con rubros correspondientes
  - Preparación para cobro en caja
  - Seguimiento de vencimientos
- **Beneficio**: Control granular de parcialidades

#### 4. ABC de Pagos
- **Descripción**: Gestión completa de pagos realizados
- **Funcionalidad**:
  - Registro de pagos
  - Aplicación a convenios
  - Conciliación automática
- **Beneficio**: Seguimiento preciso de pagos

#### 5. Impresión del Convenio
- **Descripción**: Generación de documentos oficiales
- **Funcionalidad**:
  - Oficio del convenio
  - Pagaré correspondiente
  - Formato legal requerido
- **Beneficio**: Documentación legal completa

#### 6. Consulta General del Convenio
- **Descripción**: Vista integral del estado del convenio
- **Funcionalidad**:
  - Datos generales
  - Historial de pagos
  - Adeudos pendientes
- **Beneficio**: Información completa en tiempo real

#### 7. Reportes Integrales
- **Descripción**: Sistema de reportes avanzados
- **Funcionalidad**:
  - Padrón de convenios
  - Reportes de adeudos
  - Reportes de pagos
  - Exportación a Excel
- **Beneficio**: Análisis y seguimiento detallado

#### 8. Cancelación Masiva
- **Descripción**: Herramienta de gestión masiva
- **Funcionalidad**:
  - Cancelación de convenios vencidos
  - Criterios configurables (2+ parcialidades vencidas)
  - Proceso masivo controlado
- **Beneficio**: Gestión eficiente de convenios incumplidos

### Sistema Integral de Apremios

La administración de apremios requiere un sistema especializado que incluya:

#### 1. ABC del Catálogo de Ejecutores
- **Descripción**: Gestión del personal ejecutor
- **Funcionalidad**:
  - Altas, Bajas y Cambios de ejecutores
  - Asignación de zonas/territorios
  - Control de cargas de trabajo
- **Beneficio**: Gestión organizada del personal

#### 2. Generación de Folios
- **Descripción**: Sistema automatizado de folios
- **Funcionalidad**:
  - Generación basada en criterios
  - Folios de notificación
  - Folios de requerimientos
- **Beneficio**: Proceso automatizado y controlado

#### 3. Impresión Especializada
- **Descripción**: Documentos con formato legal
- **Funcionalidad**:
  - Fundamentos legales incluidos
  - Formato de Dirección de Política Fiscal
  - Formato de Mejora Hacendaria
- **Beneficio**: Cumplimiento normativo

#### 4. Modificación de Folios
- **Descripción**: Gestión post-generación
- **Funcionalidad**:
  - Modificación de datos del folio
  - Control de cambios
  - Historial de modificaciones
- **Beneficio**: Flexibilidad operativa

#### 5. Consulta de Folios
- **Descripción**: Sistema de consultas avanzadas
- **Funcionalidad**:
  - Búsqueda por múltiples criterios
  - Estado del folio
  - Historial completo
- **Beneficio**: Acceso rápido a información

#### 6. Gestión Masiva de Folios
- **Descripción**: Operaciones masivas controladas
- **Funcionalidad**:
  - Asignación masiva
  - Cancelación masiva
  - Practicar folios masivamente
- **Beneficio**: Eficiencia operativa

#### 7. Reportes de Apremios
- **Descripción**: Sistema de reportes especializados
- **Funcionalidad**:
  - Catálogo de ejecutores
  - Listado de descuentos
  - Nómina para pago al ejecutor
  - Estado de folios asignados
  - Criterios de selección flexibles
- **Beneficio**: Control y seguimiento completo

### Conversión de Procedimientos de Pago

#### Modernización del Sistema de Pagos en Caja
- **Descripción**: Actualización de procesos de pago
- **Funcionalidad**:
  - Integración con sistemas modernos
  - Automatización de procesos
  - Interfaces mejoradas
- **Beneficio**: Procesos más eficientes y seguros

## Plan de Implementación

### Fase 1: Preparación (2 semanas)
- Análisis detallado de sistemas actuales
- Backup completo de datos existentes
- Identificación de dependencias
- Capacitación inicial al equipo

### Fase 2: Desarrollo (6 semanas)
- Desarrollo del Sistema de Convenios
- Desarrollo del Sistema de Apremios
- Conversión de procedimientos de pago
- Pruebas unitarias e integración

### Fase 3: Migración (2 semanas)
- Migración de datos existentes
- Pruebas de funcionalidad completa
- Capacitación a usuarios finales
- Documentación de procesos

### Fase 4: Puesta en Producción (1 semana)
- Despliegue en ambiente productivo
- Monitoreo de funcionalidad
- Soporte especializado
- Ajustes finales

## Beneficios Esperados

### Operacionales
- **Automatización**: Reducción del 70% en procesos manuales
- **Eficiencia**: Mejora del 60% en tiempos de respuesta
- **Precisión**: Eliminación del 90% de errores humanos
- **Integración**: Sistema unificado de gestión

### Técnicos
- **Modernización**: Eliminación de dependencias legacy
- **Escalabilidad**: Arquitectura preparada para crecimiento
- **Mantenimiento**: Código modular y documentado
- **Seguridad**: Estándares actuales de seguridad

### Administrativos
- **Control**: Seguimiento detallado de procesos
- **Reportes**: Información en tiempo real
- **Cumplimiento**: Apego a normativas vigentes
- **Transparencia**: Trazabilidad completa de operaciones

## Cronograma de Entrega

| Fase | Duración | Entregables |
|------|----------|-------------|
| Preparación | 2 semanas | Análisis, Backup, Documentación inicial |
| Desarrollo | 6 semanas | Sistemas funcionales, Pruebas |
| Migración | 2 semanas | Datos migrados, Capacitación |
| Producción | 1 semana | Sistema en vivo, Soporte |

**Tiempo total estimado: 11 semanas**

## Recursos Requeridos

### Técnicos
- 1 Arquitecto de Software Senior
- 2 Desarrolladores Full-Stack
- 1 Especialista en Base de Datos
- 1 Especialista en Frontend

### Operacionales
- 1 Coordinador de Proyecto
- 1 Analista de Procesos
- 1 Especialista en Capacitación
- Usuarios clave del área

## Consideraciones Técnicas

### Tecnologías a Utilizar
- **Frontend**: Vue.js 3 (Composition API)
- **Backend**: Laravel 10+ con PHP 8+
- **Base de Datos**: PostgreSQL 14+
- **Documentos**: PDF generation con DomPDF
- **Reportes**: Excel export con PhpSpreadsheet

### Integraciones Requeridas
- Sistema de pagos existente
- Base de datos de contribuyentes
- Sistema de notificaciones
- Generación de documentos oficiales

---

**Documento generado el:** {{ new Date().toLocaleDateString('es-MX') }}
**Responsable técnico:** Equipo de Desarrollo RefactorX
**Área solicitante:** Recaudadora Municipal