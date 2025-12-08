# RequerimientosDM

## DescripciÃ³n General

**CategorÃ­a:** Requerimientos

**PropÃ³sito:** MÃ³dulo de gestiÃ³n de requerimientos del sistema de RecaudaciÃ³n de Guadalajara.

**Usuarios:** Personal de recaudaciÃ³n, personal administrativo, supervisores del Ã¡rea de catastro y funcionarios municipales.

## Proceso Administrativo

### Funcionalidad Principal

Este mÃ³dulo forma parte del sistema integral de recaudaciÃ³n catastral y tiene como objetivo MÃ³dulo de gestiÃ³n de requerimientos.toLowerCase().

### InformaciÃ³n Requerida

El mÃ³dulo requiere los siguientes datos para su operaciÃ³n:

- InformaciÃ³n de la base de datos (tablas y consultas)
- Datos del requerimiento (folio, periodo, adeudo)
- InformaciÃ³n del contribuyente
- Domicilio para notificaciÃ³n

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
- **convcta**: Tabla principal del mÃ³dulo
- **recaud**: Tabla principal del mÃ³dulo
- **articulos**: Tabla principal del mÃ³dulo

### Consultas (TQuery)
- **updreqQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **Tsaldos**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **pagos**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **reqpredial**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **UbicacionQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **contribQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **control**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **detreqpredial**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **RegPropQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **compqry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **notificadoQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **reqmultaQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **C_EjecutoresQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **n_EjecutoresQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- **UpdEjecutorQry**: Consulta para obtenciÃ³n/actualizaciÃ³n de datos
- ... y 34 consultas adicionales

## Stored Procedures
- **actualiza**: Procedimiento almacenado para procesamiento de datos
- **StrdPrcArt**: Procedimiento almacenado para procesamiento de datos
- **FechaSys_SP**: Procedimiento almacenado para procesamiento de datos
- **MaquinaSP**: Procedimiento almacenado para procesamiento de datos

## Impacto y Repercusiones

### Registros Afectados
- Tabla de **requerimientos**: Registro de requerimientos emitidos
- Afecta el estatus de adeudos
- Control de notificaciones

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
- Requerimientos deben notificarse legalmente
- Control de tiempos y plazos legales

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

**MÃ³dulo:** RequerimientosDM.pas
**CategorÃ­a del Sistema:** Requerimientos
**Tablas identificadas:** 3 tabla(s)
**Consultas identificadas:** 49 consulta(s)
**Stored Procedures:** 4 procedimiento(s)

---

*Documento generado automÃ¡ticamente para el Sistema de RecaudaciÃ³n Catastral de Guadalajara*
*Ãšltima actualizaciÃ³n: 04/11/2025*
