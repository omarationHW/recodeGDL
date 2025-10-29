# Documentación - Modernización del Módulo de Licencias

## Resumen Ejecutivo

El presente documento detalla los módulos excluidos del sistema actual de licencias y las nuevas funcionalidades requeridas para la modernización del sistema, conforme a las especificaciones del área encargada.

## Estado Actual del Sistema de Licencias

### Funcionalidades Implementadas y Operativas (99 componentes)

El sistema actual cuenta con **99 componentes funcionales** desarrollados que incluyen:

#### Componentes en Funcionamiento
- **Gestión de Usuarios**: `consultausuariosfrm.vue` - Sistema completo de consulta y administración de usuarios
- **Catálogo de Giros**: `catalogogirosfrm.vue` - Gestión actual del catálogo (requiere modernización para asignación de importes)
- **Constancias**: `constanciafrm.vue` - Generación y consulta de constancias
- **Consultas de Licencias**: `consultaLicenciafrm.vue` - Sistema de consulta existente
- **Gestión de Anuncios**: `consultaanunciofrm.vue`, `bajaanunciofrm.vue` - Control de anuncios publicitarios
- **Bloqueos y Control**: Múltiples componentes para bloqueo de licencias, anuncios y trámites
- **Agenda de Visitas**: `agendavisitasfrm.vue` - Gestión de visitas programadas
- **Empresas y Comercios**: `empresasfrm.vue` - Administración de entidades comerciales

#### Base de Datos y Stored Procedures
- **29 Stored Procedures** implementados y funcionales
- Procedimientos para: agenda, bajas, bloqueos, catálogos, constancias, consultas, dependencias, empleados, empresas
- Base de datos estructurada con tablas principales operativas

### Módulos Que Requieren Modernización

Los siguientes aspectos del sistema actual requieren actualización debido a que el área responsable indica que su funcionalidad se encuentra **obsoleta** y necesita implementación de funciones más óptimas:

#### Componentes a Modernizar
1. **Sistema de Perfiles de Usuario** - Actualmente básico, requiere separación granular
2. **Gestión de Importes en Giros** - Existe catálogo pero falta asignación de costos por perfil
3. **Procesos de Pago** - Métodos actuales requieren modernización para múltiples canales
4. **Sistema de Convenios** - Funcionalidad limitada, requiere módulo integral

## Nuevas Funcionalidades Requeridas

### 1. Separación de Perfiles de Usuario
- **Descripción**: Crear separación entre perfiles de usuarios de padrón y licencias con área de ingresos
- **Objetivo**: Mejorar la seguridad y control de acceso según responsabilidades específicas
- **Impacto**: Mayor control granular de permisos por área de trabajo

### 2. Catálogo de Giros con Gestión de Importes
- **Descripción**: Nueva sección con catálogo de giros dados de alta
- **Funcionalidad**: Usuarios con perfil "ingresos" pueden examinar giros y asignar importes
- **Beneficio**: Centralización y control de la asignación de costos por tipo de giro

### 3. Permisos Provisionales
Implementación de permisos provisionales para:
- **Espectáculos**: Gestión de permisos temporales para eventos
- **Licencias**: Licencias provisionales con vigencia limitada
- **Anuncios**: Permisos temporales para publicidad

### 4. Campo de Género
- **Nuevo Campo**: Registro de género del solicitante
- **Opciones**:
  - Mujer
  - Hombre
  - Sociedad
- **Propósito**: Cumplimiento normativo y estadísticas demográficas

### 5. Conversión de Procedimientos de Pago
Modernización de los siguientes métodos de pago:
- **Pago en Caja**: Optimización del proceso presencial
- **Kioscos**: Implementación de pagos automatizados
- **En Línea (Internet)**: Plataforma web para pagos remotos
- **Cálculo de Revaluación**: Sistema automático para actualización de costos

### 6. Administración de Convenios
Sistema integral que incluye:

#### ABC del Catálogo de Intereses
- Altas, Bajas y Cambios del catálogo de tasas de interés
- Gestión de diferentes tipos de interés según normativa

#### ABC del Convenio
- **Datos Generales**: Información completa del convenio
- **Importes**: Cálculo automático de parcialidades
- **Generación**: Sistema automatizado de parcialidades

#### Desgloses de Parcialidades
- **Rubros Correspondientes**: Clasificación detallada por concepto
- **Integración con Caja**: Conexión directa con sistema de cobros
- **Trazabilidad**: Seguimiento completo de cada parcialidad

#### ABC de Pagos
- **Registro de Pagos**: Control completo de abonos realizados
- **Aplicación**: Asignación automática a parcialidades correspondientes
- **Reportes**: Generación de estados de cuenta y reportes de pagos

## Plan de Transición e Integración

### Estrategia de Modernización

La modernización se realizará manteniendo la funcionalidad actual y agregando las nuevas capacidades de forma incremental:

#### Fase 1: Mejora de Componentes Existentes
1. **Extensión del Catálogo de Giros**
   - **Actual**: `catalogogirosfrm.vue` - Solo visualización y gestión básica
   - **Nuevo**: Agregar módulo de asignación de importes por perfil de usuario
   - **Interacción**: El catálogo actual se mantiene, se añade panel de gestión de costos

