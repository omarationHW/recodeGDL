# Lista de Ejecutores (Reporte)

## Propósito Administrativo
Generar reportes impresos del catálogo de ejecutores fiscales activos, proporcionando listados actualizados del personal autorizado para realizar diligencias de cobro coactivo.

## Funcionalidad Principal
Este módulo genera reportes impresos con el listado completo o filtrado de ejecutores fiscales, mostrando su información básica, adscripción y categoría, útil para control administrativo y asignación de trabajo.

## Proceso de Negocio

### ¿Qué hace?
Genera reportes impresos del catálogo de ejecutores fiscales, permitiendo filtrar por oficina recaudadora y estado de vigencia, presentando la información en formato oficial para distribución y consulta.

### ¿Para qué sirve?
- Generar listados actualizados de ejecutores activos
- Distribuir directorios de personal a las áreas
- Apoyar la asignación de folios a ejecutores
- Proporcionar información para reuniones y juntas
- Facilitar control administrativo del personal
- Documentar la plantilla operativa

### ¿Cómo lo hace?
1. El usuario selecciona la oficina recaudadora (o todas)
2. Define si desea ejecutores activos o todos
3. El sistema consulta el catálogo de ejecutores
4. Ordena la información por clave de ejecutor
5. Genera el reporte en formato impreso
6. Muestra la información organizada por oficina recaudadora
7. Incluye datos como clave, nombre, RFC y categoría

### ¿Qué necesita para funcionar?
- Usuario con permisos de consulta
- Catálogo de ejecutores actualizado
- Oficina recaudadora seleccionada
- Formato de reporte configurado

## Datos y Tablas

### Tabla Principal
- **ta_15_ejecutores**: Catálogo de ejecutores fiscales

### Tablas Relacionadas
- **ta_14_recaudadoras**: Información de oficinas recaudadoras

### Stored Procedures (SP)
No utiliza stored procedures. Realiza consultas SQL directas.

### Tablas que Afecta
Este módulo es de solo consulta. No modifica ninguna tabla.

## Impacto y Repercusiones

### Repercusiones Operativas
- Facilita la comunicación interna del área
- Apoya la organización del trabajo operativo
- Proporciona información actualizada de personal
- Agiliza la asignación de responsabilidades

### Repercusiones Financieras
- No tiene impacto financiero directo

### Repercusiones Administrativas
- Genera documentación para control de personal
- Apoya la gestión de recursos humanos
- Facilita auditorías de plantilla
- Proporciona evidencia de organización del área

## Validaciones y Controles
- Valida que existan ejecutores registrados
- Controla el acceso por oficina recaudadora
- Filtra por estado de vigencia
- Verifica permisos del usuario

## Casos de Uso
1. **Jefe de Ejecutores**: Genera listado de su personal para juntas
2. **Director de Área**: Obtiene directorio completo de ejecutores
3. **Recursos Humanos**: Solicita reporte de plantilla actual
4. **Supervisor**: Imprime listado para asignación de folios

## Usuarios del Sistema
- Directores y subdirectores
- Jefes de ejecutores
- Supervisores de cobro
- Personal de recursos humanos
- Coordinadores administrativos

## Relaciones con Otros Módulos
- **List_Eje**: Administración del catálogo de ejecutores
- **Ejecutores**: Consulta individual de ejecutores
- **Modif_Masiva**: Asignación masiva de folios
- **Reasignacion**: Reasignación de folios entre ejecutores
