# ImprimeDesctos

## DescripciÃ³n General

**CategorÃ­a:** Descuentos

**PropÃ³sito:** MÃ³dulo de aplicaciÃ³n de descuentos del sistema de RecaudaciÃ³n de Guadalajara.

**Usuarios:** Personal de recaudaciÃ³n, personal administrativo, supervisores del Ã¡rea de catastro y funcionarios municipales.

## Proceso Administrativo

### Funcionalidad Principal

Este mÃ³dulo forma parte del sistema integral de recaudaciÃ³n catastral y tiene como objetivo MÃ³dulo de aplicaciÃ³n de descuentos.toLowerCase().

### InformaciÃ³n Requerida

El mÃ³dulo requiere los siguientes datos para su operaciÃ³n:

- InformaciÃ³n de la base de datos (tablas y consultas)
- Datos del descuento (porcentaje, periodo aplicable)
- Fundamento legal del descuento
- AutorizaciÃ³n correspondiente

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
- **foliosdesc**: Tabla principal del mÃ³dulo

### Consultas (TQuery)
- **descMultaQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **ContribQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **recaudQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **DescuentosQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **DescMultaMpalQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **UpdFolio**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **cancDescQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **multasQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **AutorizaQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **desctosMpalQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **cancDescMpalQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **descMultaTransQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **desctosTranQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **cancDesctranQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **QryDescrec**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- ... y 26 consultas adicionales

## Stored Procedures
- **StoredProc1**: Procedimiento almacenado para procesamiento de datos
- **Sp_Papeletas**: Procedimiento almacenado para procesamiento de datos
- **Sp_PapeletasRec**: Procedimiento almacenado para procesamiento de datos
- **Sp_PapeletasRgos**: Procedimiento almacenado para procesamiento de datos
- **Sp_DescuentosMultas**: Procedimiento almacenado para procesamiento de datos
- **Sp_DescuentosRecargos**: Procedimiento almacenado para procesamiento de datos

## Impacto y Repercusiones

### Registros Afectados
- Tabla de **descuentos**: Registro de beneficios fiscales
- Ajuste de importes a pagar

### Documentos Generados
- Reportes impresos con formato oficial
- Documentos con folio consecutivo
- Listados para supervisiÃ³n y auditorÃ­a
- Archivos para exportaciÃ³n (PDF, Excel)

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
- Descuentos requieren verificaciÃ³n de cumplimiento de requisitos legales
- AplicaciÃ³n de descuentos debe ser autorizada

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
- **Nivel requerido:** Supervisor o Administrador (operaciones crÃ­ticas)
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

**MÃ³dulo:** ImprimeDesctos.pas
**CategorÃ­a del Sistema:** Descuentos
**Tablas identificadas:** 1 tabla(s)
**Consultas identificadas:** 41 consulta(s)
**Stored Procedures:** 6 procedimiento(s)

---

*Documento generado automÃ¡ticamente para el Sistema de RecaudaciÃ³n Catastral de Guadalajara*
*Ãšltima actualizaciÃ³n: 04/11/2025*
