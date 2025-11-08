# Requerimientos - Generación de Requerimientos de Pago

## Propósito Administrativo
Genera e imprime requerimientos de pago (documentos oficiales) que notifican al contribuyente moroso la existencia de un adeudo y lo conminan a pagar dentro de un plazo legal, bajo apercibimiento de iniciar el procedimiento de embargo. Es la fase formal del procedimiento administrativo de ejecución.

## Funcionalidad Principal
Módulo que crea folios de apremio, calcula adeudos con recargos y gastos, asigna ejecutores fiscales, genera documentos oficiales de requerimiento de pago e imprime notificaciones legales para mercados, aseo y otras aplicaciones.

## Proceso de Negocio

### ¿Qué hace?
- Genera folios de apremio a partir de cuentas morosas
- Calcula adeudos con actualización, recargos y gastos de ejecución
- Asigna folios a ejecutores fiscales para notificación
- Imprime requerimientos de pago oficiales
- Registra fecha de emisión y practicación
- Controla diligencias (notificación, entregas, citatorios)
- Aplica multas según normatividad
- Genera lotes de requerimientos por selección
- Permite modificar datos antes de emisión final

### ¿Para qué sirve?
- Formalizar el procedimiento de cobro coactivo
- Notificar legalmente al contribuyente su adeudo
- Establecer plazo para pago voluntario antes del embargo
- Documentar el proceso de cobro ejecutivo
- Cumplir requisitos legales del procedimiento administrativo
- Fundar y motivar la facultad económica coactiva
- Generar evidencia legal del requerimiento

### ¿Cómo lo hace?
1. Usuario selecciona cuentas morosas (mercados, aseo, etc.)
2. Define periodo de adeudo a cobrar
3. Sistema calcula:
   - Impuesto o cuota base adeudada
   - Recargos por mora según porcentajes legales
   - Actualización monetaria
   - Gastos de ejecución (notificación, requerimiento)
   - Multas si aplica
4. Asigna número de folio consecutivo
5. Asigna ejecutor fiscal responsable
6. Genera registro en tabla de apremios
7. Imprime documento oficial de requerimiento con:
   - Datos del contribuyente
   - Desglose del adeudo
   - Fundamento legal
   - Plazo para pago
   - Apercibimiento de embargo
   - Firma del ejecutor
8. Registra fecha de emisión y practicación

### ¿Qué necesita para funcionar?
- Cuentas con adeudos vencidos
- Catálogo de gastos de ejecución vigentes
- Porcentajes de recargos legales
- Catálogo de ejecutores activos
- Plantilla de requerimiento oficial
- Permisos para generar folios de apremio
- Último folio usado por recaudadora

## Datos y Tablas

### Tabla Principal
**ta_15_apremios**: Folios de apremio (requerimientos) generados

### Tablas Relacionadas
- **ta_11_locales / ta_11_adeudos**: Adeudos de mercados
- **ta_16_contratos_aseo / ta_16_adeudos**: Adeudos de aseo
- **ta_15_ejecutores**: Ejecutores fiscales
- **ta_15_gastos**: Gastos de ejecución por año/mes
- **ta_15_recargos**: Porcentajes de recargos moratorios
- **ta_15_detalle**: Detalle de periodos adeudados
- **ta_catalogo_recaudadoras**: Recaudadoras

### Stored Procedures (SP)
Posiblemente utiliza SP para cálculo de adeudos y generación de folios (según estructura observada)

### Tablas que Afecta
**Inserta en:**
- ta_15_apremios (nuevo folio de requerimiento)
- ta_15_detalle (periodos adeudados del folio)

**Consulta:**
- Todas las tablas de adeudos y catálogos mencionadas

## Impacto y Repercusiones

### Repercusiones Operativas
- Inicia formalmente el procedimiento de cobro coactivo
- Define carga de trabajo de ejecutores
- Establece fechas límite para pago voluntario
- Genera obligaciones legales de notificación
- Documenta actuaciones de autoridad

### Repercusiones Financieras
- Determina montos oficiales a cobrar
- Incrementa adeudo con recargos y gastos
- Genera documentación para recuperación judicial
- Afecta indicadores de cartera vencida
- Permite proyectar recuperación por apremios

### Repercusiones Administrativas
- Cumple requisitos legales del procedimiento
- Genera evidencia para juicios y defensas
- Documenta actuación de ejecutores
- Permite auditoría del proceso de cobro
- Establece responsabilidades por folio
- Mantiene control de folios emitidos

## Validaciones y Controles
- Valida que cuenta tenga adeudo real
- Calcula recargos según tabla vigente
- Aplica gastos según catálogo oficial
- Asigna folios consecutivos sin duplicados
- Valida asignación de ejecutor activo
- Requiere confirmación antes de generar
- Control transaccional con rollback
- Impide generar duplicados para misma cuenta/periodo

## Casos de Uso

**Emisión masiva de requerimientos:**
- Se detectan 100 locales de mercado con adeudos
- Usuario selecciona rango de locales
- Define periodo adeudado
- Sistema calcula y genera 100 folios
- Asigna a ejecutores por zona
- Imprime lote de requerimientos

**Requerimiento individual urgente:**
- Contribuyente específico tiene adeudo relevante
- Usuario genera folio individual
- Calcula adeudo total
- Asigna ejecutor
- Imprime requerimiento inmediato
- Ejecutor lo notifica el mismo día

**Revisión antes de emisión:**
- Usuario selecciona cuentas
- Sistema calcula montos preliminares
- Usuario revisa y ajusta si es necesario
- Confirma generación
- Sistema emite folios oficiales

## Usuarios del Sistema
- Coordinador de ejecución fiscal
- Supervisores de cobranza
- Personal de emisión de requerimientos
- Ejecutores fiscales (consulta)
- Jefes de recaudadora

## Relaciones con Otros Módulos
- **Individual.pas / Individual_Folio.pas**: Consulta folios generados
- **Notificaciones.pas**: Genera notificaciones posteriores al requerimiento
- **Prenomina.pas**: Calcula comisiones por folios cobrados
- **Listados.pas**: Reportes de requerimientos emitidos
- **Facturacion.pas**: Registra pagos de requerimientos
- **ABCEjec.pas / Ejecutores.pas**: Selecciona ejecutores
- **Modificar / Modif_Masiva**: Permite modificar folios después
