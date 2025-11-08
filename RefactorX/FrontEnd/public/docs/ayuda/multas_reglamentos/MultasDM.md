# MultasDM

## DescripciÃ³n General

**CategorÃ­a:** Multas

**PropÃ³sito:** MÃ³dulo de gestiÃ³n de multas del sistema de RecaudaciÃ³n de Guadalajara.

**Usuarios:** Personal de recaudaciÃ³n, personal administrativo, supervisores del Ã¡rea de catastro y funcionarios municipales.

## Proceso Administrativo

### Funcionalidad Principal

Este mÃ³dulo forma parte del sistema integral de recaudaciÃ³n catastral y tiene como objetivo MÃ³dulo de gestiÃ³n de multas.toLowerCase().

### InformaciÃ³n Requerida

El mÃ³dulo requiere los siguientes datos para su operaciÃ³n:

- InformaciÃ³n de la base de datos (tablas y consultas)
- Datos de la multa (folio, importe, tipo de infracciÃ³n)
- InformaciÃ³n del contribuyente infractor
- Fundamento legal de la multa

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
- **ConsultaLeyes**: Tabla principal del mÃ³dulo
- **ConsultaInfracciones**: Tabla principal del mÃ³dulo
- **presMultasTbl**: Tabla principal del mÃ³dulo
- **ConsultaDependencias**: Tabla principal del mÃ³dulo

### Consultas (TQuery)
- **ConsultaMulta**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **ConsultaPagos**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **reqmultaQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **centrosQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **autorizaQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **ConsultaDesctos**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **nolaborqry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **dameIdPrescQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **AutModifQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **c_dmultampalqry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **Query1**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **presQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **ConsultaMulta_H**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **multasQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **c_dependQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- ... y 6 consultas adicionales

## Stored Procedures
Este mÃ³dulo no utiliza procedimientos almacenados especÃ­ficos.

## Impacto y Repercusiones

### Registros Afectados
- Tabla de **multas**: Registro y control de multas
- Afecta el estatus de multas (vigente, pagada, cancelada)
- ActualizaciÃ³n de saldos del contribuyente

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
- EmisiÃ³n de multas requiere fundamento legal especÃ­fico
- Multas pueden estar sujetas a prescripciÃ³n

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
- **Nivel requerido:** Operador autorizado o superior
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

**MÃ³dulo:** MultasDM.pas
**CategorÃ­a del Sistema:** Multas
**Tablas identificadas:** 4 tabla(s)
**Consultas identificadas:** 21 consulta(s)
**Stored Procedures:** 0 procedimiento(s)

---

*Documento generado automÃ¡ticamente para el Sistema de RecaudaciÃ³n Catastral de Guadalajara*
*Ãšltima actualizaciÃ³n: 04/11/2025*
