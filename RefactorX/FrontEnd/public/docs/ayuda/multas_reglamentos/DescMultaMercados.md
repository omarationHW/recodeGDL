# DescMultaMercados

## Descripción General

**Categoría:** Multas

**Propósito:** Módulo de gestión de multas del sistema de Recaudación de Guadalajara.

**Usuarios:** Personal de recaudación, personal administrativo, supervisores del área de catastro y funcionarios municipales.

## Proceso Administrativo

### Funcionalidad Principal

Este módulo forma parte del sistema integral de recaudación catastral y tiene como objetivo Módulo de gestión de multas.toLowerCase().

### Información Requerida

El módulo requiere los siguientes datos para su operación:

- Información de la base de datos (tablas y consultas)
- Datos de la multa (folio, importe, tipo de infracción)
- Información del contribuyente infractor
- Fundamento legal de la multa
- Datos del descuento (porcentaje, periodo aplicable)
- Fundamento legal del descuento
- Autorización correspondiente

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
- **buscaLocalQry**: Consulta para obtención/actualización de datos
- **descmulmercQry**: Consulta para obtención/actualización de datos
- **Query1**: Consulta para obtención/actualización de datos
- **Qryrec**: Consulta para obtención/actualización de datos
- **Qrymercados**: Consulta para obtención/actualización de datos
- **Qrysecc**: Consulta para obtención/actualización de datos
- **QryPermiso**: Consulta para obtención/actualización de datos
- **QryFuncionarios**: Consulta para obtención/actualización de datos

## Stored Procedures
- **StrdPrcActualiza**: Procedimiento almacenado para procesamiento de datos

## Impacto y Repercusiones

### Registros Afectados
- Tabla de **multas**: Registro y control de multas
- Afecta el estatus de multas (vigente, pagada, cancelada)
- Actualización de saldos del contribuyente
- Tabla de **descuentos**: Registro de beneficios fiscales
- Ajuste de importes a pagar

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
- Descuentos requieren verificación de cumplimiento de requisitos legales
- Aplicación de descuentos debe ser autorizada
- Emisión de multas requiere fundamento legal específico
- Multas pueden estar sujetas a prescripción

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
- **Nivel requerido:** Operador autorizado o superior
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

**Módulo:** DescMultaMercados.pas
**Categoría del Sistema:** Multas
**Tablas identificadas:** 0 tabla(s)
**Consultas identificadas:** 8 consulta(s)
**Stored Procedures:** 1 procedimiento(s)

---

*Documento generado automáticamente para el Sistema de Recaudación Catastral de Guadalajara*
*Última actualización: 04/11/2025*
