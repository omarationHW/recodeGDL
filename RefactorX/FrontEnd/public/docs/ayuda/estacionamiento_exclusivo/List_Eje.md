# Listado de Ejecutores

## Propósito Administrativo
Gestionar el catálogo de ejecutores fiscales del municipio, permitiendo consultar, agregar, modificar y dar de baja a los funcionarios autorizados para realizar notificaciones y diligencias de cobro coactivo.

## Funcionalidad Principal
Este módulo mantiene actualizado el padrón de ejecutores fiscales, registrando sus datos personales, información fiscal, categoría, oficina recaudadora asignada y vigencia, facilitando la gestión del personal operativo del área de apremios.

## Proceso de Negocio

### ¿Qué hace?
Administra el catálogo completo de ejecutores fiscales, permitiendo altas, bajas, modificaciones y consultas del personal autorizado para realizar diligencias de notificación, requerimiento, secuestro y demás actos del procedimiento administrativo de ejecución.

### ¿Para qué sirve?
- Mantener actualizado el padrón de ejecutores fiscales
- Controlar el personal autorizado para notificaciones
- Registrar cambios de adscripción y categoría
- Dar de baja ejecutores que causan baja del servicio
- Consultar información de ejecutores activos
- Facilitar la asignación de folios a ejecutores

### ¿Cómo lo hace?
1. Muestra el listado completo de ejecutores registrados
2. Permite buscar ejecutores por diferentes criterios
3. Facilita el alta de nuevos ejecutores con su información completa
4. Permite modificar datos de ejecutores existentes
5. Registra bajas de ejecutores con fecha y motivo
6. Controla la vigencia de cada ejecutor
7. Filtra ejecutores por oficina recaudadora
8. Valida que no se dupliquen claves de ejecutor

### ¿Qué necesita para funcionar?
- Usuario con permisos administrativos
- Datos completos del ejecutor (nombre, RFC, categoría)
- Oficina recaudadora de adscripción
- Clave única de ejecutor
- Fechas de alta y baja (si aplica)

## Datos y Tablas

### Tabla Principal
- **ta_15_ejecutores**: Catálogo de ejecutores fiscales

### Tablas Relacionadas
- **ta_14_recaudadoras**: Oficinas recaudadoras de adscripción
- **ta_15_apremios**: Folios asignados a cada ejecutor
- **ta_15_categorias**: Catálogo de categorías de ejecutores

### Stored Procedures (SP)
No utiliza stored procedures específicos. Realiza operaciones CRUD directas.

### Tablas que Afecta
- **INSERT en ta_15_ejecutores**: Registra nuevos ejecutores
- **UPDATE en ta_15_ejecutores**: Modifica datos de ejecutores
- **UPDATE en ta_15_ejecutores**: Registra bajas (vigencia = 'B')

## Impacto y Repercusiones

### Repercusiones Operativas
- Mantiene actualizado el personal operativo de apremios
- Facilita la asignación de folios a ejecutores activos
- Controla el personal autorizado para diligencias
- Permite trazabilidad de responsabilidades
- Apoya la gestión de recursos humanos del área

### Repercusiones Financieras
- No tiene impacto financiero directo
- Indirectamente afecta la capacidad de cobro del área
- Permite control del personal que maneja cobros
- Facilita auditorías de gestión de personal

### Repercusiones Administrativas
- Garantiza que solo personal autorizado realice diligencias
- Documenta la plantilla de ejecutores fiscales
- Facilita asignación equitativa de cargas de trabajo
- Apoya evaluación de desempeño individual
- Permite rotación y reasignación de personal

## Validaciones y Controles
- Valida que la clave de ejecutor sea única
- Verifica que el RFC tenga formato válido
- Asegura que el ejecutor esté asignado a una oficina recaudadora
- Valida fechas de alta y baja
- Controla que no se eliminen ejecutores con folios asignados
- Verifica permisos del usuario para modificar el catálogo

## Casos de Uso
1. **Jefe de Ejecutores**: Da de alta un nuevo ejecutor fiscal
2. **Recursos Humanos**: Actualiza datos de ejecutor por cambio de RFC
3. **Director de Área**: Da de baja ejecutor que causó baja laboral
4. **Supervisor**: Consulta ejecutores activos para asignación de folios
5. **Coordinador**: Cambia adscripción de ejecutor a otra oficina

## Usuarios del Sistema
- Directores y subdirectores de área
- Jefes de ejecutores fiscales
- Personal de recursos humanos
- Coordinadores administrativos
- Supervisores de cobro coactivo
- Usuarios con permisos administrativos especiales

## Relaciones con Otros Módulos
- **Ejecutores**: Módulo de consulta de ejecutores
- **ABCEjec**: Administración del catálogo de ejecutores
- **Modif_Masiva**: Asignación masiva de folios a ejecutores
- **Reasignacion**: Reasignación de folios entre ejecutores
- **Prenomina**: Cálculo de prenómina por ejecutor
- **CMultEmision**: Asignación automática de folios a ejecutores
