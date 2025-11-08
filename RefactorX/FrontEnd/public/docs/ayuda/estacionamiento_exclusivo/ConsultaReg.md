# ConsultaReg - Consulta de Registros por Aplicación

## Propósito Administrativo
Permite localizar y consultar los folios de apremio asociados a una cuenta específica (mercado, contrato de aseo, estacionamiento, infracción o cementerio). Facilita la búsqueda de apremios por datos de la cuenta en lugar de por número de folio.

## Funcionalidad Principal
Módulo de búsqueda que localiza folios de apremio consultando por los datos identificadores de la cuenta morosa según el tipo de aplicación, mostrando todos los folios generados para esa cuenta.

## Proceso de Negocio

### ¿Qué hace?
- Busca folios de apremio por datos de la cuenta
- Consulta en diferentes tipos de aplicación (mercados, aseo, estacionamientos, infracciones, cementerios)
- Muestra información de la cuenta asociada
- Lista todos los folios de apremio generados para esa cuenta
- Permite acceder al detalle individual de cada folio
- Presenta datos del contribuyente y ubicación

### ¿Para qué sirve?
- Localizar apremios sin conocer el número de folio
- Buscar por datos del contribuyente o cuenta
- Verificar cuántos folios tiene una cuenta específica
- Consultar adeudos de un local, contrato o placa particular
- Facilitar atención al público que consulta por su cuenta
- Auditar folios de cuentas específicas

### ¿Cómo lo hace?
**Por Mercados:**
1. Usuario captura: oficina, número de mercado, sección, local, letra y bloque
2. Sistema busca el local en catálogo de mercados
3. Si existe, consulta todos los folios de apremio de ese local
4. Muestra datos del local y lista de folios

**Por Aseo:**
1. Usuario captura: número de contrato y tipo de aseo
2. Sistema busca el contrato en catálogo de aseo
3. Si existe, consulta folios de apremio del contrato
4. Muestra datos del contrato y empresa

**Por Estacionamiento Público:**
1. Usuario captura número de estacionamiento
2. Sistema busca en catálogo de estacionamientos públicos
3. Muestra folios asociados

**Por Estacionamiento Exclusivo:**
1. Usuario captura número de exclusivo
2. Sistema busca en catálogo de exclusivos
3. Muestra folios asociados

**Por Infracciones:**
1. Usuario captura número de placa
2. Sistema busca vehículo en padrón
3. Muestra todos los folios de apremio de esa placa

**Por Cementerios:**
1. Usuario captura folio de cementerio
2. Sistema busca fosa en catálogo
3. Muestra folios de apremio asociados

### ¿Qué necesita para funcionar?
- Selección de tipo de aplicación
- Datos identificadores según tipo:
  - Mercados: oficina, mercado, sección, local, letra, bloque
  - Aseo: número de contrato y tipo
  - Públicos: número de estacionamiento
  - Exclusivos: número de exclusivo
  - Infracciones: placa vehicular
  - Cementerios: folio de cementerio
- Acceso a catálogos de cada aplicación
- Tabla de apremios con folios generados

## Datos y Tablas

### Tabla Principal
**ta_15_apremios** (Qryestoy): Folios de apremio a consultar

### Tablas Relacionadas
- **ta_11_locales** (QryMercados): Catálogo de locales de mercados
- **ta_16_contratos_aseo** (QryAseo): Contratos de servicio de aseo
- **ta_24_estacionamientospublicos** (QryPublicos): Estacionamientos públicos
- **ta_28_estacionamientosexclusivos** (QryExclusivos): Estacionamientos exclusivos
- **ta_14_infracciones** / **ta_14_placas** (QryInfracciones): Infracciones y placas
- **ta_13_cementerios** (QryCementerios): Cementerios y fosas

### Stored Procedures (SP)
No utiliza stored procedures

### Tablas que Afecta
**Solo consulta** (no modifica):
- Todas las tablas mencionadas en modo lectura

## Impacto y Repercusiones

### Repercusiones Operativas
- Facilita atención al público que consulta por cuenta
- Agiliza búsqueda sin necesidad de saber número de folio
- Permite identificar cuentas con múltiples folios
- Mejora servicio al contribuyente

### Repercusiones Financieras
- Facilita verificación de adeudos por cuenta
- Permite análisis de cuentas problemáticas
- Ayuda a identificar contribuyentes recurrentes

### Repercusiones Administrativas
- Mejora atención y tiempo de respuesta
- Facilita auditorías por cuenta específica
- Permite análisis de cuentas con múltiples apremios

## Validaciones y Controles
- Valida que se seleccione tipo de aplicación
- Requiere datos completos según tipo de cuenta
- Valida existencia de la cuenta antes de buscar folios
- Muestra mensaje si no se encuentra registro
- Solo muestra folios de la recaudadora del usuario (si aplica)

## Casos de Uso

**Contribuyente consulta su adeudo:**
- Locatario de mercado pregunta si tiene apremios
- Usuario captura datos del local
- Sistema muestra todos los folios del local
- Contribuyente puede verificar su situación

**Búsqueda por placa:**
- Ciudadano consulta adeudos de su vehículo
- Usuario busca por número de placa
- Sistema muestra folios de infracciones en apremio
- Ciudadano conoce total adeudado

**Auditoría de cuenta específica:**
- Auditor investiga cuenta con observaciones
- Consulta por datos de la cuenta
- Verifica todos los folios generados históricamente
- Analiza patrón de morosidad

## Usuarios del Sistema
- Personal de atención al público
- Ventanilla de cobranza
- Supervisores de apremios
- Personal de auditoría
- Ejecutores fiscales

## Relaciones con Otros Módulos
- **Individual.pas**: Abre detalle completo del folio seleccionado
- **Listados.pas**: Puede generar reportes de la consulta
- **Facturacion.pas**: Puede iniciar proceso de cobro desde consulta
- **Individual_Folio.pas**: Consulta individual por número de folio
