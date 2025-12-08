# Gen_Individual - Generación Individual de Remesas

## Propósito Administrativo
Permite generar remesas al Estado de folios específicos seleccionados individualmente por placa, placa-folio o año-folio, en lugar de procesamiento masivo por fechas.

## Funcionalidad Principal
Búsqueda selectiva de folios del histórico, adición incremental a remesa, generación de archivo .txt para envío al Estado, registro en bitácora.

## Proceso de Negocio

### ¿Qué hace?
Permite buscar folios por diferentes criterios (placa, placa-folio, año-folio). Muestra folios del histórico. Permite adicionar folios a una remesa en construcción. Clasifica automáticamente como PN (pago normal) o C (cancelación) según código de movimiento. Busca información de recibo o Banorte según tipo de pago. Consolida en ta14_datos_mpio. Genera archivo .txt. Registra en bitácora tipo C.

### ¿Para qué sirve?
Procesar folios específicos que no entraron en remesas automáticas. Corregir omisiones en envíos previos. Atender solicitudes específicas del Estado. Generar remesas fuera del flujo normal.

### ¿Cómo lo hace?
Determina siguiente número de remesa (ayt_gdl_rNN). Usuario busca folios por criterio seleccionado. Sistema consulta ta14_folios_histo. Por cada folio: identifica tipo según codigo_movto, busca información de recibo (ta14_refrecibo) o Banorte (ta14_fol_banorte), graba en ta14_datos_mpio. Permite adicionar más folios incrementalmente. Al finalizar genera archivo .txt y registra en bitácora.

### ¿Qué necesita para funcionar?
- Folios en ta14_folios_histo
- Criterio de búsqueda válido
- Información de recibos o Banorte disponible

## Datos y Tablas

### Tabla Principal
- **ta14_folios_histo**: Fuente de folios
- **ta14_datos_mpio**: Destino de remesa

### Tablas Relacionadas
- **ta14_refrecibo**: Información de recibos
- **ta14_fol_banorte**: Pagos Banorte
- **ta14_bitacora**: Registro de remesas

### Stored Procedures (SP)
Ninguno. Usa consultas dinámicas.

### Tablas que Afecta
- **ta14_datos_mpio**: Insert de folios seleccionados
- **ta14_bitacora**: Insert de remesa generada

## Impacto y Repercusiones

### Repercusiones Operativas
Flexibiliza el proceso permitiendo remesas a medida.

### Repercusiones Financieras
Permite corregir omisiones que afectan conciliaciones.

### Repercusiones Administrativas
Facilita atención de solicitudes específicas del Estado.

## Validaciones y Controles
- Valida existencia de folios buscados
- Clasifica automáticamente tipo de folio
- Busca información complementaria (recibo/Banorte)
- Si no encuentra información complementaria, usa fecha de movimiento
- Controla consecutivo de remesas

## Casos de Uso
1. **Corrección de Omisión**: Folio no incluido en remesa automática
2. **Solicitud del Estado**: Estado solicita información de folios específicos
3. **Reproceso Selectivo**: Regenerar envío de folios con errores

## Usuarios del Sistema
- Supervisores
- Personal de conciliación con Estado
- Administradores del sistema

## Relaciones con Otros Módulos
- **Gen_ArcDiario**: Generación masiva diaria
- **Gen_ArcAltas**: Generación masiva de altas
- **ConsRemesas**: Consulta de remesas
- **sFrm_consulta_folios**: Consulta de folios
