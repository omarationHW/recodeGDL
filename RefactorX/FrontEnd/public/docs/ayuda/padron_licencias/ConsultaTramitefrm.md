# Consulta y Seguimiento de Trámites

## Descripción General

### ¿Qué hace este módulo?
Este módulo es el **centro de consulta y seguimiento de todos los trámites** de licencias y anuncios. Permite buscar, consultar, reportear y exportar información detallada de trámites usando múltiples criterios de búsqueda. Es una herramienta fundamental para dar seguimiento al estatus de solicitudes en proceso.

### ¿Para qué sirve en el proceso administrativo?
- Consultar estatus actual de cualquier trámite
- Dar seguimiento a solicitudes en proceso de revisión
- Generar reportes para diferentes áreas (dependencias)
- Identificar trámites atrasados o pendientes
- Exportar información para análisis externos
- Atender consultas de ciudadanos sobre sus trámites
- Monitorear tiempos de atención por dependencia
- Generar estadísticas de trámites procesados

### ¿Quiénes lo utilizan?
- **Personal de ventanilla**: Para informar estatus a contribuyentes
- **Supervisores**: Para monitorear avance de trámites
- **Dependencias**: Para consultar expedientes enviados a revisión
- **Dirección**: Para estadísticas y control de tiempos
- **Auditoría**: Para verificar proceso y cumplimiento de plazos
- **Contribuyentes** (indirectamente): Reciben información sobre sus trámites

## Proceso Administrativo

### Criterios de Búsqueda Disponibles

**1. Por Número de Trámite** (TabSheet1)
- Captura directa del número de folio del trámite
- Búsqueda más rápida y precisa

**2. Por Fecha** (TabSheet2)
- Búsqueda por rango de fechas de captura
- Útil para reportes periódicos

**3. Por Ubicación** (TabSheet3)
- Búsqueda por calle y número del inmueble
- Para localizar trámites por domicilio

**4. Por Contribuyente** (TabSheet4)
- Búsqueda por nombre del propietario o solicitante

**5. Por Cuenta Catastral** (TabSheet5)
- Búsqueda por clave catastral o cuenta predial

**6. Por Clave Catastral** (TabSheet6)
- Búsqueda por clave nueva de catastro

**7. Por Estatus** (TabSheet7)
- Filtro por estado del trámite (pendiente, dictaminado, etc.)

**8. Por Dependencia** (TabSheet8)
- Filtra trámites enviados a una dependencia específica
- Con o sin respuesta

**9. Por Dependencia con Días** (TabSheet9)
- Trámites en dependencia con filtro de antigüedad (días)

**10. Por Rango de Fechas de Oficios** (TabSheet10)
- Trámites según fecha de envío de oficios

**11. Por Tipo de Trámite** (TabSheet11)
- Filtra por tipo de licencia solicitada

**12. Por Tipo y Estatus Combinados** (TabSheet12)
- Filtro avanzado combinando tipo, estatus, fecha, dependencia

**13. Por Apoderado** (TabSheet13)
- Búsqueda por nombre del representante legal

**14. Por Grupo de Trámites** (TabSheet14)
- Búsqueda por agrupación administrativa predefinida

**15. Por Imágenes Cargadas** (TabSheetImg)
- Trámites que tienen imágenes/documentos digitalizados

### ¿Qué información muestra?

**Datos Principales del Trámite:**
- Número de folio
- Tipo de trámite (licencia nueva, renovación, cambio de propietario, etc.)
- Fecha de captura
- Propietario/solicitante (nombre completo con apellidos)
- RFC y CURP
- Actividad comercial
- Giro solicitado

**Datos del Inmueble:**
- Domicilio del propietario
- Ubicación del negocio
- Colonia, CP
- Zona y subzona
- Cruces de calles
- Coordenadas (X,Y)

**Datos Técnicos:**
- Superficie construida y autorizada
- Número de empleados
- Cajones de estacionamiento
- Aforo
- Inversión estimada
- Horario propuesto

**Estatus y Seguimiento:**
- Estatus actual del trámite
- Dependencias que han revisado
- Fechas de envío y respuesta de cada dependencia
- Observaciones de cada revisión
- Bloqueado (sí/no)
- Dictamen (aprobado/rechazado/pendiente)

### ¿Qué documentos genera?

**1. Reporte Detallado de Trámite Individual** (ppReport1)
- Información completa del trámite
- Incluye todas las características técnicas
- Muestra observaciones
- Formato oficial para expediente

