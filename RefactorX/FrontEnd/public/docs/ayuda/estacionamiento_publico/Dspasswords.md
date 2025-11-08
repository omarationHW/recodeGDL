# Dspasswords - Data Module de Passwords y Usuarios

## Propósito Administrativo
Módulo de datos que proporciona acceso a información de usuarios del sistema, incluyendo credenciales, niveles de acceso y estados.

## Funcionalidad Principal
Centraliza el acceso a la tabla de usuarios y proporciona consultas parametrizadas para validar y recuperar información de usuarios autenticados.

## Proceso de Negocio

### ¿Qué hace?
Proporciona acceso a TblPasswords (tabla completa de usuarios) y QryPasswords (consulta parametrizada por usuario). Permite recuperar información del usuario: id_usuario, usuario, nombre, estado, id_rec (recaudadora), nivel de acceso.

### ¿Para qué sirve?
Permite al módulo de Acceso validar usuarios y recuperar su información. Facilita la obtención de datos del usuario actual para auditoría y control de permisos. Centraliza el acceso a información de seguridad.

### ¿Cómo lo hace?
Expone una tabla (TblPasswords) para mantenimiento de usuarios y una consulta parametrizada (QryPasswords) que filtra por nombre de usuario para validación y recuperación de datos.

### ¿Qué necesita para funcionar?
- Tabla de usuarios configurada en base de datos de seguridad
- Conexión activa a dbseguridad

## Datos y Tablas

### Tabla Principal
- **TblPasswords**: Tabla de usuarios del sistema

### Tablas Relacionadas
Ninguna directamente en este módulo.

### Stored Procedures (SP)
Ninguno.

### Tablas que Afecta
Ninguna. Es módulo de solo lectura para validación.

## Impacto y Repercusiones

### Repercusiones Operativas
Esencial para autenticación y control de acceso.

### Repercusiones Financieras
Indirectas. Permite identificar quién realiza operaciones financieras.

### Repercusiones Administrativas
Fundamental para auditoría y control de permisos.

## Validaciones y Controles
Las validaciones son realizadas por el módulo que consume este data module.

## Casos de Uso
Utilizado por módulo Acceso durante el login. Utilizado por otros módulos para obtener información del usuario actual.

## Usuarios del Sistema
Todos. Es infraestructura de seguridad.

## Relaciones con Otros Módulos
- **Acceso**: Principal consumidor durante autenticación
- **UnDatos**: Almacena información recuperada del usuario
