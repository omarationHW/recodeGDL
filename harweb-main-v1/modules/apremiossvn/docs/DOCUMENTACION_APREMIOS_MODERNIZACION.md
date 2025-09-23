# Documentación - Modernización del Módulo de Apremios

## Resumen Ejecutivo

El presente documento detalla las nuevas funcionalidades requeridas para la modernización del módulo de apremios, conforme a las especificaciones del área encargada. Este módulo no requiere exclusión de funcionalidades obsoletas.

## Estado Actual del Sistema de Apremios

### Funcionalidades Implementadas y Operativas

El sistema actual cuenta con múltiples componentes funcionales desarrollados que incluyen gestión básica de procedimientos administrativos, control de embargos y administración de notificaciones.

## Funciones a Excluir del Sistema Actual

**N/A** - No se requiere excluir ninguna funcionalidad del sistema actual.

## Nuevas Funcionalidades Requeridas

### Sistema Integral de Convenios para Apremios

La administración de convenios requiere un sistema completo que incluya:

#### 1. ABC del Catálogo de Intereses
- **Descripción**: Gestión completa de tasas de interés aplicables a procedimientos de apremio
- **Funcionalidad**:
  - Altas, Bajas y Cambios de tipos de interés
  - Configuración de tasas por tipo de procedimiento
  - Vigencias y actualizaciones automáticas
- **Beneficio**: Control preciso de intereses según normativa fiscal vigente

#### 2. ABC del Convenio
- **Descripción**: Administración integral de convenios de pago para procedimientos de apremio
- **Funcionalidad**:
  - Datos generales del convenio
  - Importes a generar para parcialidades
  - Generación automática de parcialidades
- **Beneficio**: Gestión eficiente de acuerdos de pago en procedimientos coactivos

#### 3. Desglose de Parcialidades
- **Descripción**: Administración detallada de parcialidades con rubros específicos
- **Funcionalidad**:
  - Desglose completo de parcialidades
  - Rubros correspondientes para cobro en caja
  - Seguimiento de vencimientos
- **Beneficio**: Control granular de pagos parciales

#### 4. ABC de Pagos
- **Descripción**: Gestión integral de pagos realizados en convenios
- **Funcionalidad**:
  - Registro de pagos efectuados
  - Aplicación automática a parcialidades
  - Control de saldos pendientes
- **Beneficio**: Seguimiento preciso de cumplimiento de convenios

#### 5. Impresión del Convenio
- **Descripción**: Generación de documentos oficiales del convenio
- **Funcionalidad**:
  - Impresión del convenio mediante oficio
  - Generación del pagaré correspondiente
  - Formatos oficiales requeridos
- **Beneficio**: Documentación legal completa

#### 6. Consulta General del Convenio
- **Descripción**: Sistema de consulta integral de convenios
- **Funcionalidad**:
  - Datos generales del convenio
  - Historial de pagos realizados
  - Adeudos pendientes
- **Beneficio**: Vista completa del estado de convenios

#### 7. Reportes del Padrón de Convenios
- **Descripción**: Sistema de reportes especializados
- **Funcionalidad**:
  - Padrón completo de convenios
  - Reportes de adeudos y pagos
  - Exportación a Excel
- **Beneficio**: Análisis y seguimiento masivo de convenios

#### 8. Cancelación Masiva de Convenios
- **Descripción**: Herramienta de cancelación automática
- **Funcionalidad**:
  - Criterios configurables por usuario
  - Cancelación de convenios con dos o más parcialidades vencidas
  - Procesamiento masivo
- **Beneficio**: Gestión eficiente de convenios incumplidos

### Sistema Integral de Apremios

La administración de apremios requiere un sistema especializado que incluya:

#### 1. ABC del Catálogo de Ejecutores
- **Descripción**: Gestión completa del personal ejecutor
- **Funcionalidad**:
  - Altas, Bajas y Cambios de ejecutores
  - Asignación de zonas y competencias
  - Control de capacitación y certificaciones
- **Beneficio**: Administración profesional del personal ejecutor

