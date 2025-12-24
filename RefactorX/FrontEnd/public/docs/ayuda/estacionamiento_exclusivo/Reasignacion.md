# Reasignacion - Reasignación de Folios entre Ejecutores

## Propósito Administrativo
Permite transferir folios de apremio de un ejecutor a otro, facilitando la redistribución de carga de trabajo, cobertura de ausencias o reorganización de zonas de trabajo.

## Funcionalidad Principal
Módulo que reasigna folios de apremio entre ejecutores fiscales, actualiza el responsable del folio, registra la reasignación y mantiene trazabilidad del cambio.

## Proceso de Negocio

### ¿Qué hace?
- Reasigna folios de un ejecutor a otro
- Permite reasignación individual o masiva
- Actualiza ejecutor responsable del folio
- Registra fecha y usuario de la reasignación
- Mantiene historial de cambios
- Permite reasignación por diversos criterios (folio, rango, zona)

### ¿Para qué sirve?
- Redistribuir carga de trabajo entre ejecutores
- Cubrir ausencias de ejecutores (incapacidad, vacaciones)
- Reorganizar zonas de responsabilidad
- Optimizar productividad por ejecutor
- Corregir asignaciones incorrectas
- Balancear trabajo entre personal disponible

### ¿Cómo lo hace?
1. Usuario selecciona folios a reasignar
2. Indica ejecutor origen (actual)
3. Selecciona ejecutor destino (nuevo responsable)
4. Sistema valida que folios estén asignados al ejecutor origen
5. Actualiza campo de ejecutor en los folios
6. Registra la reasignación en bitácora
7. Confirma cambio realizado

### ¿Qué necesita para funcionar?
- Folios de apremio existentes
- Ejecutor origen con folios asignados
- Ejecutor destino activo
- Criterios de selección de folios
- Permisos de reasignación

## Datos y Tablas

### Tabla Principal
**ta_15_apremios**: Actualiza campo de ejecutor asignado

### Tablas Relacionadas
- **ta_15_ejecutores**: Ejecutores origen y destino
- **ta_catalogo_recaudadoras**: Recaudadoras

### Stored Procedures (SP)
Posiblemente utiliza SP para reasignación masiva

### Tablas que Afecta
**Actualiza:**
- ta_15_apremios (ejecutor asignado)

## Impacto y Repercusiones

### Repercusiones Operativas
- Optimiza distribución de trabajo
- Permite continuidad operativa
- Balancea cargas de trabajo
- Facilita reorganización

### Repercusiones Financieras
- Afecta prenómina de ejecutores
- Cambia comisiones entre personal
- Redistribuye productividad

### Repercusiones Administrativas
- Mantiene trazabilidad de cambios
- Documenta reasignaciones
- Facilita auditoría de asignaciones
- Permite evaluación de decisiones

## Validaciones y Controles
- Valida que folios estén asignados al ejecutor origen
- Verifica que ejecutor destino esté activo
- Requiere confirmación de reasignación
- Registra usuario que reasigna
- Control transaccional

## Casos de Uso

**Incapacidad de ejecutor:**
- Ejecutor se incapacita por 15 días
- Supervisor reasigna sus 50 folios a otros 2 ejecutores
- Trabajo continúa sin interrupción

**Reorganización por zonas:**
- Se rediseñan zonas de responsabilidad
- Se reasignan masivamente folios según nueva geografía
- Cada ejecutor tiene su nueva zona

## Usuarios del Sistema
- Supervisores de cobranza
- Coordinador de ejecución fiscal
- Jefes de recaudadora

## Relaciones con Otros Módulos
- **Prenomina.pas**: Afecta cálculo de comisiones
- **Listados.pas**: Reportes por ejecutor reflejan reasignaciones
- **Requerimientos.pas**: Asignación inicial
- **Ejecutores.pas**: Selección de ejecutores
