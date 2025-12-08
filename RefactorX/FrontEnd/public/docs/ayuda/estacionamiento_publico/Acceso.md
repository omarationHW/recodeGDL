# Acceso - Sistema de Estacionamientos

## Proposito Administrativo

Controlar y registrar el acceso de usuarios al sistema de estacionamientos municipales. Garantiza la seguridad del sistema validando credenciales y estableciendo sesiones de trabajo autorizadas.

## Funcionalidad Principal

Ventana de inicio de sesion (login) que valida usuarios y contrasenas contra la base de datos de seguridad, estableciendo conexiones a las bases de datos del sistema segun las credenciales proporcionadas.

## Proceso de Negocio

### Que hace
- Valida usuario y contrasena contra la base de datos de seguridad (Informix)
- Establece conexiones a bases de datos: ingresosifx (seguridad) y esta_ifx (estacionamientos)
- Registra el usuario que inicio sesion para auditorias
- Controla intentos fallidos de acceso
- Mantiene el ultimo usuario que accedio al sistema (via registro de Windows)

### Para que
- Garantizar que solo personal autorizado acceda al sistema de estacionamientos
- Establecer trazabilidad de quien realiza operaciones en el sistema
- Proteger la informacion sensible de pagos, folios y concesiones
- Permitir auditorias posteriores por usuario

### Como funciona
1. El usuario ingresa su nombre de usuario (se recupera el ultimo usado del registro de Windows)
2. Ingresa su contrasena
3. El sistema valida contra la tabla de usuarios (base datos ingresosifx)
4. Si es correcto: conecta a base esta_ifx y registra el usuario en sesion
5. Si es incorrecto: muestra mensaje de error y permite reintentar
6. Al salir, guarda el usuario para proxima sesion

### Que necesita
- Base de datos ingresosifx operativa (tabla de usuarios y contrasenas)
- Base de datos esta_ifx operativa (datos de estacionamientos)
- Usuario estacion con contrasena 3st4c10n configurado en la base de datos
- Registro de Windows habilitado para guardar preferencias

## Datos y Tablas

### Tablas consultadas
- Usuarios (base ingresosifx): valida credenciales, obtiene id_usuario, nombre, nivel, recaudadora asignada
- QryPasswords: recupera datos completos del usuario autenticado

### Datos clave
- Usuario: login del empleado
- Contrasena: credencial de acceso (encriptada en BD)
- ID Usuario: identificador unico del empleado
- Nivel: perfil de acceso (determina permisos en el sistema)
- Recaudadora: oficina/zona asignada al usuario

## Impacto y Repercusiones

### Impacto operativo
- CRITICO: Sin este modulo nadie puede acceder al sistema
- Cualquier falla bloquea todas las operaciones de estacionamientos
- Determina que funciones puede ejecutar cada usuario

### Repercusiones
- Accesos no autorizados pueden generar alteracion de folios, pagos o cancelaciones
- Perdida de contrasenas obliga a reseteo por administrador
- Fallas en base de seguridad paralizan ventas y cobros de estacionamientos

## Validaciones

1. Usuario y contrasena no vacios: ambos campos son obligatorios
2. Credenciales validas: usuario y contrasena deben coincidir con base de datos
3. Usuario activo: el usuario debe estar dado de alta y no bloqueado
4. Conexion a bases de datos: verifica que ambas bases esten accesibles
5. Registro exitoso: valida que se pudo registrar el usuario en sesion

## Casos de Uso

### Caso 1: Inicio de turno
1. Cajero llega al inicio de su turno
2. Abre el sistema
3. Ingresa su usuario y contrasena
4. Sistema valida y abre menu principal
5. Puede comenzar a cobrar folios

### Caso 2: Cambio de turno
1. Cajero A cierra sesion
2. Cajero B inicia sesion con sus credenciales
3. Sistema registra el cambio de operador
4. Operaciones posteriores quedan vinculadas a Cajero B

### Caso 3: Acceso denegado
1. Usuario ingresa contrasena incorrecta
2. Sistema muestra mensaje de error
3. Usuario puede reintentar
4. Despues de 3 intentos queda bloqueado (seguridad)

## Usuarios del Modulo

- Cajeros: personal de ventanilla que cobra folios
- Supervisores: revisan operaciones y autorizan excepciones
- Administradores: configuran usuarios y accesos
- Personal administrativo: consultan reportes e historicos

## Relaciones con Otros Modulos

- sFrm_menu: modulo principal al que accede despues de login exitoso
- DsDBGasto: componente de conexion a bases de datos que utiliza
- DsPasswords: consulta datos completos del usuario
- mensaje: muestra alertas de error o confirmacion
- UnDatos: almacena datos globales de sesion (usuario, ejercicio, id)

## Notas Importantes

- Almacena el ultimo usuario en registro de Windows: Software\ayuntamiento\usuario sistema
- El ano de ejercicio se obtiene automaticamente de la fecha del sistema
- Conexion a esta_ifx usa credenciales fijas (estacion/3st4c10n)
- Conexion a ingresosifx usa credenciales del usuario que inicia sesion
