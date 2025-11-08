# Bonificaciones - Gestión de Bonificaciones

## Propósito Administrativo
Módulo para administrar bonificaciones extraordinarias sobre adeudos de mantenimiento, permitiendo aplicar condonaciones parciales o totales autorizadas mediante oficio oficial, con control de aplicación gradual del beneficio.

## Funcionalidad Principal
Permite registrar bonificaciones autorizadas por la autoridad municipal mediante oficio, definiendo el monto total a bonificar, el importe ya bonificado, y el saldo pendiente de aplicar en futuros pagos.

## Proceso de Negocio

### ¿Qué hace?
Gestiona bonificaciones autorizadas oficialmente:
- Registro de bonificaciones por oficio municipal
- Asociación de bonificación a folio RCM específico
- Control de monto total autorizado
- Registro de montos ya aplicados
- Cálculo de saldo pendiente de bonificar
- Vinculación con recaudadora que procesa
- Eliminación de bonificaciones no aplicadas

### ¿Para qué sirve?
Formaliza condonaciones extraordinarias de adeudos:
- Casos especiales autorizados por la autoridad
- Programas de regularización masiva
- Apoyo a situaciones económicas críticas
- Incentivos por regularización voluntaria
- Corrección de cobros indebidos históricos
- Resolución de conflictos legales

### ¿Cómo lo hace?
1. El operador captura:
   - Número de oficio de autorización
   - Año del oficio
   - Recaudadora que procesará
2. El sistema busca si ya existe el oficio registrado
3. Si es nuevo, permite capturar:
   - Folio RCM beneficiado
   - Fecha del oficio
   - Importe total a bonificar
   - Importe ya bonificado (inicialmente 0)
   - Saldo pendiente de bonificar (igual al total inicial)
4. Si ya existe, muestra los datos actuales:
   - Información del espacio funerario
   - Monto total autorizado
   - Monto ya aplicado en pagos
   - Saldo pendiente de aplicar
5. Permite modificar solo fecha y montos
6. Los montos bonificados se actualizan automáticamente desde ABCPagos
7. Permite eliminar bonificaciones no utilizadas
8. El sistema calcula automáticamente el resto pendiente

### ¿Qué necesita para funcionar?
- Oficio oficial de autorización
- Folio RCM válido y existente
- Recaudadora asignada
- Autorización para registrar bonificaciones
- Respaldo documental del oficio

## Datos y Tablas

### Tabla Principal
**ta_13_bonifrcm** - Registro de bonificaciones autorizadas
Contiene: control_bon, oficio, axo, id_rec, doble, control_rcm, cementerio, clase, seccion, linea, fosa (con variantes alfa), fecha_oficio, importe_bonificar, importe_bonificado, importe_resto, usuario, fecha_mov

### Tablas Relacionadas
- **ta_13_datosrcm** - Información del espacio beneficiado
- **ta_13_pagosrcm** - Pagos donde se aplica la bonificación
- **ta_13_adeudosrcm** - Adeudos contra los que se aplica
- **ta_recaudadoras** - Recaudadora que procesa
- **ta_usuarios** - Usuario que registra

### Stored Procedures (SP)
Ninguno (usa SQL directo)

### Tablas que Afecta
**Inserta:**
- ta_13_bonifrcm (nueva bonificación autorizada)

**Actualiza:**
- ta_13_bonifrcm (modificación de montos e importe bonificado)

**Elimina:**
- ta_13_bonifrcm (bonificaciones sin aplicar)

## Impacto y Repercusiones

### Repercusiones Operativas
- Control formal de condonaciones
- Trazabilidad de autorizaciones oficiales
- Aplicación gradual de beneficios
- Evita abusos o errores en condonaciones

### Repercusiones Financieras
- Reducción significativa de cuentas por cobrar
- Afecta indicadores de cobranza
- Debe estar autorizado y presupuestado
- Impacto en ingresos del departamento
- Requiere justificación legal sólida

### Repercusiones Administrativas
- Cumplimiento de resoluciones oficiales
- Documentación legal de condonaciones
- Base para informes a autoridades
- Control de casos extraordinarios
- Transparencia en aplicación de beneficios

## Validaciones y Controles
- Requiere número de oficio y año
- Valida existencia del folio RCM
- Verifica que importe a bonificar sea mayor a cero
- Calcula automáticamente saldo pendiente (total - bonificado)
- Impide eliminar bonificaciones con importe ya bonificado
- Requiere autorización para modificar montos
- Controla que importe bonificado no exceda el autorizado
- Mantiene histórico de usuario y fecha de registro

## Casos de Uso
1. **Bonificación por regularización**: Oficio autoriza condonar 50% de adeudo histórico
2. **Caso social extraordinario**: Condonación del 100% por situación crítica
3. **Corrección de cobros**: Bonificar cobros indebidos de años anteriores
4. **Incentivo de regularización**: Condonación parcial por pago voluntario
5. **Resolución judicial**: Aplicar bonificación ordenada por tribunal
6. **Actualización de bonificado**: Sistema actualiza monto cuando se aplica en pagos
7. **Eliminación de bonificación**: Cancelar bonificación no utilizada por error

## Usuarios del Sistema
- **Jefes de Departamento**: Registro de oficios autorizados
- **Supervisores**: Captura de bonificaciones
- **Contabilidad**: Seguimiento de aplicación
- **Auditoría**: Verificación de autorizaciones
- **Dirección**: Consulta de bonificaciones otorgadas

## Relaciones con Otros Módulos
- **ABCementer/ABCFolio**: Verifica datos del folio beneficiado
- **ABCPagos**: Aplica bonificación y actualiza importe bonificado
- **ConsultaFol**: Muestra bonificaciones registradas
- **Rep_Bon**: Reporte de bonificaciones otorgadas
- **Liquidaciones**: Considera bonificaciones al calcular total a pagar
