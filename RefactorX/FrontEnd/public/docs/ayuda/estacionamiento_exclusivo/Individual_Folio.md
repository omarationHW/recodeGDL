# Emisión Individual por Folio

## Propósito Administrativo
Consultar y reimprimir requerimientos de pago ya emitidos, permitiendo la generación de copias de folios existentes para reposición de documentos extraviados o para entrega adicional a contribuyentes.

## Funcionalidad Principal
Este módulo permite buscar folios de apremio previamente emitidos y generar nuevas impresiones del documento oficial, manteniendo intacta la información original del requerimiento de pago.

## Proceso de Negocio

### ¿Qué hace?
Busca folios de requerimiento ya emitidos y permite reimprimir el documento oficial con toda la información original, incluyendo adeudos, recargos, multas y gastos de ejecución tal como fueron calculados en la fecha de emisión.

### ¿Para qué sirve?
- Reimprimir folios extraviados o deteriorados
- Generar copias adicionales para el expediente
- Proporcionar copias a contribuyentes que lo soliciten
- Recuperar documentos para procesos legales
- Verificar información de folios emitidos
- Generar respaldo documental

### ¿Cómo lo hace?
1. El usuario ingresa el número de folio a buscar
2. Selecciona el tipo de aplicación (Mercados, Aseo, Estacionómetros, etc.)
3. Especifica la oficina recaudadora
4. El sistema busca el folio en la base de datos
5. Recupera toda la información original del requerimiento
6. Muestra los datos en pantalla para verificación
7. Permite imprimir el documento oficial con el formato original
8. Genera una copia fiel del requerimiento emitido

### ¿Qué necesita para funcionar?
- Número de folio válido y existente
- Usuario con permisos de consulta
- Folio previamente emitido en el sistema
- Datos del requerimiento completos y disponibles
- Formato de impresión configurado

## Datos y Tablas

### Tabla Principal
- **ta_15_apremios**: Contiene todos los folios de requerimientos emitidos

### Tablas Relacionadas
- **ta_11_locales**: Datos de locales en mercados
- **ta_16_contratos_aseo**: Contratos de aseo contratado
- **dbestacion::pubmain**: Estacionamientos públicos
- **dbestacion::ex_contrato**: Estacionamientos exclusivos
- **ta_14_infracciones_placas**: Infracciones de estacionómetros
- **ta_13_cementerios**: Contratos de cementerios
- **ta_14_recaudadoras**: Información de oficinas recaudadoras
- **ta_15_claves**: Catálogos de tipos de diligencia y estados

### Stored Procedures (SP)
No utiliza stored procedures. Realiza consultas SQL directas.

### Tablas que Afecta
Este módulo es de solo consulta. No modifica ninguna tabla.

## Impacto y Repercusiones

### Repercusiones Operativas
- Facilita la recuperación de documentos extraviados
- Agiliza la atención a solicitudes de contribuyentes
- Permite integración completa de expedientes
- Apoya procesos legales y administrativos

### Repercusiones Financieras
- No tiene impacto financiero directo
- Apoya la documentación de adeudos en cobro
- Facilita auditorías y revisiones contables
- Proporciona evidencia para procesos de cobro

### Repercusiones Administrativas
- Garantiza disponibilidad de documentos oficiales
- Facilita cumplimiento de obligaciones de transparencia
- Apoya procesos de archivo y resguardo documental
- Permite atención eficiente a solicitudes de información

## Validaciones y Controles
- Valida que el folio exista en la base de datos
- Verifica que el folio pertenezca a la oficina recaudadora correcta
- Confirma que el usuario tenga permisos de consulta
- Valida que el módulo seleccionado corresponda al folio
- Asegura la integridad de los datos a imprimir

## Casos de Uso
1. **Contribuyente**: Solicita copia de su requerimiento de pago por extravío
2. **Ejecutor Fiscal**: Necesita reimprimir folio para segunda notificación
3. **Abogado**: Requiere copia del requerimiento para proceso legal
4. **Auditor**: Solicita copias de folios para revisión
5. **Personal Administrativo**: Genera copias para integrar expediente físico

## Usuarios del Sistema
- Personal de ventanilla
- Ejecutores fiscales
- Notificadores
- Supervisores de cobro
- Personal administrativo
- Coordinadores de área

## Relaciones con Otros Módulos
- **Individual**: Emisión original de los folios
- **CMultEmision**: Emisión masiva de folios
- **ConsultaReg**: Consulta detallada de registros
- **Cons_his**: Consulta del historial del folio
- **Notificaciones**: Registro de entregas del documento
