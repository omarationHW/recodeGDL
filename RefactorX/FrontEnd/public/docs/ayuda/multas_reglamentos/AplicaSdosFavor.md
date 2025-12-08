# AplicaSdosFavor

## DescripciÃ³n General

**CategorÃ­a:** Saldos a Favor

**PropÃ³sito:** MÃ³dulo de gestiÃ³n de saldos a favor del sistema de RecaudaciÃ³n de Guadalajara.

**Usuarios:** Personal de recaudaciÃ³n, personal administrativo, supervisores del Ã¡rea de catastro y funcionarios municipales.

## Proceso Administrativo

### Funcionalidad Principal

Este mÃ³dulo forma parte del sistema integral de recaudaciÃ³n catastral y tiene como objetivo MÃ³dulo de gestiÃ³n de saldos a favor.toLowerCase().

### InformaciÃ³n Requerida

El mÃ³dulo requiere los siguientes datos para su operaciÃ³n:

- InformaciÃ³n de la base de datos (tablas y consultas)
- NÃºmero de licencia
- Datos del titular
- Giro comercial

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
- Este mÃ³dulo utiliza consultas dinÃ¡micas (TQuery)

### Consultas (TQuery)
- **busca_sol**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **convcta**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **contrib**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **SdosFavorQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **Aplica_PagFavorQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **sdosFAplica**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **detSaldosQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **selecDetSalQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **importeQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **pagosQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **PagosSdosQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **tienereqQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **x**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos

## Stored Procedures
- **detpagoSP**: Procedimiento almacenado para procesamiento de datos
- **paga_detsalSP**: Procedimiento almacenado para procesamiento de datos

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

**MÃ³dulo:** AplicaSdosFavor.pas
**CategorÃ­a del Sistema:** Saldos a Favor
**Tablas identificadas:** 0 tabla(s)
**Consultas identificadas:** 14 consulta(s)
**Stored Procedures:** 2 procedimiento(s)

---

*Documento generado automÃ¡ticamente para el Sistema de RecaudaciÃ³n Catastral de Guadalajara*
*Ãšltima actualizaciÃ³n: 04/11/2025*
