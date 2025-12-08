# AutorizaDes - Autorización de Descuentos en Apremios

## Propósito Administrativo
Gestión de descuentos autorizados sobre adeudos en proceso de cobro coactivo. Permite que funcionarios autorizados otorguen porcentajes de descuento a contribuyentes morosos para facilitar la recuperación de cartera vencida.

## Funcionalidad Principal
Módulo que administra la autorización, modificación y cancelación de descuentos aplicables a folios de apremio. Controla quién autoriza, qué porcentaje se aplica, y mantiene el registro histórico de descuentos otorgados para incentivar el pago voluntario.

## Proceso de Negocio

### ¿Qué hace?
- Autoriza descuentos sobre adeudos en apremio
- Registra quién autoriza el descuento y con qué fundamento
- Aplica porcentajes de descuento a multas, recargos y gastos
- Modifica descuentos previamente autorizados
- Cancela descuentos otorgados
- Valida que el porcentaje no exceda el límite autorizado por funcionario
- Actualiza automáticamente los montos del folio según el descuento
- Mantiene historial de descuentos por folio

### ¿Para qué sirve?
- Incentivar el pago voluntario de adeudos mediante descuentos autorizados
- Recuperar cartera vencida con montos reducidos en lugar de procedimientos largos
- Documentar legalmente los descuentos otorgados con fecha y funcionario responsable
- Aplicar políticas públicas de regularización fiscal
- Facilitar convenios de pago con contribuyentes morosos
- Cumplir programas de regularización tributaria

### ¿Cómo lo hace?
1. Usuario captura el folio de apremio a aplicar descuento
2. Sistema valida que el folio esté practicado y vigente
3. Muestra la información del adeudo y aplicación (mercados, aseo, estacionamientos, etc.)
4. Permite seleccionar el funcionario autorizante de un catálogo
5. Captura el porcentaje de descuento y fecha de autorización
6. Valida que el porcentaje no exceda el límite del funcionario autorizante
7. Si es nuevo, inserta registro en tabla de autorizados
8. Si existe, permite modificar porcentaje o fecha
9. Ejecuta stored procedure que recalcula montos con descuento aplicado
10. Permite dar de baja (cancelar) descuentos, restaurando montos originales al 100%

### ¿Qué necesita para funcionar?
- Folio de apremio válido, practicado y vigente
- Funcionario autorizante del catálogo ta_15_quienautor
- Porcentaje de descuento dentro del límite autorizado
- Fecha de autorización del descuento
- Recaudadora y módulo del folio (mercados, aseo, infracciones, etc.)
- Permisos de usuario para autorizar descuentos

## Datos y Tablas

### Tabla Principal
**ta_15_autorizados**: Registro de descuentos autorizados por folio de apremio

### Tablas Relacionadas
- **ta_15_apremios** (QryFolios): Folios de apremio a los que se aplica descuento
- **ta_15_quienautor** (Qryquien): Catálogo de funcionarios autorizados para otorgar descuentos
- **ta_11_locales** (QryMercados): Información de locales de mercados
- **ta_16_contratos_aseo** (QryAseo): Información de contratos de aseo
- **ta_24_estacionamientospublicos** (QryPublicos): Estacionamientos públicos
- **ta_28_estacionamientosexclusivos** (QryExclusivos): Estacionamientos exclusivos
- **ta_14_infracciones** (QryInfracciones): Infracciones de tránsito
- **ta_13_cementerios** (QryCementerios): Cementerios y fosas
- **ta_catalogo_recaudadoras** (QryRec): Recaudadoras del sistema
- **ta_catalogo_aplicaciones** (QryAplica): Aplicaciones/módulos del sistema

### Stored Procedures (SP)
**Qryporcentaje**: Actualiza los montos del folio aplicando el porcentaje de descuento autorizado
**Qry100por**: Restaura los montos del folio al 100% cuando se cancela el descuento

### Tablas que Afecta
**Inserta en:**
- ta_15_autorizados (al dar alta a un descuento nuevo)

**Actualiza:**
- ta_15_autorizados (al modificar descuento o dar de baja)
- ta_15_apremios (actualiza montos con descuento mediante SP)

## Impacto y Repercusiones

### Repercusiones Operativas
- Agiliza la recuperación de cartera vencida mediante descuentos
- Reduce tiempos de cobro al incentivar pago voluntario
- Disminuye costos operativos de embargos y remates
- Permite negociación con contribuyentes morosos
- Facilita cumplimiento de metas de recaudación

### Repercusiones Financieras
- Recupera parte del adeudo en lugar de mantenerlo incobrable
- Reduce pérdidas por prescripción de créditos fiscales
- Genera ingresos inmediatos aunque con descuento
- Optimiza la relación costo-beneficio del cobro coactivo
- Permite implementar programas de regularización fiscal
- Afecta directamente los montos de ingresos por apremios

### Repercusiones Administrativas
- Documenta la autoridad que otorga descuentos
- Mantiene trazabilidad de beneficios fiscales otorgados
- Permite auditar descuentos por funcionario y fecha
- Garantiza que descuentos no excedan límites autorizados
- Facilita reportes de descuentos para transparencia
- Cumple requisitos legales de fundamentación

## Validaciones y Controles
- Valida que el folio exista y esté vigente
- Requiere que el folio esté practicado (clave_practicado = 'P')
- Valida que el porcentaje no exceda el límite del funcionario autorizante (porcentajetope)
- Impide descuentos en folios cancelados o pagados
- Control de transacciones con StartTransaction/Commit/Rollback
- Valida fechas de autorización
- Requiere confirmación para aplicar o cancelar descuentos
- Permite descuentos solo a usuarios con permisos especiales (QryPermiso)
- Filtra funcionarios autorizantes según permisos del usuario (funcionarios vs. todos)

## Casos de Uso

**Autorización de descuento en programa de regularización:**
- Municipio lanza programa con 50% de descuento en recargos
- Contribuyente solicita acogerse al programa
- Supervisor valida requisitos y autoriza 50% de descuento
- Sistema aplica descuento y recalcula monto total
- Contribuyente paga monto con descuento en ventanilla

**Modificación de porcentaje autorizado:**
- Se autorizó 30% pero debe ser 40% según programa vigente
- Usuario modifica el porcentaje de 30% a 40%
- Sistema recalcula nuevamente los montos
- Monto actualizado para pago del contribuyente

**Cancelación de descuento:**
- Contribuyente no pagó en plazo del programa
- Vence el periodo de descuento autorizado
- Usuario cancela el descuento
- Sistema restaura montos al 100% original

**Validación de límites de autorización:**
- Usuario intenta autorizar 60% de descuento
- Funcionario seleccionado solo tiene límite de 50%
- Sistema rechaza y muestra mensaje de error
- Usuario debe seleccionar funcionario con mayor autorización

## Usuarios del Sistema
- Jefe de departamento de ejecución fiscal
- Director de ingresos
- Tesorero municipal
- Subdirector de cobranza
- Supervisores con facultades especiales
- Coordinadores de regularización tributaria

## Relaciones con Otros Módulos
- **Individual.pas / Individual_Folio.pas**: Muestra si un folio tiene descuento autorizado
- **Requerimientos.pas**: Considera descuentos al generar requerimientos de pago
- **Facturacion.pas**: Aplica descuentos al calcular importes a cobrar
- **Listados.pas**: Reportes de folios con descuento
- **ReportAutor.pas**: Reporte de descuentos autorizados por funcionario
- **Prenomina.pas**: Considera montos con descuento para calcular comisiones
