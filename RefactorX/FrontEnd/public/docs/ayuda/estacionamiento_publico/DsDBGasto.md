# DsDBGasto - Data Module de Conexiones a Base de Datos

## Propósito Administrativo
Módulo fundamental que establece y mantiene las conexiones a las bases de datos necesarias para el funcionamiento del sistema de Estacionamientos.

## Funcionalidad Principal
Gestiona la conexión a dos bases de datos: dbseguridad (para autenticación) y DbCtlesta (para datos de estacionamientos). Valida parámetros de conexión al iniciar la aplicación.

## Proceso de Negocio

### ¿Qué hace?
Al crear el data module, verifica que se hayan pasado usuario y contraseña como parámetros. Establece conexión a dbseguridad con las credenciales del usuario. Si la conexión es exitosa, establece conexión a DbCtlesta con credenciales fijas del sistema.

### ¿Para qué sirve?
Centraliza las conexiones a base de datos para que todos los módulos usen las mismas instancias. Garantiza que el usuario esté autenticado antes de permitir acceso a datos. Facilita el mantenimiento al tener un solo punto de configuración de conexiones.

### ¿Cómo lo hace?
Recibe usuario y contraseña como parámetros de línea de comandos (ParamStr). Configura dbseguridad con alias 'ingresosifx' usando credenciales del usuario. Si conecta exitosamente, configura DbCtlesta con alias 'esta_ifx' usando credenciales fijas ('estacion'/'3st4c10n'). Si falla o no hay parámetros, termina la aplicación.

### ¿Qué necesita para funcionar?
- Parámetros de línea de comandos: usuario y contraseña
- Alias BDE configurados: ingresosifx y esta_ifx
- Bases de datos accesibles

## Datos y Tablas

### Tabla Principal
No maneja tablas directamente. Proporciona conexiones.

### Tablas Relacionadas
Todas las tablas del sistema acceden a través de estas conexiones.

### Stored Procedures (SP)
Ninguno.

### Tablas que Afecta
Ninguna directamente. Proporciona infraestructura para que otros módulos accedan a datos.

## Impacto y Repercusiones

### Repercusiones Operativas
Sin estas conexiones, el sistema completo no puede funcionar.

### Repercusiones Financieras
Indirectas. Permite que todos los módulos accedan a datos financieros.

### Repercusiones Administrativas
Garantiza seguridad al requerir autenticación antes de acceder a datos.

## Validaciones y Controles
- Valida que se pasen exactamente 2 parámetros
- Termina aplicación si no hay parámetros o falla conexión
- Usa credenciales separadas para seguridad vs datos

## Casos de Uso
Se ejecuta automáticamente al iniciar la aplicación. No hay interacción directa del usuario.

## Usuarios del Sistema
Todos los usuarios. Es infraestructura base.

## Relaciones con Otros Módulos
Utilizado por todos los módulos del sistema que accedan a base de datos.
