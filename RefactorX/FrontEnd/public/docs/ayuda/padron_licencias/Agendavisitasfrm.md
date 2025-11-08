# Agenda de Visitas de Inspección

## Descripción General

### ¿Qué hace este módulo?
Gestiona y consulta la **agenda de visitas programadas** para inspecciones de campo por parte de las diferentes dependencias (Reglamentos, Protección Civil, Ecología, Construcción). Permite ver el calendario de inspecciones asignadas y exportar la agenda.

### ¿Para qué sirve en el proceso administrativo?
- Consultar visitas agendadas por dependencia y fecha
- Programar trabajo de campo de inspectores
- Generar agenda diaria o semanal de inspecciones
- Exportar listado de visitas para entregar a inspectores
- Imprimir rutas de inspección
- Dar seguimiento a inspecciones pendientes

### ¿Quiénes lo utilizan?
- **Jefes de dependencias**: Para asignar y programar inspecciones
- **Inspectores**: Para conocer su agenda de visitas
- **Coordinadores**: Para distribuir carga de trabajo
- **Supervisores**: Para monitorear cumplimiento de agenda

## Proceso Administrativo

**1. Selección de Filtros**
- Seleccionar dependencia (Reglamentos, PC, Ecología, etc.)
- Capturar rango de fechas (fecha inicial - fecha final)
- Click en "Generar" (BitBtn1)

**2. Consulta de Agenda**
- Sistema ejecuta query filtrando por dependencia y fechas
- Muestra listado en grid con:
  - Fecha de la visita
  - Día en letras
  - Folio del trámite
  - Turno (matutino/vespertino)
  - Hora programada
  - Zona y subzona
  - Actividad comercial
  - Propietario (con apellidos)
  - Domicilio completo
  - Fecha de captura

**3. Acciones Disponibles**
- **Exportar a Excel**: Para compartir agenda con inspectores
- **Imprimir**: Genera documento impreso de la agenda
- Visualizar en pantalla para consulta rápida

## Tablas de Base de Datos

### Tabla Principal
**revisiones** (Query) - Vista de visitas programadas

### Tablas que Consulta
1. **revisiones** - Tabla de revisiones de trámites con fechas programadas
2. **Depencencias** (dependencias) - Catálogo de dependencias
3. **tramites** - Información del trámite asociado a la visita

### Tablas que Modifica
**NINGUNA** - Módulo de solo consulta

## Stored Procedures
No utiliza stored procedures.

## Impacto y Repercusiones

- **NO afecta registros**: Módulo de solo lectura
- **NO modifica estatus**: Solo consulta agenda
- **Genera documentos**: Agenda impresa o exportada para inspectores

## Flujo de Trabajo

```
1. Usuario abre módulo
2. Sistema muestra fecha actual como default
3. Usuario selecciona dependencia
4. Usuario ajusta rango de fechas
5. Click en "Generar"
6. Sistema consulta visitas programadas
7. Muestra resultados en grid
8. Usuario puede:
   - Exportar a Excel
   - Imprimir agenda
   - Revisar en pantalla
9. FIN
```

## Notas Importantes

**Usos Prácticos:**
- Inspectores imprimen su agenda al inicio del día
- Coordinadores exportan a Excel para análisis de carga
- Se usa para planificar rutas óptimas de inspección
- Permite identificar inspecciones atrasadas

**Consideraciones:**
- Solo muestra visitas ya programadas (capturadas en otro módulo)
- No permite agendar nuevas visitas (eso se hace en módulo de trámites)
- Es un reporte/consulta de información existente
