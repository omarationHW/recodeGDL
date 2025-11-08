# Menu - Menú Principal del Sistema de Apremios

## Propósito Administrativo
Punto central de navegación del sistema APREMIOS. Proporciona acceso organizado a todas las funcionalidades del sistema de cobro coactivo mediante un menú tipo Outlook con categorías temáticas.

## Funcionalidad Principal
Módulo maestro que sirve como hub de navegación, controla el acceso a todos los módulos del sistema, valida permisos de usuario y gestiona el flujo de trabajo del sistema de ejecución fiscal.

## Proceso de Negocio

### ¿Qué hace?
- Presenta menú principal con acceso a todos los módulos
- Organiza funcionalidades por categorías (consultas, modificaciones, reportes, catálogos)
- Valida permisos de usuario antes de abrir módulos
- Gestiona ventanas MDI (múltiples documentos)
- Muestra información del usuario conectado
- Presenta fecha y hora del sistema
- Controla versión de la aplicación
- Permite cambio de contraseña
- Cierra sesión y sale del sistema

### ¿Para qué sirve?
- Centralizar acceso a funcionalidades
- Organizar operaciones por categorías lógicas
- Controlar permisos por usuario
- Facilitar navegación intuitiva
- Presentar información de contexto (usuario, fecha, hora)
- Mantener control de versiones

### ¿Cómo lo hace?
1. Se activa después del login exitoso (acceso.pas)
2. Carga información del usuario desde variables globales
3. Verifica permisos especiales del usuario
4. Presenta menú con categorías:
   - **Página 1 - Modificaciones**: Individual, Reasignación, Modificación Masiva, Modificación de Bienes
   - **Página 2 - Reportes**: Listados, Recuperación, Prenómina, Estado por Folio
   - **Página 3 - Procesos**: Notificaciones, Requerimientos, Facturación, Cartas Invitación
   - **Página 4 - Catálogos**: Ejecutores, Descuentos Autorizados, Consultas
5. Abre módulos al hacer clic en botones
6. Cierra ventana activa antes de abrir nueva
7. Controla que solo haya una ventana abierta a la vez

### ¿Qué necesita para funcionar?
- Sesión de usuario establecida por acceso.pas
- Variables globales de usuario (GloUsuario, GloId_usuario, GloNivelUsuario)
- Conexión activa a base de datos
- Permisos de usuario registrados en base de datos

## Datos y Tablas

### Tabla Principal
**ta_permiso_adic** (Qrypermiso): Permisos adicionales de usuarios

### Tablas Relacionadas
- **ta_usuarios**: Información del usuario conectado (via ModuloDb)

### Stored Procedures (SP)
No utiliza stored procedures

### Tablas que Afecta
**Solo consulta**:
- ta_permiso_adic

## Impacto y Repercusiones

### Repercusiones Operativas
- Define flujo de trabajo del sistema
- Organiza operaciones de manera lógica
- Facilita capacitación de nuevos usuarios
- Estandariza navegación del sistema

### Repercusiones Financieras
- Indirecto: facilita acceso eficiente a procesos de cobro

### Repercusiones Administrativas
- Centraliza control de acceso
- Facilita auditoría de funcionalidades usadas
- Permite segregación de funciones por permisos
- Documenta versión del sistema en uso

## Validaciones y Controles
- Valida que usuario esté autenticado
- Cierra sistema si no hay sesión activa
- Controla permisos especiales mediante consulta a base de datos
- Muestra/oculta opciones según permisos
- Controla versión de aplicación
- Permite actualización automática de versiones

## Casos de Uso

**Usuario inicia jornada:**
- Ingresa al sistema con credenciales
- Ve menú principal con sus opciones habilitadas
- Accede a módulo de notificaciones para iniciar trabajo del día

**Usuario con permisos especiales:**
- Usuario con permiso de descuentos accede al sistema
- Ve opción de "Autoriza Descuentos" habilitada
- Otros usuarios no ven esa opción

**Cambio de contraseña:**
- Usuario requiere cambiar su contraseña
- Hace clic en opción de cambiar contraseña
- Sistema abre módulo de cambio de clave

## Usuarios del Sistema
- Todos los usuarios del sistema de apremios
- Cada usuario ve opciones según sus permisos

## Relaciones con Otros Módulos

**Módulos invocados desde Página 1 - Modificaciones:**
- **Modificar_bien.pas**: Modificación de datos de bienes embargados
- **Individual_Folio.pas / ConsultaReg.pas**: Consulta individual de folios
- **Reasignacion.pas**: Reasignación de folios entre ejecutores
- **Modif_Masiva.pas**: Modificaciones masivas de folios
- **CMultFolio.pas / CMultEmision.pas**: Consultas múltiples

**Módulos invocados desde Página 2 - Reportes:**
- **Listados.pas**: Listados generales de apremios
- **Listados_Ade.pas**: Listados de adeudos
- **List_Eje.pas / Lista_Eje.pas**: Reportes de ejecutores
- **Recuperacion.pas**: Reporte de recuperación de cartera
- **Prenomina.pas**: Prenómina de ejecutores
- **EstadxFolio.pas**: Estado por folio
- **ListxFec.pas / ListxReg.pas**: Listados por fecha y registro
- **Lista_GastosCob.pas**: Gastos cobrados
- **ExportarExcel.pas**: Exportación a Excel

**Módulos invocados desde Página 3 - Procesos:**
- **Notificaciones.pas / NotificacionesMes.pas**: Notificaciones oficiales
- **Requerimientos.pas**: Generación de requerimientos de pago
- **Facturacion.pas**: Facturación de apremios
- **FirmaElectronica.pas**: Firma electrónica de documentos
- **CartaInvitacion.pas**: Cartas invitación previas

**Módulos invocados desde Página 4 - Catálogos:**
- **ABCEjec.pas**: Alta, baja y cambios de ejecutores
- **AutorizaDes.pas**: Autorización de descuentos
- **ReportAutor.pas**: Reporte de autorizaciones

**Módulos de sistema:**
- **acceso.pas**: Invocado al iniciar para validar usuario
- **sfrm_chgpass.pas**: Cambio de contraseña
- **ModuloDb.pas**: Conexión a base de datos y funciones comunes
