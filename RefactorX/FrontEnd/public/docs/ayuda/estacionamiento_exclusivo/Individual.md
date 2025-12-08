# Emisión Individual de Requerimientos

## Propósito Administrativo
Emitir requerimientos de pago individuales para contribuyentes con adeudos vencidos, generando folios de apremio uno por uno con todos los datos necesarios para iniciar el procedimiento administrativo de ejecución.

## Funcionalidad Principal
Este módulo permite crear folios de apremio de manera individual para locales de mercados o contratos de aseo, calculando automáticamente adeudos, recargos, multas y gastos de ejecución, y generando un folio único de requerimiento de pago.

## Proceso de Negocio

### ¿Qué hace?
Crea un folio de requerimiento de pago individual para un contribuyente específico, calculando todos los conceptos adeudados hasta la fecha, aplicando recargos moratorios y determinando los gastos de ejecución correspondientes.

### ¿Para qué sirve?
- Emitir requerimientos de pago personalizados
- Atender casos especiales que no entran en emisión masiva
- Generar folios fuera del ciclo regular de emisión
- Iniciar procedimiento de cobro coactivo individual
- Documentar adeudos con certeza jurídica

### ¿Cómo lo hace?
1. El usuario selecciona el tipo de aplicación (Mercados o Aseo)
2. Busca y selecciona el contribuyente específico (local o contrato)
3. El sistema calcula automáticamente todos los adeudos vencidos
4. Aplica recargos moratorios según la normativa vigente
5. Determina los gastos de ejecución aplicables
6. Calcula el importe total del requerimiento
7. Genera un nuevo folio de apremio con numeración consecutiva
8. Registra el documento en la tabla de apremios
9. Permite imprimir el requerimiento de pago

### ¿Qué necesita para funcionar?
- Usuario autorizado para emitir requerimientos
- Contribuyente registrado con adeudos vencidos
- Tabla de recargos actualizada
- Tabla de gastos de ejecución vigente
- Numeración de folios disponible
- Datos completos del contribuyente

## Datos y Tablas

### Tabla Principal
- **ta_15_apremios**: Tabla donde se registra el nuevo folio de requerimiento

### Tablas Relacionadas
- **ta_11_locales**: Datos de locales en mercados
- **ta_11_adeudo_local**: Adeudos de locales en mercados
- **ta_16_contratos_aseo**: Contratos de aseo contratado
- **ta_16_adeudos_aseo**: Adeudos de aseo
- **ta_12_recargos**: Porcentajes de recargos moratorios por periodo
- **ta_12_gastos**: Gastos de ejecución aplicables
- **ta_14_recaudadoras**: Información de oficinas recaudadoras
- **ta_15_folio**: Control de numeración de folios

### Stored Procedures (SP)
No utiliza stored procedures específicos. Realiza cálculos y consultas SQL dinámicas.

### Tablas que Afecta
- **INSERT en ta_15_apremios**: Crea el nuevo registro de requerimiento
- **UPDATE en ta_15_folio**: Actualiza el consecutivo de folios

## Impacto y Repercusiones

### Repercusiones Operativas
- Inicia formalmente el procedimiento administrativo de ejecución
- Genera documentación legal para el expediente
- Activa el reloj procesal para notificaciones
- Permite seguimiento individual del caso

### Repercusiones Financieras
- Formaliza el cobro de adeudos vencidos
- Añade recargos moratorios al adeudo original
- Incorpora gastos de ejecución recuperables
- Incrementa el monto total a cobrar
- Documenta la cartera vencida en cobro coactivo

### Repercusiones Administrativas
- Crea un expediente de cobro individual
- Genera obligación de seguimiento y notificación
- Activa tiempos y plazos legales
- Requiere asignación a ejecutor fiscal
- Documenta acciones de cobro para auditorías

## Validaciones y Controles
- Verifica que el contribuyente tenga adeudos vencidos
- Valida que no exista un requerimiento previo vigente
- Confirma que el contribuyente esté activo
- Calcula correctamente recargos según normativa
- Valida disponibilidad de numeración de folios
- Asegura que el usuario tenga permisos de emisión

## Casos de Uso
1. **Supervisor de Cobro**: Emite requerimiento para caso especial fuera del proceso masivo
2. **Ejecutor Fiscal**: Genera folio para contribuyente que solicita convenio de pago
3. **Coordinador Administrativo**: Crea requerimiento para adeudo recién identificado
4. **Jefe de Departamento**: Emite folio urgente por instrucción superior

## Usuarios del Sistema
- Supervisores de cobro coactivo
- Jefes de ejecutores fiscales
- Coordinadores administrativos
- Personal autorizado para emisión de requerimientos
- Directores de área con permisos especiales

## Relaciones con Otros Módulos
- **CMultEmision**: Alternativa para emisión masiva de folios
- **ConsultaReg**: Permite consultar los folios emitidos
- **Ejecutores**: Los folios se asignan a ejecutores para gestión
- **Notificaciones**: Los folios deben notificarse posteriormente
- **Recuperacion**: Permite dar seguimiento a los pagos
