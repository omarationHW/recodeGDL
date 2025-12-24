# DatosIndividuales

## Descripción General

**Categoría:** General

**Propósito:**  del sistema de Mercados de Guadalajara.

**Usuarios:** Personal administrativo del departamento de Mercados, personal de recaudación y supervisores del área.

## Proceso Administrativo

### Funcionalidad Principal

Este módulo forma parte del sistema integral de gestión de mercados municipales y tiene como objetivo .toLowerCase().

### Información Requerida

El módulo requiere los siguientes datos para su operación:

- Información de la base de datos (tablas y consultas)

### Validaciones

El sistema realiza validaciones para garantizar la integridad de la información:

- Validación de campos obligatorios
- Validación de formatos de datos
- Verificación de permisos de usuario
- Control de duplicidad de registros

## Tablas de Base de Datos

### Tablas Principales
- Este módulo utiliza consultas dinámicas (TQuery)

### Consultas (TQuery)
- **QryLocales**: Consulta para obtención de datos
- **QryUsuario**: Consulta para obtención de datos
- **QryMercado**: Consulta para obtención de datos
- **QryCuota**: Consulta para obtención de datos
- **QryRequerimientos**: Consulta para obtención de datos
- **QryAdeudos**: Consulta para obtención de datos
- **QryTotalAde**: Consulta para obtención de datos
- **QryEnerg**: Consulta para obtención de datos
- **QryRecargos**: Consulta para obtención de datos
- **QryRecargosTot**: Consulta para obtención de datos
- ... y 8 consultas adicionales

## Stored Procedures
- **sp_desctomerc**: Procedimiento almacenado para procesamiento de datos
- **spget_lic_estatus**: Procedimiento almacenado para procesamiento de datos
- **admin_recargos**: Procedimiento almacenado para procesamiento de datos
- **admin_multa**: Procedimiento almacenado para procesamiento de datos
- **Sp_CalcRenta**: Procedimiento almacenado para procesamiento de datos
- **SpAdeudosDet**: Procedimiento almacenado para procesamiento de datos
- **SpAdeudoTot**: Procedimiento almacenado para procesamiento de datos

## Impacto y Repercusiones

### Registros Afectados

### Documentos Generados
- Registros en base de datos
- Bitácora de movimientos

### Validaciones de Negocio

- Verificación de permisos de usuario según nivel de acceso
- Control de fechas y periodos válidos
- Validación de importes y cálculos
- Verificación de estatus de registros (vigente/baja)

## Flujo de Trabajo

### Proceso Típico

1. **Inicio:** El usuario accede al módulo desde el menú principal
2. **Selección:** Se seleccionan los parámetros necesarios (mercado, periodo, etc.)
3. **Procesamiento:** El sistema valida la información y procesa los datos
4. **Resultado:** Se generan los reportes, actualizaciones o consultas solicitadas
5. **Confirmación:** El sistema confirma la operación exitosa

### Casos Especiales

## Notas Importantes

### Consideraciones Especiales

- Este módulo es parte del sistema integral de mercados
- Requiere conexión activa a la base de datos
- Los cambios son registrados en bitácora de auditoría
- Se recomienda realizar respaldos antes de operaciones masivas

### Restricciones

- Acceso restringido según perfil de usuario
- No permite eliminación de registros históricos
- Requiere cierre de periodo para operaciones financieras

### Permisos Necesarios
- **Nivel requerido:** Según configuración del sistema
- Validación mediante tabla de permisos por usuario
- Registro de accesos en bitácora

### Recomendaciones

- Verificar la información antes de confirmar cambios
- Utilizar los filtros de búsqueda para agilizar consultas
- Revisar los reportes generados antes de impresión masiva
- Contactar al administrador del sistema ante dudas o problemas

## Información Técnica

**Módulo:** DatosIndividuales.pas
**Categoría del Sistema:** General
**Tablas identificadas:** 0 tabla(s)
**Consultas identificadas:** 18 consulta(s)
**Stored Procedures:** 7 procedimiento(s)

---

*Documento generado automáticamente para el Sistema de Mercados de Guadalajara*
*Última actualización: 04/11/2025*
