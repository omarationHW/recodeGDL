# Acceso - Control de Acceso y Autenticación

## Propósito Administrativo
Módulo de autenticación y control de acceso que valida las credenciales de los usuarios antes de permitir el ingreso al sistema de cementerios, asegurando que solo personal autorizado pueda operar el sistema.

## Funcionalidad Principal
Proporciona el mecanismo de seguridad que valida usuario y contraseña contra la base de datos, establece la sesión del usuario, carga su perfil de permisos y recaudadora asignada, y controla intentos fallidos de acceso.

## Proceso de Negocio

### ¿Qué hace?
Gestiona la autenticación y sesión de usuarios:
- Solicita credenciales (usuario y contraseña)
- Valida contra base de datos de usuarios
- Establece conexión a base de datos con credenciales del usuario
- Carga perfil del usuario (nombre, nivel, recaudadora)
- Registra usuario activo en variables globales del sistema
- Controla intentos fallidos de acceso
- Permite cancelar el acceso
- Cierra conexión al cancelar o fallar autenticación

### ¿Para qué sirve?
Garantiza la seguridad del sistema:
- Solo usuarios registrados pueden acceder
- Cada usuario opera con sus propias credenciales
- Trazabilidad de operaciones por usuario
- Control de nivel de acceso por usuario
- Asignación de recaudadora específica por usuario

### ¿Cómo lo hace?
1. Al iniciar el sistema, muestra formulario de acceso
2. Recupera último usuario utilizado desde registro de Windows
3. Usuario captura su contraseña
4. El sistema intenta conectar a base de datos con usuario/contraseña
5. Si la conexión es exitosa:
   - Consulta tabla ta_usuarios para validar existencia
   - Carga perfil completo del usuario
   - Asigna variables globales: gloUsuario, gloId_usuario, gloNivelUsuario
   - Permite continuar al menú principal
6. Si la conexión falla:
   - Muestra mensaje de error
   - Incrementa contador de intentos
   - Permite reintento (hasta 3 intentos)
   - Al tercer intento fallido, cierra el sistema
7. Si se cancela:
   - Marca sesión como cancelada
   - Cierra conexión
   - Cierra el sistema
8. Al cerrar, guarda último usuario en registro de Windows

### ¿Qué necesita para funcionar?
- Base de datos accesible
- Usuario registrado en ta_usuarios
- Contraseña configurada en el manejador de base de datos
- Conexión de red a servidor de base de datos

## Datos y Tablas

### Tabla Principal
**ta_usuarios** - Catálogo de usuarios del sistema
Contiene: id_usuario, usuario, nombre, estado, id_rec, nivel

### Tablas Relacionadas
**QryUsuario** - Query que valida y carga datos del usuario

### Stored Procedures (SP)
Ninguno (consulta directa a ta_usuarios)

### Tablas que Afecta
**Solo Consulta:**
- ta_usuarios (validación de credenciales y carga de perfil)

**Registro de Windows:**
- Guarda/lee último usuario en: Software\ayuntamiento\usuario sistema

## Impacto y Repercusiones

### Repercusiones Operativas
- Control total de acceso al sistema
- Cada operación se registra con usuario que la realizó
- Bloqueo automático tras intentos fallidos
- Auditoría de conexiones

### Repercusiones Financieras
- Usuarios tienen asignada recaudadora específica
- Operaciones financieras trazables por usuario
- Control de autorizaciones por nivel

### Repercusiones Administrativas
- Cumplimiento de políticas de seguridad
- Responsabilidad individual por operaciones
- Control de accesos no autorizados
- Base para auditoría de usuarios

## Validaciones y Controles
- Valida que usuario y contraseña no estén vacíos
- Verifica conexión a base de datos antes de validar usuario
- Consulta ta_usuarios para confirmar existencia del usuario
- Requiere que usuario esté en estado "Activo"
- Limita intentos fallidos de acceso (máximo 3)
- Guarda último usuario utilizado para agilizar acceso
- Cierra automáticamente si no hay conexión
- Marca sesión como cancelada si usuario abandona

## Casos de Uso
1. **Acceso normal**: Usuario ingresa credenciales y accede al sistema
2. **Contraseña incorrecta**: Sistema notifica error y permite reintento
3. **Usuario inexistente**: Sistema rechaza acceso y solicita validar credenciales
4. **Cancelación de acceso**: Usuario cancela antes de ingresar
5. **Conexión fallida**: Sistema no puede conectar a base de datos
6. **Cambio de usuario**: Cerrar sesión y autenticar con otro usuario
7. **Primer acceso**: Usuario nuevo ingresa por primera vez

## Usuarios del Sistema
- **Todos los usuarios del sistema** deben pasar por esta autenticación

## Relaciones con Otros Módulos
- **Menu**: Después de autenticación exitosa, carga el menú principal
- **Todos los módulos**: Usan variables globales cargadas por Acceso:
  - gloUsuario: nombre de usuario conectado
  - gloId_usuario: ID numérico del usuario
  - gloNivelUsuario: nivel de permisos
- **sfrm_chgpass**: Módulo para cambio de contraseña del usuario actual
