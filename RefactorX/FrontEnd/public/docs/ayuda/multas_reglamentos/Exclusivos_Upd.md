# Exclusivos_Upd

## Descripción General

**Categoría:** General

**Propósito:**  del sistema de Recaudación de Guadalajara.

**Usuarios:** Personal de recaudación, personal administrativo, supervisores del área de catastro y funcionarios municipales.

## Proceso Administrativo

### Funcionalidad Principal

Este módulo forma parte del sistema integral de recaudación catastral y tiene como objetivo .toLowerCase().

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
- Este módulo utiliza consultas dinámicas (TQuery)

### Consultas (TQuery)
- **Qry_exc_contrato**: Consulta para obtención/actualización de datos
- **QryAdeudos**: Consulta para obtención/actualización de datos
- **Ins_Porcentaje**: Consulta para obtención/actualización de datos
- **QryEx_EliminaDescuentos**: Consulta para obtención/actualización de datos
- **QryPermiso**: Consulta para obtención/actualización de datos
- **QryFuncionarios**: Consulta para obtención/actualización de datos
- **QryDescuentos**: Consulta para obtención/actualización de datos
- **QryDescMulta**: Consulta para obtención/actualización de datos
- **Ins_PorcentajeMulta**: Consulta para obtención/actualización de datos
- **QryEx_EliminaDescuentosMulta**: Consulta para obtención/actualización de datos
- **QryFuncionariosMulta**: Consulta para obtención/actualización de datos

## Stored Procedures
- **sp14_upd_cor_bat**: Procedimiento almacenado para procesamiento de datos

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
- **Nivel requerido:** Según configuración del sistema
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

**Módulo:** Exclusivos_Upd.pas
**Categoría del Sistema:** General
**Tablas identificadas:** 0 tabla(s)
**Consultas identificadas:** 11 consulta(s)
**Stored Procedures:** 1 procedimiento(s)

---

*Documento generado automáticamente para el Sistema de Recaudación Catastral de Guadalajara*
*Última actualización: 04/11/2025*
