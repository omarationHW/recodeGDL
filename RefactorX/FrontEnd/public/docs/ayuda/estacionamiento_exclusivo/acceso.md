# acceso - Control de Acceso y Autenticación de Usuarios

## Propósito Administrativo
Punto de entrada al sistema que valida y autentica las credenciales de los usuarios que acceden al módulo de APREMIOS. Controla quién puede ingresar y establece los permisos de operación.

## Funcionalidad Principal
Módulo de seguridad que gestiona el inicio de sesión de usuarios, valida credenciales contra la base de datos, establece la sesión del usuario y define el nivel de acceso y permisos dentro del sistema de ejecución fiscal.

## Proceso de Negocio

### ¿Qué hace?
- Valida usuario y contraseña contra la base de datos MySQL
- Establece la conexión a la base de datos de ingresos
- Recupera y almacena información del usuario (ID, nivel, recaudadora)
- Configura el ejercicio fiscal de trabajo
- Registra el último usuario que accedió al sistema (persistencia en registro de Windows)
- Controla intentos de acceso fallidos
- Permite cancelar el acceso al sistema

### ¿Para qué sirve?
- Garantizar que solo personal autorizado acceda al sistema de apremios
- Establecer el contexto de trabajo del usuario (recaudadora, permisos, ejercicio)
- Proteger la información sensible de cuentas morosas y adeudos
- Auditar quién accede al sistema y cuándo
- Prevenir accesos no autorizados mediante validación de credenciales

### ¿Cómo lo hace?
1. Presenta la pantalla de inicio de sesión
2. Recupera el último usuario que accedió (desde registro de Windows)
3. Solicita contraseña al usuario
4. Permite seleccionar el ejercicio fiscal (año de trabajo)
5. Al aceptar, intenta conectar a la base de datos con las credenciales proporcionadas
6. Si la conexión es exitosa, consulta la tabla de usuarios
7. Valida que exista exactamente un usuario con esas credenciales
8. Carga información del usuario en variables globales del sistema
9. Habilita el menú principal y funcionalidades según nivel de usuario

### ¿Qué necesita para funcionar?
- Usuario válido en la base de datos de ingresos
- Contraseña correcta
- Conexión a MySQL/Interbase
- Registro de tabla de usuarios (ta_usuarios)
- Ejercicio fiscal válido
- Configuración de conexión a base de datos

## Datos y Tablas

### Tabla Principal
**ta_usuarios** (QryUsuario): Catálogo de usuarios del sistema con credenciales y permisos

### Tablas Relacionadas
No consulta otras tablas directamente

### Stored Procedures (SP)
No utiliza stored procedures

### Tablas que Afecta
**Consulta:**
- ta_usuarios (validación de credenciales y recuperación de perfil)

**No inserta ni actualiza tablas** (solo lectura)

## Impacto y Repercusiones

### Repercusiones Operativas
- Define quién puede operar el sistema de apremios
- Establece la recaudadora de trabajo del usuario
- Determina qué módulos están disponibles según nivel de usuario
- Controla el acceso a funciones administrativas sensibles
- Permite segregación de responsabilidades por recaudadora

### Repercusiones Financieras
- Protege información financiera sensible de adeudos
- Previene manipulación no autorizada de cuentas morosas
- Garantiza trazabilidad de operaciones por usuario
- Resguarda datos de pagos y recuperación de cartera

### Repercusiones Administrativas
- Establece responsabilidad por usuario en cada operación
- Permite auditoría de accesos al sistema
- Facilita control de permisos por nivel de usuario
- Documenta quién trabajó en qué ejercicio fiscal
- Mantiene segregación de funciones entre recaudadoras

## Validaciones y Controles
- Valida que usuario y contraseña no estén vacíos
- Verifica credenciales contra base de datos
- Controla intentos de acceso (máximo de intentos)
- Valida que exista exactamente un registro de usuario
- Manejo de excepciones en conexión a base de datos
- Valida rango de ejercicio fiscal (desde 2001 hasta año actual)
- Cierra sesión si se presiona cancelar
- Almacena último usuario en registro de Windows para persistencia

## Casos de Uso

**Inicio de sesión exitoso:**
- Usuario captura credenciales correctas
- Sistema valida y carga perfil de usuario
- Habilita menú con opciones según permisos
- Usuario puede operar el sistema de apremios

**Credenciales incorrectas:**
- Usuario captura datos incorrectos
- Sistema muestra mensaje de error
- Permite reintentar acceso
- Después de varios intentos fallidos puede bloquear

**Cancelar acceso:**
- Usuario decide no ingresar
- Sistema cierra sin establecer sesión
- No se habilita el menú principal

**Cambio de ejercicio fiscal:**
- Usuario selecciona año de trabajo diferente
- Sistema ajusta consultas al ejercicio seleccionado
- Permite trabajar con información histórica o actual

## Usuarios del Sistema
- Ejecutores fiscales
- Supervisores de cobranza
- Notificadores
- Personal administrativo de apremios
- Jefes de recaudadora
- Coordinadores de ingresos
- Capturistas del área

## Relaciones con Otros Módulos
- **Menu.pas**: Módulo que se activa después del login exitoso
- **ModuloDb.pas**: Establece conexión y variables globales de sesión
- **Todos los módulos del sistema**: Dependen de la sesión establecida por acceso.pas

**Variables globales que establece:**
- gloUsuario: Nombre de usuario conectado
- gloId_usuario: ID del usuario en base de datos
- gloNivelUsuario: Nivel de permisos del usuario
- gloEjercicio: Año fiscal de trabajo
- conectado: Bandera de sesión activa