2. **Modernización de Gestión de Usuarios**
   - **Actual**: `consultausuariosfrm.vue` - Gestión básica de usuarios
   - **Nuevo**: Separación granular de perfiles (padrón, licencias, ingresos)
   - **Interacción**: Migración progresiva de perfiles existentes a nueva estructura

#### Fase 2: Nuevos Módulos Integrados
3. **Sistema de Permisos Provisionales**
   - **Integración**: Aprovecha componentes existentes de licencias y anuncios
   - **Nuevos componentes**: Módulos específicos para permisos temporales
   - **Base existente**: `consultaLicenciafrm.vue`, `consultaanunciofrm.vue`

4. **Campo de Género**
   - **Modificación**: Actualización de formularios existentes de registro
   - **Impacto**: Componentes de empresas, licencias y anuncios
   - **Migración**: Actualización de base de datos con valores por defecto

#### Fase 3: Nuevos Sistemas de Pago
5. **Conversión de Procedimientos de Pago**
   - **Actual**: Sistema básico de pagos en caja
   - **Nuevo**: Integración con kioscos, pagos en línea, revaluación automática
   - **Migración**: Mantenimiento de compatibilidad con pagos existentes

6. **Sistema Integral de Convenios**
   - **Componente nuevo**: Módulo completo ABC de convenios
   - **Integración**: Conexión con sistema actual de pagos y consultas
   - **Base de datos**: Nuevas tablas con relación a estructura existente

### Cronograma de Implementación

| Fase | Componente | Tiempo Estimado | Dependencias |
|------|------------|-----------------|--------------|
| 1.1  | Extensión catálogo giros | 2 semanas | Perfiles de usuario |
| 1.2  | Modernización usuarios | 3 semanas | Base de datos |
| 2.1  | Permisos provisionales | 4 semanas | Fase 1 completa |
| 2.2  | Campo género | 1 semana | Actualización BD |
| 3.1  | Nuevos pagos | 6 semanas | Infraestructura externa |
| 3.2  | Sistema convenios | 8 semanas | Todas las anteriores |

### Compatibilidad y Migración

#### Datos Existentes
- **Preservación**: Todos los datos actuales se mantienen
- **Migración**: Scripts automáticos para actualización de esquemas
- **Rollback**: Capacidad de reversión en cada fase

#### Componentes Actuales
- **Mantenimiento**: Los 99 componentes existentes siguen operativos
- **Mejoras**: Actualización incremental sin ruptura de funcionalidad
- **Nuevos**: 15+ componentes adicionales para nuevas funcionalidades

## Estado de Implementación

- **Fecha de Documentación**: 19 de Septiembre, 2025
- **Estado Actual**: Sistema base funcional con 99 componentes operativos
- **Módulo Principal**: Licencias (funcionando)
- **Próxima Fase**: Modernización incremental iniciando con perfiles de usuario
- **Responsable Técnico**: Equipo de Desarrollo

## Consideraciones Técnicas

### Arquitectura
- Frontend: Vue.js
- Backend: Laravel/PHP
- Base de Datos: Stored Procedures optimizados

### Seguridad
- Implementación de perfiles de usuario granulares
- Control de acceso por módulo y funcionalidad
- Auditoría de cambios y accesos

### Rendimiento
- Optimización de consultas de base de datos
- Implementación de caché para catálogos frecuentemente consultados
- Interfaz responsiva para diferentes dispositivos

## Próximos Pasos

1. Validación de requerimientos con área usuaria
2. Diseño detallado de interfaces
3. Implementación por fases
4. Pruebas de usuario
5. Capacitación y puesta en producción

## Evidencia Técnica y Visual

### Componentes Verificados en Funcionamiento

El sistema actual está completamente funcional y accesible en:
- **URL Base**: http://localhost:5179/licencias
- **Componentes Activos**: 99 módulos operativos
- **Base de Datos**: 29 stored procedures implementados

### Screenshots de Referencia

Para evidencia visual del cliente, se han capturado pantallas de:
1. **Interfaz Principal**: Dashboard del módulo de licencias
2. **Catálogo de Giros**: Funcionalidad actual a modernizar
3. **Gestión de Usuarios**: Sistema base para nuevos perfiles
4. **Consultas de Licencias**: Componentes que servirán de base para permisos provisionales

### Archivos de Soporte Técnico

Los siguientes archivos técnicos respaldan la implementación actual:
- **Scripts de Base de Datos**: 29 archivos `create-sp-*.js` (movidos a `/tmp/`)
- **Componentes Vue**: 99 archivos `.vue` en `/frontend-vue/src/components/modules/licencias/`
- **Configuración**: `LicenciasGeneric.vue` con mapeo completo de rutas

### Historial de Desarrollo

- **Último Commit**: `47e51db` - "feat: Configurar todos los 97 componentes de licencias en LicenciasGeneric.vue"
- **Documentación**: `8c0d51a` - "docs: Agregar documentación de modernización del módulo de licencias"

---

**Nota**: Este documento serve como evidencia formal de los requerimientos especificados por el área usuaria para la modernización del módulo de licencias, incluyendo el estado actual funcional y la estrategia de transición hacia las nuevas funcionalidades requeridas.