#### 2. Generación de Folios de Notificación
- **Descripción**: Sistema automatizado de generación de folios
- **Funcionalidad**:
  - Generación basada en criterios determinados
  - Folios de notificación y requerimientos
  - Numeración automática y consecutiva
- **Beneficio**: Control sistemático de notificaciones

#### 3. Impresión de Folios
- **Descripción**: Generación de documentos oficiales de notificación
- **Funcionalidad**:
  - Impresión con fundamentos legales
  - Formato requerido por Dirección de Política Fiscal y Mejora Hacendaria
  - Documentos legalmente válidos
- **Beneficio**: Cumplimiento de requisitos legales

#### 4. Modificación de Datos del Folio
- **Descripción**: Sistema de actualización de folios generados
- **Funcionalidad**:
  - Edición de datos específicos
  - Control de versiones
  - Historial de modificaciones
- **Beneficio**: Flexibilidad en gestión de documentos

#### 5. Consulta del Folio
- **Descripción**: Sistema de consulta integral de folios
- **Funcionalidad**:
  - Búsqueda por múltiples criterios
  - Estado actual del procedimiento
  - Historial completo
- **Beneficio**: Seguimiento preciso de procedimientos

#### 6. Gestión Masiva de Folios
- **Descripción**: Herramientas de procesamiento masivo
- **Funcionalidad**:
  - Asignación masiva de folios
  - Cancelación masiva por criterios
  - Practicar folios masivamente
- **Beneficio**: Eficiencia en gestión de volúmenes altos

#### 7. Reportes Especializados
- **Descripción**: Sistema de reportes para apremios
- **Funcionalidad**:
  - Catálogo de ejecutores
  - Listado de descuentos aplicados
  - Nómina para pago de ejecutores
  - Estado de folios por ejecutor
- **Beneficio**: Control administrativo y de pagos

### Sistema de Descuentos

#### Descuentos de Recargos y Multas
- **Descripción**: Sistema automatizado de aplicación de descuentos
- **Funcionalidad**:
  - Configuración de porcentajes de descuento
  - Aplicación automática según criterios
  - Control de autorizaciones
- **Beneficio**: Gestión eficiente de beneficios fiscales

### Sistema de Conversión de Procedimientos

#### Conversión y Revaluación
- **Descripción**: Sistema de conversión de procedimientos de pago
- **Funcionalidad**:
  - Conversión de procedimientos de pago en caja
  - Cálculo automático para revaluación de costos
  - Actualización de valores según índices
- **Beneficio**: Actualización automática de valores fiscales

## Beneficios de la Modernización

### Eficiencia Operativa
- Automatización de procesos manuales
- Reducción de errores en cálculos
- Agilización de procedimientos administrativos

### Control Fiscal
- Seguimiento preciso de convenios y apremios
- Reportes especializados para toma de decisiones
- Cumplimiento de normativa fiscal

### Atención Ciudadana
- Consultas en línea de procedimientos
- Impresión de documentos oficiales
- Facilidades de pago estructuradas

## Componentes Técnicos Implementados

### 1. SistemaConveniosApremios.vue
- Gestión completa de convenios de pago
- 8 pestañas especializadas
- Interfaz moderna y funcional

### 2. SistemaApremiosApremios.vue
- Administración integral de procedimientos de apremio
- 7 pestañas de gestión
- Herramientas de procesamiento masivo

### 3. SistemaDescuentosConversion.vue
- Sistema unificado de descuentos y conversión
- 3 sistemas integrados en uno
- Automatización de cálculos

## Evidencia Visual para Cliente

- ✅ **3 Nuevos Componentes** implementados y funcionales
- ✅ **Badges "NUEVO"** en navegación para destacar funcionalidades
- ✅ **Documentación completa** de requerimientos
- ✅ **Interfaces modernas** con Vue.js 3
- ✅ **Integración completa** con sistema existente

## Conclusión

La modernización del módulo de apremios proporciona las herramientas necesarias para una gestión eficiente y profesional de procedimientos administrativos, convenios de pago y sistemas de descuentos, cumpliendo con los más altos estándares de la administración pública moderna.