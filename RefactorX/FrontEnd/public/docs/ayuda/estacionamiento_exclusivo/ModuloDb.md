# ModuloDb - Módulo de Conexión a Base de Datos

## Propósito Administrativo
Módulo central que gestiona la conexión a la base de datos, proporciona funciones utilitarias comunes y mantiene las variables globales del sistema. Es el núcleo de acceso a datos del sistema de apremios.

## Funcionalidad Principal
Data Module que centraliza la conexión a la base de datos MySQL/Interbase, proporciona funciones de validación, formato de fechas, autenticación y control de versiones. Todas las operaciones de base de datos del sistema pasan por este módulo.

## Proceso de Negocio

### ¿Qué hace?
- Establece y mantiene conexión a base de datos de ingresos
- Recibe credenciales por parámetros de línea de comandos
- Valida usuarios y contraseñas contra base de datos
- Proporciona funciones de formato de fechas
- Gestiona consulta de fecha/hora del servidor
- Valida entradas numéricas
- Controla versiones de aplicaciones
- Mantiene variables globales del sistema (usuario, permisos, nivel)

### ¿Para qué sirve?
- Centralizar acceso a base de datos
- Evitar múltiples conexiones concurrentes
- Estandarizar funciones comunes de formato y validación
- Mantener estado de sesión de usuario
- Controlar versiones del sistema
- Facilitar mantenimiento de conexiones
- Proporcionar utilidades de fecha/hora centralizadas

### ¿Cómo lo hace?
**Conexión a base de datos:**
1. Recibe usuario y contraseña como parámetros al iniciar
2. Configura conexión con esos parámetros
3. Abre conexión a base de datos
4. Termina aplicación si falla la conexión

**Validación de usuario:**
1. Recibe usuario y contraseña a validar
2. Intenta conectar con esas credenciales
3. Consulta tabla de usuarios
4. Regresa ID de usuario si es válido

**Control de versiones:**
1. Recibe nombre de proyecto y versión actual
2. Consulta tabla de versiones
3. Compara versión actual con registrada
4. Indica si hay nueva versión disponible

### ¿Qué necesita para funcionar?
- Parámetros de línea de comandos con usuario y contraseña
- Servidor de base de datos MySQL/Interbase accesible
- Configuración de conexión (alias, servidor, puerto)
- Tablas de control (usuarios, versiones)

## Datos y Tablas

### Tabla Principal
**ta_usuarios** (QryUsuario): Usuarios del sistema con permisos

### Tablas Relacionadas
- **ta_versiones** (QryVersiones): Control de versiones de aplicaciones
- **ta_catalogo_recaudadoras**: Recaudadoras (via QryUsuario)

### Stored Procedures (SP)
No utiliza stored procedures directamente

### Tablas que Afecta
**Solo consulta**:
- ta_usuarios
- ta_versiones
- Query para obtener fecha/hora del servidor

## Impacto y Repercusiones

### Repercusiones Operativas
- Punto crítico: sin este módulo no funciona ninguna operación
- Centraliza autenticación y acceso a datos
- Facilita diagnóstico de problemas de conexión

### Repercusiones Financieras
- Crítico: toda operación financiera depende de este módulo

### Repercusiones Administrativas
- Controla seguridad de acceso
- Mantiene integridad de sesiones
- Facilita auditoría mediante variables globales
- Controla actualización de versiones

## Validaciones y Controles
- Requiere exactamente 2 parámetros al iniciar (usuario y contraseña)
- Termina aplicación si no recibe parámetros correctos
- Termina aplicación si falla conexión inicial
- Valida formato de entradas numéricas
- Controla precisión de decimales en validaciones

## Casos de Uso

**Inicio de aplicación:**
- Sistema recibe parámetros en línea de comandos
- ModuloDb valida parámetros
- Establece conexión a base de datos
- Sistema queda listo para operar

**Consulta de fecha/hora servidor:**
- Módulo requiere fecha/hora oficial
- Invoca función FechaHora
- Obtiene timestamp del servidor de base de datos
- Usa esa fecha para operaciones

**Formato de fecha para usuario:**
- Sistema necesita mostrar fecha en español
- Invoca FechaAletras con fecha a formatear
- Recibe texto "15 de Marzo de 2024"
- Muestra al usuario

**Validación de entrada numérica:**
- Usuario captura monto en campo
- Sistema invoca NInvalidVal por cada tecla
- Valida formato numérico y decimales
- Rechaza caracteres inválidos

## Usuarios del Sistema
- Todos (usado por todos los módulos internamente)
- No es accesible directamente por usuarios

## Relaciones con Otros Módulos
- **Todos los módulos del sistema**: Dependen de ModuloDb para acceso a datos
- **acceso.pas**: Usa funciones de validación de usuario
- **Menu.pas**: Usa variables globales establecidas aquí
- **Cualquier módulo con consultas**: Usa la conexión Dbingresos

**Variables globales que mantiene:**
- **DMGral**: Instancia del DataModule (acceso global)
- **GloId_usuario**: ID del usuario conectado
- **GloUsuario**: Nombre de usuario conectado
- **GloClave**: Clave del usuario (deprecated por seguridad)
- **gloNivelUsuario**: Nivel de permisos del usuario
- **permiso**: Bandera de permisos especiales
- **cUser, cPass**: Credenciales de conexión

**Funciones públicas:**
- **fechaHoraFormato**: Formatea fecha/hora a string
- **FechaHora**: Obtiene fecha/hora del servidor
- **FechaAletras**: Convierte fecha a texto en español
- **NInvalidVal**: Valida entrada numérica con decimales
- **validausuario**: Valida credenciales de usuario
- **HayNuevaVersion**: Verifica si hay actualización disponible
