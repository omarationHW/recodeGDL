# reg

## DescripciÃ³n General

**CategorÃ­a:** General

**PropÃ³sito:**  del sistema de RecaudaciÃ³n de Guadalajara.

**Usuarios:** Personal de recaudaciÃ³n, personal administrativo, supervisores del Ã¡rea de catastro y funcionarios municipales.

## Proceso Administrativo

### Funcionalidad Principal

Este mÃ³dulo forma parte del sistema integral de recaudaciÃ³n catastral y tiene como objetivo .toLowerCase().

### InformaciÃ³n Requerida

El mÃ³dulo requiere los siguientes datos para su operaciÃ³n:

- InformaciÃ³n de la base de datos (tablas y consultas)

### Validaciones

El sistema realiza validaciones para garantizar la integridad de la informaciÃ³n:

- ValidaciÃ³n de campos obligatorios
- ValidaciÃ³n de formatos de datos (RFC, CURP, importes)
- VerificaciÃ³n de permisos de usuario segÃºn nivel
- Control de duplicidad de registros
- ValidaciÃ³n de periodos y fechas
- VerificaciÃ³n de saldos y adeudos

## Tablas de Base de Datos

### Tablas Principales
- **ejecutores**: Tabla principal del mÃ³dulo
- **pagos**: Tabla principal del mÃ³dulo
- **cajeros**: Tabla principal del mÃ³dulo
- **pagosMulta**: Tabla principal del mÃ³dulo
- **Table1**: Tabla principal del mÃ³dulo
- **dbUsrAutMultEsp**: Tabla principal del mÃ³dulo
- **PagosLic**: Tabla principal del mÃ³dulo
- **PagosAnun**: Tabla principal del mÃ³dulo
- **PagosDif**: Tabla principal del mÃ³dulo

### Consultas (TQuery)
- **Query1**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **Tsaldos**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **convcta**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **autorizaQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **autmultaQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **reqmultas**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **multas**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **ejecutorMulta**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **Query2**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **pagomulQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **Qry_obs_hist**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **PerPago**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **updReq**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **noreqQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **valoradeudoQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- ... y 20 consultas adicionales

## Stored Procedures
- **StoredProc1**: Procedimiento almacenado para procesamiento de datos
- **StoredProc2**: Procedimiento almacenado para procesamiento de datos
- **StoredProc3**: Procedimiento almacenado para procesamiento de datos

## Impacto y Repercusiones

### Registros Afectados

### Documentos Generados
- Registros en base de datos
- BitÃ¡cora de movimientos para auditorÃ­a

### Validaciones de Negocio

- VerificaciÃ³n de permisos de usuario segÃºn nivel de acceso
- Control de fechas y periodos fiscales vÃ¡lidos
- ValidaciÃ³n de importes y cÃ¡lculos automÃ¡ticos
- VerificaciÃ³n de estatus de registros (vigente/baja/cancelado)
- Control de autorizaciÃ³n para operaciones sensibles
- ValidaciÃ³n de fundamentos legales aplicables

## Flujo de Trabajo

### Proceso TÃ­pico

1. **Inicio:** El usuario accede al mÃ³dulo desde el menÃº principal del sistema
2. **SelecciÃ³n:** Se seleccionan los parÃ¡metros necesarios (contribuyente, periodo, tipo, etc.)
3. **ValidaciÃ³n:** El sistema valida la informaciÃ³n ingresada y permisos del usuario
4. **Procesamiento:** Se ejecutan los cÃ¡lculos, consultas o actualizaciones correspondientes
5. **Resultado:** Se generan los reportes, actualizaciones o consultas solicitadas
6. **ConfirmaciÃ³n:** El sistema confirma la operaciÃ³n exitosa y registra en bitÃ¡cora

### Casos Especiales

## Notas Importantes

### Consideraciones Especiales

- Este mÃ³dulo es parte del sistema integral de recaudaciÃ³n catastral
- Requiere conexiÃ³n activa a la base de datos
- Todos los movimientos son registrados en bitÃ¡cora de auditorÃ­a
- Se recomienda realizar respaldos antes de operaciones masivas
- Cumplimiento de marco legal y normativo municipal vigente

### Restricciones

- Acceso restringido segÃºn perfil de usuario
- No permite eliminaciÃ³n de registros histÃ³ricos sin autorizaciÃ³n
- Requiere cierre de periodo para operaciones financieras crÃ­ticas
- Operaciones sensibles requieren doble validaciÃ³n
- Control estricto de fechas retroactivas

### Permisos Necesarios
- **Nivel requerido:** SegÃºn configuraciÃ³n del sistema
- ValidaciÃ³n mediante tabla de permisos por usuario
- Registro de accesos en bitÃ¡cora del sistema
- Trazabilidad completa de operaciones

### Recomendaciones

- Verificar cuidadosamente la informaciÃ³n antes de confirmar cambios
- Utilizar los filtros de bÃºsqueda para agilizar consultas
- Revisar los reportes generados antes de impresiÃ³n masiva
- Mantener actualizados los datos de contribuyentes
- Consultar con supervisor ante situaciones no contempladas
- Contactar al administrador del sistema ante dudas o problemas tÃ©cnicos

## InformaciÃ³n TÃ©cnica

**MÃ³dulo:** reg.pas
**CategorÃ­a del Sistema:** General
**Tablas identificadas:** 9 tabla(s)
**Consultas identificadas:** 35 consulta(s)
**Stored Procedures:** 3 procedimiento(s)

---

*Documento generado automÃ¡ticamente para el Sistema de RecaudaciÃ³n Catastral de Guadalajara*
*Ãšltima actualizaciÃ³n: 04/11/2025*
