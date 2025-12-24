# GAdeudos_OpcMult_RA

## DescripciÃ³n General

**CategorÃ­a:** Adeudos

**Tipo de ObligaciÃ³n:** Giros (Licencias)

**PropÃ³sito:** MÃ³dulo de gestiÃ³n de adeudos del sistema de Otras Obligaciones de Guadalajara.

**Usuarios:** Personal de ingresos, personal administrativo, supervisores del Ã¡rea de recaudaciÃ³n y funcionarios municipales.

## Proceso Administrativo

### Funcionalidad Principal

Este mÃ³dulo forma parte del sistema integral de gestiÃ³n de Otras Obligaciones Fiscales y tiene como objetivo MÃ³dulo de gestiÃ³n de adeudos.toLowerCase() para el control y administraciÃ³n de obligaciones fiscales diversas del municipio.

### InformaciÃ³n Requerida

El mÃ³dulo requiere los siguientes datos para su operaciÃ³n:

- InformaciÃ³n de la base de datos (tablas y consultas)
- Periodo de consulta de adeudos
- Datos del contribuyente
- Conceptos adeudados

### Validaciones

El sistema realiza validaciones para garantizar la integridad de la informaciÃ³n:

- ValidaciÃ³n de campos obligatorios
- ValidaciÃ³n de formatos de datos (RFC, CURP, importes)
- VerificaciÃ³n de permisos de usuario segÃºn nivel
- Control de duplicidad de registros
- ValidaciÃ³n de periodos fiscales
- VerificaciÃ³n de saldos y montos

## Tablas de Base de Datos

### Tablas Principales
- Este mÃ³dulo utiliza consultas dinÃ¡micas (TQuery)

### Consultas (TQuery)
- **QryTablas**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **QryEtiq**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **QryRecaudadoras**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **QryCaja**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **QryPagados**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos

## Stored Procedures
- **spcob34_gdatosg_02**: Procedimiento almacenado para procesamiento de datos

## Impacto y Repercusiones

### Registros Afectados
- Consulta de **adeudos**: Saldos pendientes de pago
- ActualizaciÃ³n de recargos y actualizaciones
- Control de obligaciones vencidas

### Documentos Generados
- Registros en base de datos
- BitÃ¡cora de movimientos para auditorÃ­a

### Validaciones de Negocio

- VerificaciÃ³n de permisos de usuario segÃºn nivel de acceso
- Control de periodos fiscales y fechas vÃ¡lidas
- ValidaciÃ³n de importes y cÃ¡lculos automÃ¡ticos
- VerificaciÃ³n de estatus de registros (activo/baja)
- Control de autorizaciÃ³n para operaciones crÃ­ticas
- ValidaciÃ³n de datos fiscales (RFC, razÃ³n social)

## Flujo de Trabajo

### Proceso TÃ­pico

1. **Inicio:** El usuario accede al mÃ³dulo desde el menÃº principal del sistema
2. **SelecciÃ³n:** Se seleccionan los parÃ¡metros necesarios (contribuyente, periodo, rubro, etc.)
3. **ValidaciÃ³n:** El sistema valida la informaciÃ³n ingresada y permisos del usuario
4. **Procesamiento:** Se ejecutan los cÃ¡lculos, consultas o actualizaciones correspondientes
5. **Resultado:** Se generan los reportes, actualizaciones o consultas solicitadas
6. **ConfirmaciÃ³n:** El sistema confirma la operaciÃ³n exitosa y registra en bitÃ¡cora

### Casos Especiales

## Notas Importantes

### Consideraciones Especiales

- Este mÃ³dulo es parte del sistema integral de Otras Obligaciones Fiscales
- Requiere conexiÃ³n activa a la base de datos
- Todos los movimientos son registrados en bitÃ¡cora de auditorÃ­a
- Se recomienda realizar respaldos antes de operaciones masivas
- Cumplimiento de marco legal y normativo fiscal vigente

### Restricciones

- Acceso restringido segÃºn perfil de usuario
- No permite eliminaciÃ³n de registros histÃ³ricos sin autorizaciÃ³n
- Requiere cierre de periodo para operaciones financieras crÃ­ticas
- Operaciones de baja y cancelaciÃ³n requieren autorizaciÃ³n especial
- Control estricto de fechas retroactivas

### Permisos Necesarios
- **Nivel requerido:** SegÃºn configuraciÃ³n del sistema
- ValidaciÃ³n mediante tabla de permisos por usuario
- Registro de accesos en bitÃ¡cora del sistema
- Trazabilidad completa de operaciones

### Recomendaciones

- Verificar cuidadosamente la informaciÃ³n antes de confirmar cambios
- Mantener actualizados los datos fiscales de contribuyentes
- Utilizar los filtros de bÃºsqueda para agilizar consultas
- Revisar los reportes generados antes de distribuciÃ³n
- Consultar con supervisor ante situaciones no contempladas
- Realizar respaldos periÃ³dicos de la informaciÃ³n
- Contactar al administrador del sistema ante dudas o problemas tÃ©cnicos

## InformaciÃ³n TÃ©cnica

**MÃ³dulo:** GAdeudos_OpcMult_RA.pas
**CategorÃ­a del Sistema:** Adeudos
**Tipo:** Giros (Licencias)
**Tablas identificadas:** 0 tabla(s)
**Consultas identificadas:** 5 consulta(s)
**Stored Procedures:** 1 procedimiento(s)

---

*Documento generado automÃ¡ticamente para el Sistema de Otras Obligaciones de Guadalajara*
*Ãšltima actualizaciÃ³n: 04/11/2025*
