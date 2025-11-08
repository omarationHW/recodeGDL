# DatosIndividuales

## DescripciÃ³n General

**CategorÃ­a:** General

**PropÃ³sito:**  del sistema de Mercados de Guadalajara.

**Usuarios:** Personal administrativo del departamento de Mercados, personal de recaudaciÃ³n y supervisores del Ã¡rea.

## Proceso Administrativo

### Funcionalidad Principal

Este mÃ³dulo forma parte del sistema integral de gestiÃ³n de mercados municipales y tiene como objetivo .toLowerCase().

### InformaciÃ³n Requerida

El mÃ³dulo requiere los siguientes datos para su operaciÃ³n:

- InformaciÃ³n de la base de datos (tablas y consultas)

### Validaciones

El sistema realiza validaciones para garantizar la integridad de la informaciÃ³n:

- ValidaciÃ³n de campos obligatorios
- ValidaciÃ³n de formatos de datos
- VerificaciÃ³n de permisos de usuario
- Control de duplicidad de registros

## Tablas de Base de Datos

### Tablas Principales
- Este mÃ³dulo utiliza consultas dinÃ¡micas (TQuery)

### Consultas (TQuery)
- **QryLocales**: Consulta para obtenciÃ³n de datos
- **QryUsuario**: Consulta para obtenciÃ³n de datos
- **QryMercado**: Consulta para obtenciÃ³n de datos
- **QryCuota**: Consulta para obtenciÃ³n de datos
- **QryRequerimientos**: Consulta para obtenciÃ³n de datos
- **QryAdeudos**: Consulta para obtenciÃ³n de datos
- **QryTotalAde**: Consulta para obtenciÃ³n de datos
- **QryEnerg**: Consulta para obtenciÃ³n de datos
- **QryRecargos**: Consulta para obtenciÃ³n de datos
- **QryRecargosTot**: Consulta para obtenciÃ³n de datos
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
- BitÃ¡cora de movimientos

### Validaciones de Negocio

- VerificaciÃ³n de permisos de usuario segÃºn nivel de acceso
- Control de fechas y periodos vÃ¡lidos
- ValidaciÃ³n de importes y cÃ¡lculos
- VerificaciÃ³n de estatus de registros (vigente/baja)

## Flujo de Trabajo

### Proceso TÃ­pico

1. **Inicio:** El usuario accede al mÃ³dulo desde el menÃº principal
2. **SelecciÃ³n:** Se seleccionan los parÃ¡metros necesarios (mercado, periodo, etc.)
3. **Procesamiento:** El sistema valida la informaciÃ³n y procesa los datos
4. **Resultado:** Se generan los reportes, actualizaciones o consultas solicitadas
5. **ConfirmaciÃ³n:** El sistema confirma la operaciÃ³n exitosa

### Casos Especiales

## Notas Importantes

### Consideraciones Especiales

- Este mÃ³dulo es parte del sistema integral de mercados
- Requiere conexiÃ³n activa a la base de datos
- Los cambios son registrados en bitÃ¡cora de auditorÃ­a
- Se recomienda realizar respaldos antes de operaciones masivas

### Restricciones

- Acceso restringido segÃºn perfil de usuario
- No permite eliminaciÃ³n de registros histÃ³ricos
- Requiere cierre de periodo para operaciones financieras

### Permisos Necesarios
- **Nivel requerido:** SegÃºn configuraciÃ³n del sistema
- ValidaciÃ³n mediante tabla de permisos por usuario
- Registro de accesos en bitÃ¡cora

### Recomendaciones

- Verificar la informaciÃ³n antes de confirmar cambios
- Utilizar los filtros de bÃºsqueda para agilizar consultas
- Revisar los reportes generados antes de impresiÃ³n masiva
- Contactar al administrador del sistema ante dudas o problemas

## InformaciÃ³n TÃ©cnica

**MÃ³dulo:** DatosIndividuales.pas
**CategorÃ­a del Sistema:** General
**Tablas identificadas:** 0 tabla(s)
**Consultas identificadas:** 18 consulta(s)
**Stored Procedures:** 7 procedimiento(s)

---

*Documento generado automÃ¡ticamente para el Sistema de Mercados de Guadalajara*
*Ãšltima actualizaciÃ³n: 04/11/2025*
