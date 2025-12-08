# ConsultaDatosEnergia

## DescripciÃ³n General

**CategorÃ­a:** Consultas

**PropÃ³sito:** MÃ³dulo de consulta de informaciÃ³n del sistema de Mercados de Guadalajara.

**Usuarios:** Personal administrativo del departamento de Mercados, personal de recaudaciÃ³n y supervisores del Ã¡rea.

## Proceso Administrativo

### Funcionalidad Principal

Este mÃ³dulo forma parte del sistema integral de gestiÃ³n de mercados municipales y tiene como objetivo MÃ³dulo de consulta de informaciÃ³n.toLowerCase().

### InformaciÃ³n Requerida

El mÃ³dulo requiere los siguientes datos para su operaciÃ³n:

- InformaciÃ³n de la base de datos (tablas y consultas)
- Consumo de energÃ­a elÃ©ctrica
- Lecturas de medidores

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
- **QryEnergia**: Consulta para obtenciÃ³n de datos
- **QryReqEnergia**: Consulta para obtenciÃ³n de datos
- **QryAdeudosEnergia**: Consulta para obtenciÃ³n de datos
- **QryRecargos**: Consulta para obtenciÃ³n de datos
- **QryDiaVenc**: Consulta para obtenciÃ³n de datos

## Stored Procedures
Este mÃ³dulo no utiliza procedimientos almacenados especÃ­ficos.

## Impacto y Repercusiones

### Registros Afectados
- Tablas de **energÃ­a elÃ©ctrica**: Consumos y cargos

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
- **Nivel requerido:** Operador, Supervisor o Administrador
- ValidaciÃ³n mediante tabla de permisos por usuario
- Registro de accesos en bitÃ¡cora

### Recomendaciones

- Verificar la informaciÃ³n antes de confirmar cambios
- Utilizar los filtros de bÃºsqueda para agilizar consultas
- Revisar los reportes generados antes de impresiÃ³n masiva
- Contactar al administrador del sistema ante dudas o problemas

## InformaciÃ³n TÃ©cnica

**MÃ³dulo:** ConsultaDatosEnergia.pas
**CategorÃ­a del Sistema:** Consultas
**Tablas identificadas:** 0 tabla(s)
**Consultas identificadas:** 5 consulta(s)
**Stored Procedures:** 0 procedimiento(s)

---

*Documento generado automÃ¡ticamente para el Sistema de Mercados de Guadalajara*
*Ãšltima actualizaciÃ³n: 04/11/2025*
