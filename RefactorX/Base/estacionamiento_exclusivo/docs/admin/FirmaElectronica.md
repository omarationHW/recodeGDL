# Firma Electrónica

## Propósito Administrativo
Generar documentos oficiales de notificación con firma electrónica digital para requerimientos de pago, certificando la autenticidad y validez legal de las comunicaciones emitidas por la autoridad fiscal.

## Funcionalidad Principal
Este módulo genera cartas de invitación al pago y requerimientos con firma electrónica del funcionario autorizado, imprimiendo documentos oficiales que tienen plena validez legal para el procedimiento administrativo de ejecución.

## Proceso de Negocio

### ¿Qué hace?
Crea documentos oficiales de notificación con firma electrónica digital, imprimiendo cartas de invitación al pago dirigidas a contribuyentes con adeudos vencidos, respaldadas con el sello digital y firma del funcionario competente.

### ¿Para qué sirve?
- Formalizar legalmente las notificaciones de adeudo
- Certificar la autenticidad de los documentos oficiales
- Cumplir con requisitos legales de notificación
- Generar evidencia documental válida para el expediente
- Agilizar el proceso de notificación masiva
- Dar certeza jurídica a los actos de autoridad

### ¿Cómo lo hace?
1. El usuario selecciona el tipo de aplicación (Mercados, Aseo, Estacionómetros, Públicos, Exclusivos)
2. Define el rango de folios a notificar
3. Especifica el rango de fechas de emisión
4. El sistema consulta los folios vigentes sin practicar en ese rango
5. Obtiene los datos del contribuyente y del adeudo
6. Genera el documento oficial con el texto legal correspondiente
7. Incluye la firma electrónica del funcionario autorizado
8. Imprime las cartas de invitación en formato oficial

### ¿Qué necesita para funcionar?
- Usuario autorizado para emitir notificaciones
- Folios de apremios emitidos y vigentes
- Datos completos del contribuyente
- Información del adeudo actualizada
- Firma electrónica del funcionario competente
- Formato oficial de carta de invitación

## Datos y Tablas

### Tabla Principal
- **ta_15_apremios**: Registros de apremios a notificar

### Tablas Relacionadas
- **ta_11_locales**: Datos de locales en mercados
- **ta_11_adeudo_local**: Adeudos de locales en mercados
- **ta_16_contratos_aseo**: Contratos de aseo contratado
- **ta_16_adeudos_aseo**: Adeudos de aseo
- **dbestacion::pubmain**: Estacionamientos públicos
- **dbestacion::ex_contrato**: Estacionamientos exclusivos
- **ta_14_infracciones_placas**: Infracciones de estacionómetros
- **ta_14_recaudadoras**: Información de oficinas recaudadoras

### Stored Procedures (SP)
No utiliza stored procedures. Realiza consultas SQL dinámicas.

### Tablas que Afecta
Este módulo es de solo consulta para generar reportes. No modifica ninguna tabla.

## Impacto y Repercusiones

### Repercusiones Operativas
- Formaliza legalmente el inicio del procedimiento de cobro coactivo
- Agiliza la notificación masiva de adeudos
- Genera documentos con plena validez legal
- Facilita la gestión de expedientes administrativos

### Repercusiones Financieras
- Inicia formalmente el procedimiento de cobro
- Permite el cobro de gastos de ejecución
- Fundamenta legalmente el cobro coactivo
- Genera evidencia para auditorías

### Repercusiones Administrativas
- Cumple requisitos legales de notificación
- Genera documentos oficiales certificados
- Crea evidencia documental para expedientes
- Garantiza certeza jurídica en actos de autoridad

## Validaciones y Controles
- Valida que el folio inicial no sea mayor que el folio final
- Verifica que los folios estén vigentes
- Valida que los folios no hayan sido practicados
- Asegura que existan datos del contribuyente
- Controla el acceso por oficina recaudadora

## Casos de Uso
1. **Coordinador de Notificaciones**: Genera cartas de invitación masivas mensuales
2. **Notificador**: Imprime documentos oficiales para entrega a contribuyentes
3. **Ejecutor Fiscal**: Genera notificaciones formales previas al requerimiento de pago
4. **Supervisor Legal**: Verifica que las notificaciones cumplan requisitos legales

## Usuarios del Sistema
- Coordinadores de notificaciones
- Jefes de ejecutores fiscales
- Notificadores
- Personal administrativo autorizado
- Supervisores legales

## Relaciones con Otros Módulos
- **CMultEmision**: Los folios notificados fueron emitidos en este módulo
- **CartaInvitacion**: Módulo relacionado de generación de cartas
- **Notificaciones**: Registro del resultado de las notificaciones
- **Ejecutores**: Los documentos se asignan a ejecutores para entrega
