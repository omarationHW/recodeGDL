# consultapredial

## Descripción General

**Categoría:** Consultas

**Propósito:** Módulo de consulta de información del sistema de Recaudación de Guadalajara.

**Usuarios:** Personal de recaudación, personal administrativo, supervisores del área de catastro y funcionarios municipales.

## Proceso Administrativo

### Funcionalidad Principal

Este módulo forma parte del sistema integral de recaudación catastral y tiene como objetivo Módulo de consulta de información.toLowerCase().

### Información Requerida

El módulo requiere los siguientes datos para su operación:

- Información de la base de datos (tablas y consultas)

### Validaciones

El sistema realiza validaciones para garantizar la integridad de la información:

- Validación de campos obligatorios
- Validación de formatos de datos (RFC, CURP, importes)
- Verificación de permisos de usuario según nivel
- Control de duplicidad de registros
- Validación de periodos y fechas
- Verificación de saldos y adeudos

## Tablas de Base de Datos

### Tablas Principales
- **TNatActos**: Tabla principal del módulo
- **dgacto**: Tabla principal del módulo
- **TAvaluosTrans**: Tabla principal del módulo
- **tblpagos**: Tabla principal del módulo
- **Table1**: Tabla principal del módulo
- **ejecutores**: Tabla principal del módulo

### Consultas (TQuery)
- **detpagoQry**: Consulta para obtención/actualización de datos
- **c_movctaQry**: Consulta para obtención/actualización de datos
- **pagadosQry**: Consulta para obtención/actualización de datos
- **bmxQry**: Consulta para obtención/actualización de datos
- **pagreqQry**: Consulta para obtención/actualización de datos
- **condominioQry**: Consulta para obtención/actualización de datos
- **QryModif**: Consulta para obtención/actualización de datos
- **QryIncon**: Consulta para obtención/actualización de datos
- **QryAfavor**: Consulta para obtención/actualización de datos
- **QryDesctoPred**: Consulta para obtención/actualización de datos
- **QryDesctoRec**: Consulta para obtención/actualización de datos
- **QryDesctoMul**: Consulta para obtención/actualización de datos
- **TransmisQry**: Consulta para obtención/actualización de datos
- **AdquirientesQry**: Consulta para obtención/actualización de datos
- **ReqTransQry**: Consulta para obtención/actualización de datos
- ... y 9 consultas adicionales

## Stored Procedures
- **StoredProc1**: Procedimiento almacenado para procesamiento de datos

## Impacto y Repercusiones

### Registros Afectados

### Documentos Generados
- Registros en base de datos
- Bitácora de movimientos para auditoría

### Validaciones de Negocio

- Verificación de permisos de usuario según nivel de acceso
- Control de fechas y periodos fiscales válidos
- Validación de importes y cálculos automáticos
- Verificación de estatus de registros (vigente/baja/cancelado)
- Control de autorización para operaciones sensibles
- Validación de fundamentos legales aplicables

## Flujo de Trabajo

### Proceso Típico

1. **Inicio:** El usuario accede al módulo desde el menú principal del sistema
2. **Selección:** Se seleccionan los parámetros necesarios (contribuyente, periodo, tipo, etc.)
3. **Validación:** El sistema valida la información ingresada y permisos del usuario
4. **Procesamiento:** Se ejecutan los cálculos, consultas o actualizaciones correspondientes
5. **Resultado:** Se generan los reportes, actualizaciones o consultas solicitadas
6. **Confirmación:** El sistema confirma la operación exitosa y registra en bitácora

### Casos Especiales

## Notas Importantes

### Consideraciones Especiales

- Este módulo es parte del sistema integral de recaudación catastral
- Requiere conexión activa a la base de datos
- Todos los movimientos son registrados en bitácora de auditoría
- Se recomienda realizar respaldos antes de operaciones masivas
- Cumplimiento de marco legal y normativo municipal vigente

### Restricciones

- Acceso restringido según perfil de usuario
- No permite eliminación de registros históricos sin autorización
- Requiere cierre de periodo para operaciones financieras críticas
- Operaciones sensibles requieren doble validación
- Control estricto de fechas retroactivas

### Permisos Necesarios
- **Nivel requerido:** Operador, Supervisor o Administrador
- Validación mediante tabla de permisos por usuario
- Registro de accesos en bitácora del sistema
- Trazabilidad completa de operaciones

### Recomendaciones

- Verificar cuidadosamente la información antes de confirmar cambios
- Utilizar los filtros de búsqueda para agilizar consultas
- Revisar los reportes generados antes de impresión masiva
- Mantener actualizados los datos de contribuyentes
- Consultar con supervisor ante situaciones no contempladas
- Contactar al administrador del sistema ante dudas o problemas técnicos

## Información Técnica

**Módulo:** consultapredial.pas
**Categoría del Sistema:** Consultas
**Tablas identificadas:** 6 tabla(s)
**Consultas identificadas:** 24 consulta(s)
**Stored Procedures:** 1 procedimiento(s)

---

*Documento generado automáticamente para el Sistema de Recaudación Catastral de Guadalajara*
*Última actualización: 04/11/2025*
