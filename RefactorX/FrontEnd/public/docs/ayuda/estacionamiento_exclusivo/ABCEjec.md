# ABCEjec - Alta, Baja y Cambios de Ejecutores Fiscales

## Propósito Administrativo
Gestión del catálogo de ejecutores fiscales que participan en el procedimiento de cobro coactivo. Este módulo permite administrar el personal autorizado para practicar diligencias de apremio, notificaciones y embargos.

## Funcionalidad Principal
Módulo de administración del personal ejecutor que realiza el alta, modificación y baja de ejecutores fiscales en el sistema de apremios. Mantiene actualizado el padrón de personal autorizado para realizar cobros coactivos.

## Proceso de Negocio

### ¿Qué hace?
- Registra nuevos ejecutores fiscales en el sistema
- Actualiza información de ejecutores existentes (nombre, RFC, datos de homologación)
- Da de baja temporal a ejecutores que ya no están activos
- Reactiva ejecutores que habían sido dados de baja
- Valida la vigencia y autorización de cada ejecutor
- Registra el oficio de nombramiento y periodo de vigencia

### ¿Para qué sirve?
- Mantener un catálogo actualizado del personal autorizado para realizar cobro coactivo
- Controlar quién puede practicar diligencias de apremio
- Establecer periodos de vigencia de los nombramientos
- Garantizar la legalidad de las acciones de cobro ejecutivo mediante personal debidamente autorizado
- Facilitar la asignación de cuentas morosas a ejecutores activos

### ¿Cómo lo hace?
1. El usuario captura el número de ejecutor a consultar
2. El sistema busca si el ejecutor existe en la recaudadora correspondiente
3. Si existe, muestra sus datos para modificación o baja
4. Si no existe, habilita el formulario para dar de alta un nuevo ejecutor
5. Valida que todos los campos obligatorios estén completos (nombre, RFC, homologación, oficio, fechas)
6. Registra la transacción con control de integridad
7. Mantiene el estado de vigencia: Activo (A) o Baja (B)

### ¿Qué necesita para funcionar?
- Número de ejecutor fiscal
- Nombre completo del ejecutor
- Iniciales para RFC
- Fecha de nacimiento para RFC
- Homoclave del RFC
- Número de oficio de nombramiento
- Fecha de inicio de vigencia del nombramiento
- Fecha de término de vigencia
- Recaudadora a la que pertenece
- Permisos de usuario para modificar el catálogo

## Datos y Tablas

### Tabla Principal
**ta_15_ejecutores**: Catálogo maestro de ejecutores fiscales autorizados

### Tablas Relacionadas
- **ta_catalogo_recaudadoras** (QryRec): Define las recaudadoras del sistema

### Stored Procedures (SP)
No utiliza stored procedures. Ejecuta sentencias SQL directas para INSERT y UPDATE.

### Tablas que Afecta
**Inserta en:**
- ta_15_ejecutores (al dar de alta un nuevo ejecutor)

**Actualiza:**
- ta_15_ejecutores (al modificar datos o cambiar vigencia A/B)

## Impacto y Repercusiones

### Repercusiones Operativas
- Define quién puede ser asignado a folios de apremio
- Afecta la capacidad de trabajo del departamento de ejecución fiscal
- Controla la carga de trabajo por ejecutor
- Permite planificar asignaciones según ejecutores activos

### Repercusiones Financieras
- Impacta indirectamente en la recuperación de cartera vencida
- Ejecutores activos determinan la capacidad de cobro del departamento
- Afecta el cálculo de prenómina de ejecutores

### Repercusiones Administrativas
- Mantiene la trazabilidad de quién realiza las diligencias
- Garantiza que solo personal autorizado practique actos de cobro
- Documenta los periodos de vigencia de nombramientos
- Permite auditar las actuaciones por ejecutor

## Validaciones y Controles
- Valida que el número de ejecutor no esté vacío
- Requiere nombre completo obligatorio
- Valida RFC (iniciales, fecha nacimiento, homoclave)
- Requiere número de oficio de nombramiento
- Valida fechas de inicio y término de vigencia
- Control de transacciones con StartTransaction/Commit/Rollback
- Impide registros duplicados por recaudadora

## Casos de Uso

**Alta de nuevo ejecutor:**
- Se nombra un nuevo ejecutor fiscal mediante oficio oficial
- Se capturan sus datos personales y RFC
- Se registra en el sistema con estado "Activo"
- Queda disponible para asignación de folios de apremio

**Modificación de datos:**
- Se corrige información personal o administrativa
- Se actualiza periodo de vigencia por renovación de nombramiento
- Se registra el usuario que realiza la modificación

**Baja de ejecutor:**
- El ejecutor deja de laborar o es removido del cargo
- Se marca como estado "Baja" (B)
- No puede recibir nuevas asignaciones pero conserva su historial

**Reactivación:**
- Un ejecutor dado de baja regresa al departamento
- Se cambia su estado de "B" a "A"
- Queda nuevamente disponible para asignaciones

## Usuarios del Sistema
- Supervisor del área de ejecución fiscal
- Jefe del departamento de apremios
- Coordinador administrativo
- Personal de recursos humanos del área de ingresos
- Usuarios con permisos especiales para modificar catálogos

## Relaciones con Otros Módulos
- **Requerimientos.pas**: Consulta ejecutores activos para asignar folios
- **Prenomina.pas**: Utiliza el catálogo para generar nómina de ejecutores
- **Reasignacion.pas**: Consulta ejecutores para reasignar cuentas
- **Lista_Eje.pas / List_Eje.pas**: Reportes de ejecutores
- **Individual.pas**: Muestra información del ejecutor asignado a un folio
- **Listados.pas**: Filtros y reportes por ejecutor