**2. Listado de Trámites** (ppReport2)
- Reporte resumido de múltiples trámites
- Columnas: Folio, Fecha, Propietario, Ubicación, Giro, Estatus
- Incluye contador de registros
- Útil para reportes gerenciales

**3. Reporte Compacto** (ppReport3)
- Versión reducida con información esencial
- Para reportes internos rápidos

**4. Archivo Excel/CSV**
- Exportación completa del grid
- Todas las columnas visibles
- Útil para análisis en herramientas externas

## Tablas de Base de Datos

### Tabla Principal
**tramites** - Contiene todos los registros de solicitudes de trámites

### Tablas Relacionadas que Consulta
1. **c_giros** - Catálogo de giros comerciales
2. **revisiones** - Histórico de revisiones por dependencias
3. **seg_revision** - Detalle de cada revisión (oficios, fechas, observaciones)
4. **dependenciastbl/dependencias** - Catálogo de dependencias (Reglamentos, Protección Civil, Ecología, etc.)
5. **usr** - Usuarios del sistema (capturistas, revisores)
6. **TipoLicencia** - Catálogo de tipos de trámites
7. **tramites_grupos** - Grupos de trámites
8. **tramites_detgrupo** - Detalle de trámites por grupo
9. **Imagenes** - Registro de documentos digitalizados asociados al trámite
10. **QryCruceCalles** - Calles de cruce para ubicación

### Tablas que Modifica
**NINGUNA** - Este módulo es de solo consulta. No modifica registros.

## Stored Procedures
No utiliza stored procedures. Toda la lógica es mediante queries SQL directas.

## Impacto y Repercusiones

### ¿Qué registros afecta?
**NINGUNO** - Módulo de solo lectura. No modifica datos.

### ¿Qué cambios de estado provoca?
**NINGUNO** - Solo consulta información existente.

### ¿Qué documentos/reportes genera?
1. **Reportes impresos** - Documentos oficiales del trámite
2. **Listados** - Reportes resumidos de múltiples trámites
3. **Exportaciones Excel** - Para análisis externos
4. **Reportes de imagen** - Si tiene documentos digitalizados

### ¿Qué validaciones de negocio aplica?
1. Valida que existan registros antes de imprimir
2. Valida formato de fechas en búsquedas
3. Valida que se seleccione un criterio de búsqueda
4. Valida coherencia de rangos de fechas

## Flujo de Trabajo

### Flujo de Consulta por Folio
```
1. Usuario selecciona TabSheet1
2. Captura número de trámite
3. Presiona botón "Buscar"
4. Sistema ejecuta query con WHERE folio=X
5. Muestra resultado en grid
6. Usuario puede imprimir o exportar
```

### Flujo de Consulta por Dependencia
```
1. Usuario selecciona TabSheet8 o TabSheet9
2. Selecciona dependencia del combobox
3. Si aplica, captura rango de fechas
4. Sistema filtra trámites enviados a esa dependencia
5. Muestra: folio, fecha envío, fecha respuesta, estatus
6. Permite generar reporte de trámites pendientes
```

### Flujo de Exportación
```
1. Usuario genera consulta con cualquier criterio
2. Grid se llena con resultados
3. Click en botón "Exportar a Excel"
4. Sistema abre diálogo para guardar archivo
5. Exporta datos con formato
6. Archivo queda disponible para análisis externo
```

## Notas Importantes

### Consideraciones Especiales

**1. Módulo de Solo Consulta**
- No permite crear, modificar o eliminar trámites
- Es seguro para uso de personal de ventanilla
- No afecta integridad de datos

**2. Múltiples Criterios de Búsqueda**
- 15 diferentes formas de buscar trámites
- Cada criterio optimizado para un caso de uso específico
- Permite encontrar información rápidamente

**3. Integración con Revisiones**
- Muestra el histórico completo de revisiones
- Cada dependencia que ha intervenido
- Fechas y observaciones de cada revisión

**4. Exportación Flexible**
- Permite compartir información con otras áreas
- Útil para presentaciones y análisis estadísticos

**5. Imágenes Asociadas**
- Identifica trámites con documentación digitalizada
- Útil para verificar expediente completo

### Restricciones
- No permite modificar trámites
- Solo consulta y reporte
- Permisos de solo lectura suficientes

### Permisos Necesarios
- Usuario válido del sistema
- Permiso de lectura en tablas de trámites
- Para exportar: permiso de exportación
- Para imprimir: acceso a impresora configurada

### Uso Recomendado
- Para atención a contribuyentes sobre estatus
- Para seguimiento interno de proceso
- Para generar reportes periódicos a dirección
- Para identificar trámites atrasados
- Para estadísticas de desempeño por dependencia
