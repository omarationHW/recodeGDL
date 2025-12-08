# frmMetrometers - Integración con Sistema de Parquímetros

## Propósito Administrativo
Permite visualizar información de folios de infracciones generados por el sistema de parquímetros (Metrom eters), incluyendo fotos de las infracciones.

## Funcionalidad Principal
Consume web service SOAP para recuperar fotografías de infracciones desde el sistema central de parquímetros.

## Proceso de Negocio

### ¿Qué hace?
Consulta folios de infracciones de parquímetros. Recupera fotografías del folio desde servidor remoto mediante web service. Decodifica imágenes en formato Base64 MIME y las muestra.

### ¿Para qué sirve?
Permite al personal verificar visualmente las infracciones registradas por parquímetros. Soporta validación de casos controvertidos. Proporciona evidencia fotográfica.

### ¿Qué necesita para funcionar?
- Conectividad con servidor de parquímetros (http://208.89.215.254)
- Web service Metro activo
- Folios con fotos registradas

## Datos y Tablas

### Tabla Principal
- **Query1**: Consulta con información del folio (axo, folio, dirección, geoposición, marca, modelo, links de fotos, motivo, id medio)

### Web Services
- **MetroPort**: Servicio SOAP con operaciones:
  - foliocancelar: Cancelar folio
  - foliopagar: Registrar pago
  - foliofoto: Recuperar fotografía

## Impacto y Repercusiones

### Repercusiones Operativas
Facilita validación de infracciones antes de aplicar sanciones.

### Repercusiones Administrativas
Proporciona evidencia para casos legales o controversias.

## Casos de Uso
1. **Verificación de Infracción**: Personal verifica foto antes de confirmar multa
2. **Atención de Controversia**: Ciudadano disputa infracción, se revisan fotos

## Usuarios del Sistema
- Personal de validación de infracciones
- Supervisores
- Personal jurídico

## Relaciones con Otros Módulos
- **metro.pas**: Definición del web service
- Sistema externo de parquímetros (Metrometers)
