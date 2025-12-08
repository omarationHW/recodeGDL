# Modulo - Módulo de Datos Global

## Propósito Administrativo
Módulo central que contiene las conexiones a bases de datos, queries globales, funciones compartidas y variables del sistema utilizadas por todos los demás módulos.

## Funcionalidad Principal
Proporciona infraestructura común para todos los módulos del sistema, incluyendo conexión a base de datos, funciones de utilería y variables globales.

## Componentes Principales

### Conexiones
- **DMGral.Dbingresos**: Conexión principal a base de datos de ingresos
- **QryUsuario**: Query para validación y datos de usuarios
- **QryFecha**: Query para obtener fecha/hora del servidor

### Variables Globales
- **gloUsuario**: Nombre del usuario conectado
- **gloId_usuario**: ID numérico del usuario
- **gloNivelUsuario**: Nivel de permisos (1-9)
- **conectado**: Estado de conexión

### Funciones Utilerías
- **FechaAletras**: Convierte fecha a texto
- **FechaAletrascorta**: Versión corta de fecha en texto
- **validausuario**: Valida credenciales de usuario

## Usuarios del Sistema
Utilizado internamente por todos los módulos (infraestructura)
