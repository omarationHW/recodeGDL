# Módulo de Pagos con Tarjeta (Adquira/Pinpad)

## Información General

**Archivo:** TestFrm.pas
**Módulo:** Estacionamientos Públicos - Pagos Electrónicos
**Propósito:** Procesamiento de pagos con tarjetas de crédito/débito mediante terminal Pinpad y plataforma Adquira

---

## ¿Qué hace este módulo?

Este módulo especializado permite **procesar pagos electrónicos** utilizando tarjetas de crédito o débito a través de un dispositivo Pinpad conectado al sistema. Se integra con la plataforma de pagos **Adquira** para autorizar y confirmar transacciones en tiempo real.

---

## ¿Para qué sirve?

### Funciones Principales

1. **Lectura de Tarjetas desde Pinpad**
   - Captura datos de la tarjeta desde dispositivo físico
   - Obtiene nombre del tarjetahabiente
   - Lee fecha de vencimiento (mes/año)
   - Captura número de tarjeta encriptado
   - Obtiene Track2 encriptado para mayor seguridad

2. **Procesamiento de Pagos**
   - Envía transacción a plataforma Adquira
   - Autoriza el cargo con el banco emisor
   - Recibe confirmación o rechazo
   - Procesa respuesta en formato XML

3. **Impresión de Comprobantes**
   - Genera recibo para el cliente (copia cliente)
   - Genera voucher para el establecimiento (copia establecimiento)
   - Incluye todos los datos de la transacción
   - Formato oficial con datos fiscales

4. **Registro Contable**
   - Afecta tablas de movimientos de ingresos
   - Vincula pago con operación de caja
   - Registra en base de datos Adquira
   - Genera trazabilidad completa

5. **Soporte para Meses Sin Intereses**
   - Permite pagos diferidos a 3 o 6 meses
   - Valida montos mínimos según plazo
   - Requiere autorización especial
   - Solo con bancos participantes

---

## ¿Cómo funciona?

### Flujo Operativo Completo

```
1. INICIALIZACIÓN
   ↓
   - Se genera número de transmisión único
   - Se prepara estructura de datos
   - Se consulta catálogo de bancos
   ↓
2. CONFIGURACIÓN
   ↓
   - Usuario selecciona banco emisor
   - Define tipo de tarjeta (Visa/MasterCard)
   - Indica crédito o débito
   - Configura meses sin intereses (si aplica)
   ↓
3. VALIDACIÓN PREVIA
   ↓
   - Verifica código de seguridad (CCV2)
   - Valida banco seleccionado
   - Confirma tipo de tarjeta
   - Verifica compatibilidad MSI/Banco
   ↓
4. LECTURA DE TARJETA
   ↓
   - Conecta con Pinpad
   - Lee datos de la banda magnética/chip
   - Captura información del tarjetahabiente
   - Encripta datos sensibles
   ↓
5. PREPARACIÓN DE TRANSACCIÓN
   ↓
   - Genera digest de seguridad
   - Encripta datos según protocolo
   - Prepara estructura XML para envío
   ↓
6. ENVÍO A ADQUIRA
   ↓
   - Transmite datos encriptados
   - Espera respuesta del autorizador
   - Recibe resultado en XML
   ↓
7. PROCESAMIENTO DE RESPUESTA
   ↓
   - Parsea XML de respuesta
   - Extrae datos de autorización
   - Valida resultado (aprobado/rechazado)
   ↓
8. AFECTACIÓN CONTABLE (si aprobado)
   ↓
   - Inicia transacción en base de datos
   - Registra en tabla de Adquira
   - Vincula con operación
   - Confirma cambios (commit)
   ↓
9. IMPRESIÓN
   ↓
   - Genera comprobante duplicado
   - Imprime recibo cliente
   - Imprime voucher establecimiento
   ↓
10. FINALIZACIÓN
   ↓
   - Deshabilita botones de pago
   - Limpia formulario
   - Retorna a forma de pago principal
```

### Validaciones del Sistema

#### Antes de Leer Pinpad

1. **Código de Seguridad (CCV2)**
   - Campo obligatorio
   - Debe ser numérico
   - 3 o 4 dígitos según tipo de tarjeta

2. **Banco Emisor**
   - Debe seleccionarse del catálogo
   - Valida para el tipo de transacción

3. **Tipo de Tarjeta**
   - 1 = Visa
   - 2 = MasterCard
   - Obligatorio antes de lectura

4. **Tipo de Pago**
   - Crédito o Débito
   - Si es débito, no permite MSI

5. **Meses Sin Intereses**
   - Validación de banco participante:
     * Bancomer: Permite "Interés Libre"
     * Santander/HSBC: Permite "Otros Bancos"
   - Validación de montos:
     * 3 meses: Mínimo $300.00
     * 6 meses: Mínimo $500.00

6. **Periodo MSI**
   - Solo acepta 3 o 6 meses
   - Rechaza otros valores

#### Durante la Transacción

1. **Lectura Exitosa del Pinpad**
   - Mensaje debe ser "LECTURA EXITOSA"
   - Solo entonces se habilita botón de pago

2. **Generación de Digest**
   - Concatena: Transmisión + Referencia + Importe + CCV2
   - Se encripta con algoritmo hash

3. **Encriptación de Datos Sensibles**
   - Número de tarjeta: `EncriptaR()`
   - Fecha vencimiento: `EncriptaR()`
   - CCV2: `EncriptaR()`
   - Digest: `EncriptaH()`

#### Después de la Transacción

1. **Análisis de Respuesta XML**
   - Si hay error: Muestra mensaje y no procesa
   - Si es exitoso: Extrae datos de autorización
   - Si resultado = 0: Pago aprobado
   - Si resultado = 1: Pago rechazado

2. **Afectación Solo Si Aprobado**
   - Inicia transacción de BD
   - Si falla algún paso: Rollback
   - Si todo OK: Commit

---

## ¿Qué necesita para funcionar?

### Hardware Requerido

1. **Terminal Pinpad**
   - Dispositivo conectado al equipo
   - Puerto configurado correctamente
   - Drivers instalados
   - Comunicación activa

2. **Impresora**
   - Para generar comprobantes
   - Configurada en sistema

### Software/Componentes

1. **Librería Adquira32**
   - DLL `Adquira32.dll`
   - Funciones:
     * `LeerPinpad()` - Lee tarjeta
     * `EnviarTransaccion()` - Procesa pago
     * `EncriptaR()` - Encripta con clave R
     * `EncriptaH()` - Encripta con hash
     * `ValidoHasta()` - Formatea fecha vencimiento

2. **Conexión a Internet**
   - Para comunicación con Adquira
   - Puerto específico habilitado
   - Firewall configurado

### Datos de Entrada

#### Datos Automáticos del Sistema

- **Número de Transmisión:** Generado por SP
- **Referencia:** Según tipo de servicio
  * Estacionamientos: Folio específico
  * Predial: "Acumgdl" + caja + rango operaciones
- **Importe:** Calculado por el sistema según adeudos
- **ID Recaudadora:** Del usuario conectado
- **Caja:** De la sesión actual
- **Usuario:** ID del usuario operador
- **Servicio:**
  * 2 = Predial
  * 9 = Multas
  * Otros según catálogo

#### Datos Capturados por Usuario

- **Banco emisor:** Selección de combo
- **Tipo de tarjeta:** Visa (1) o MasterCard (2)
- **Crédito/Débito:** Radiob buttons
- **CCV2:** Código de seguridad (captura manual)
- **Meses sin intereses:** Si aplica (0, 3 o 6)
- **Email:** Opcional
- **Teléfono:** Opcional

#### Datos Leídos del Pinpad

- **Nombre del tarjetahabiente**
- **Número de tarjeta** (encriptado)
- **Mes y año de vencimiento**
- **Track2** (banda magnética encriptada)
- **Resultado de lectura**
- **Mensaje de estatus**

### Parámetros de Configuración

```pascal
// Fijos en el sistema
edtEmailAdmin.Text := 'jmezag@guadalajara.gob.mx'
edtIdCliente.Text := '10376'
edtMoneda.Text := '0'  // 0=Pesos, 1=Dólares
edtNegocio.Text := [ID_Recaudadora]
edtCobro.Text := '1'  // Tipo de cobro fijo
edtAccion.Text := 'PAGO'
```

---

## ¿Qué tablas utiliza?

### Tablas Principales

#### Tabla de Transacciones Adquira

**Tabla:** No se especifica nombre explícito, se infiere como `adquira_transacciones` o similar

**Campos utilizados:**
- `p_transm` - Número de transmisión (único por transacción)
- `p_ref` - Referencia del pago
- `p_fecha` - Fecha/hora de la operación
- `p_idrec` - ID de recaudadora
- `p_caja` - Caja que procesó
- `p_operacion` - Número de operación (0 en registro inicial)
- `p_importe` - Monto de la transacción
- `p_estado` - Estado ('V'=Vigente)
- `p_usu` - Usuario que operó

**Datos de Tarjeta:**
- `p_nombret` - Nombre del tarjetahabiente
- `p_numtarjeta` - Número de tarjeta
- `p_axot` - Año de vencimiento
- `p_mest` - Mes de vencimiento
- `p_tiptarjeta` - Tipo (1=Visa, 2=MC)
- `p_idbanco` - ID del banco emisor
- `p_codigoseg` - Código CCV2
- `p_tarjcredeb` - Crédito(2) o Débito(3)

**Datos Técnicos:**
- `p_track2` - Track2 encriptado
- `p_digest` - Hash de seguridad
- `p_mesessint` - Tipo de MSI
- `p_periodosint` - Periodo (3 o 6 meses)
- `p_moneda` - Tipo de moneda
- `p_tipopago` - Tipo de pago
- `p_servicio` - Tipo de servicio
- `p_accion` - Acción realizada

**Control:**
- `p_emailadm` - Email administrativo
- `p_idcliente` - ID de cliente Adquira
- `p_telefono` - Teléfono opcional
- `p_email` - Email opcional
- `p_idnegocio` - ID negocio
- `p_movimiento` - Tipo: 'I'=Inicial, 'P'=Procesado

### Tablas de Catálogos

**`cat_bancos`** o similar
- `id_banco` - ID único del banco
- `nombre` - Nombre del banco
- `sucursal` - Sucursal

---

## ¿Qué procedimientos almacenados consume?

### Procedimiento Principal

**`StprcAdquira`** - Stored Procedure para registro de transacciones Adquira

**Parámetros de Entrada:** (41 parámetros)

```sql
StprcAdquira(
    @p_transm INT,
    @p_ref VARCHAR,
    @p_fecha DATETIME,
    @p_idrec INT,
    @p_caja VARCHAR,
    @p_operacion INT,
    @p_importe CURRENCY,
    @p_estado CHAR(1),
    @p_usu INT,
    @p_emailadm VARCHAR,
    @p_idcliente INT,
    @p_telefono VARCHAR,
    @p_email VARCHAR,
    @p_tiptarjeta SMALLINT,
    @p_idbanco INT,
    @p_codigoseg SMALLINT,
    @p_tarjcredeb SMALLINT,
    @p_mesessint SMALLINT,
    @p_periodosint SMALLINT,
    @p_digest VARCHAR,
    @p_moneda SMALLINT,
    @p_idnegocio SMALLINT,
    @p_tipopago SMALLINT,
    @p_servicio SMALLINT,
    @p_track2 VARCHAR,
    @p_accion VARCHAR,
    @p_nombret VARCHAR,
    @p_axot SMALLINT,
    @p_mest SMALLINT,
    @p_numtarjeta VARCHAR,
    @p_movimiento CHAR(1)
)
```

**Funcionalidad según p_movimiento:**
- **'I'** (Inicial): Genera número de transmisión nuevo, retorna en campo `expression`
- **'P'** (Procesado): Actualiza registro con datos completos de la transacción autorizada

**Retorna:**
- Campo `expression` con número de transmisión generado (en modo 'I')
- Código de resultado/error

---

## ¿Qué tablas afecta?

### Modificaciones Directas

1. **Tabla de Transacciones Adquira**
   - **INSERT**: En modo inicial (genera transmisión)
   - **UPDATE**: En modo procesado (completa datos tras autorización)

2. **Tablas de Ingresos** (indirecta, vía transacción)
   - Se afectan cuando el pago es aprobado
   - Se vincula operación con transacción Adquira

### Operaciones en Transacción

```pascal
// Inicia transacción
DMGral.DBingresos.StartTransaction;

try
  // Ejecuta SP de afectación
  DMGral.StprcAdquira.Open;

  // Si todo OK
  DMGral.DBingresos.Commit;
except
  // Si falla algo
  DMGral.DBingresos.Rollback;
  ShowMessage('Error al Afectar adquira recibo');
end;
```

---

## Repercusiones en el Sistema

### Impacto Financiero

1. **Registro de Ingreso**
   - Se genera ingreso real en recaudadora
   - Se vincula con operación de caja
   - Afecta reportes de recaudación diaria

2. **Aplicación de Pago**
   - Liquida adeudos específicos
   - Actualiza saldos del contribuyente
   - Genera recibo oficial

3. **Conciliación Bancaria**
   - Los pagos quedan pendientes de conciliar
   - Se comparan con depositos bancarios
   - Plataforma Adquira envía archivo de liquidación

### Impacto Operativo

1. **Comprobantes Fiscales**
   - Se generan automáticamente
   - Incluyen todos los datos fiscales
   - Son válidos para deducción

2. **Auditoría**
   - Cada transacción queda completamente trazada
   - Se registra usuario, fecha, hora
   - Se almacenan datos de autorización bancaria

3. **Seguridad**
   - Datos sensibles van encriptados
   - No se almacenan números completos de tarjeta
   - Cumple con PCI-DSS

### Riesgos y Controles

#### Riesgos Identificados

1. **Transacciones Duplicadas**
   - Control: Número de transmisión único
   - Control: Validación de operación ya procesada

2. **Fraude con Tarjeta**
   - Control: CCV2 obligatorio
   - Control: Validación en línea con banco
   - Control: Track2 encriptado

3. **Errores de Comunicación**
   - Control: Try-Catch en afectación
   - Control: Rollback automático si falla
   - Control: Mensaje claro al usuario

4. **Rechazo Posterior al Cobro**
   - Impacto: Usuario ve aprobado pero banco rechaza
   - Control: Validar resultado del XML
   - Control: Solo afectar BD si resultado=0

#### Controles Implementados

✓ Validaciones pre-transacción
✓ Encriptación de datos sensibles
✓ Transaccionalidad en BD
✓ Auditoría completa
✓ Impresión de comprobantes duplicados
✓ Registro de autorizaciones bancarias

---

## Meses Sin Intereses (MSI)

### Configuraciones Disponibles

#### Tipo 1: Pago Único
- **Código:** `edtInteres.Text := '1'`
- **Periodo:** 0 meses
- **Aplica:** Todos los bancos, crédito y débito
- **Sin restricciones de monto**

#### Tipo 2: Interés Libre Bancomer
- **Código:** `edtInteres.Text := '2'`
- **Banco:** Solo Bancomer (id_banco = 16)
- **Periodos:** 3 o 6 meses
- **Monto mínimo:**
  * 3 meses: $300.00
  * 6 meses: $500.00
- **Solo crédito**

#### Tipo 3: Interés Libre Otros Bancos
- **Código:** `edtInteres.Text := '3'`
- **Bancos:** Santander (7) y HSBC (20)
- **Periodos:** 3 o 6 meses
- **Monto mínimo:**
  * 3 meses: $300.00
  * 6 meses: $500.00
- **Solo crédito**

### Autorización Especial

Para servicios distintos a Predial (servicio ≠ 2):
- Botón "Autorizar" visible
- Requiere contraseña especial
- Si autoriza: Habilita MSI
- Si no autoriza: Solo pago único

---

## Estructura de Datos XML

### XML de Solicitud (Enviado a Adquira)

```xml
<transaccion>
  <s_transm>[Número Transmisión]</s_transm>
  <c_referencia>[Referencia]</c_referencia>
  <val_1>[ID Negocio]</val_1>
  <t_servicio>[Tipo Servicio]</t_servicio>
  <c_cur>[Moneda]</c_cur>
  <t_importe>[Importe]</t_importe>
  <val_2>[Nombre Tarjetahabiente]</val_2>
  <val_3>[Número Tarjeta Encriptado]</val_3>
  <val_4>[Vencimiento Encriptado]</val_4>
  <val_5>[CCV2 Encriptado]</val_5>
  <val_6>[Digest Hash]</val_6>
  <val_11>[Email]</val_11>
  <val_12>[Teléfono]</val_12>
  <val_15>[ID Cliente]</val_15>
  <val_16>[Tipo Tarjeta]</val_16>
  <val_17>[Tipo Cobro]</val_17>
  <val_18>[Track2]</val_18>
  <val_19>[MSI Tipo]</val_19>
  <val_20>[MSI Periodo]</val_20>
  <val_21>[Email Admin]</val_21>
  <val_22>[Acción]</val_22>
</transaccion>
```

### XML de Respuesta (Recibido de Adquira)

#### Respuesta Exitosa

```xml
<respuesta operation="[Operación]">
  <datos>
    <campo key="s_transm" value="[Transmisión]"/>
    <campo key="c_referencia" value="[Referencia]"/>
    <campo key="val_1" value="[Negocio]"/>
    <campo key="t_servicio" value="[Servicio]"/>
    <campo key="t_importe" value="[Importe]"/>
    <campo key="t_pago" value="[Total Pagado]"/>
    <campo key="val_8" value="[Dato Adicional]"/>
    <campo key="val_10" value="[Dato Adicional]"/>
  </datos>
</respuesta>
```

#### Respuesta con Error

```xml
<respuesta>
  <error key="error" value="[Mensaje de Error]"/>
</respuesta>
```

---

## Formato de Comprobantes

### Datos Impresos

#### Encabezado
- ID Recaudadora + Nombre
- Caja + Usuario
- Fecha/Hora

#### Datos de Tarjeta
- Tipo (Visa/MasterCard)
- Últimos 4 dígitos (xxxxxxxxxxxx1234)
- Crédito o Débito
- Banco emisor
- Nombre del tarjetahabiente

#### Datos de Transacción
- Referencia de pago
- Número de transmisión
- Importe total
- Autorización bancaria

#### Datos Adicionales (si aplica)
- Meses sin intereses
- Periodo (3 o 6 meses)

### Copias Generadas
1. **Copia Cliente** - Se entrega al contribuyente
2. **Copia Establecimiento** - Queda en archivo de caja

---

## Usuarios del Sistema

### Usuario de Caja (Operativo)
- Captura CCV2 del cliente
- Selecciona banco emisor
- Define tipo de tarjeta
- Opera el Pinpad
- Entrega comprobante al cliente

### Requisitos:
- Sesión activa en caja
- Permisos para cobro con tarjeta
- Capacitación en uso de Pinpad
- Conocimiento de tipos de MSI

### Usuario Supervisor (Administrativo)
- Autoriza meses sin intereses en casos especiales
- Proporciona contraseña de autorización
- Supervisa operaciones especiales

---

## Consideraciones Técnicas

### Encriptación

1. **Función EncriptaR()**
   - Encripta con clave simétrica R
   - Usada para datos de tarjeta
   - Número de tarjeta, vencimiento, CCV2

2. **Función EncriptaH()**
   - Genera hash unidireccional
   - Usada para digest de seguridad
   - No puede ser revertido

3. **Track2**
   - Ya viene encriptado del Pinpad
   - Se envía tal cual a Adquira
   - Contiene datos de banda magnética

### Formato de Fecha Vencimiento

```pascal
function ValidoHasta(Anio, Mes: String): String;
// Convierte:
// Año: "25", Mes: "12"
// A: "1225" (MMYY)
```

### Manejo de Errores

1. **Error en Lectura de Pinpad**
   - Mensaje específico del dispositivo
   - No habilita botón de pago
   - Permite reintentar

2. **Error en Transmisión**
   - Mensaje de la plataforma Adquira
   - Muestra en MessageDlg
   - No afecta BD

3. **Error en Afectación**
   - Rollback automático
   - Mensaje al usuario
   - Transacción quedó en Adquira pero no en BD local
   - Requiere investigación manual

---

## Variables Globales Utilizadas

```pascal
// Del módulo principal
vapl: String;           // Referencia de aplicación
vservicio: Integer;     // Tipo de servicio
tadq: Boolean;          // Indica si es pago acumulado
operI, operF: Integer;  // Rango de operaciones (acumulado)
totacum: Currency;      // Total acumulado
idbcotarj: Integer;     // ID banco seleccionado

// Variables de afectación
p_transm: Integer;
p_idcliente: Integer;
p_tiptarjeta: Integer;
p_idbanco: Integer;
p_codigoseg: Integer;
p_tarjcredeb: Integer;
p_mesessint: Integer;
p_periodosint: Integer;
p_moneda: Integer;
p_idnegocio: Integer;
p_tipopago: Integer;
p_axot: Integer;
p_mest: Integer;
p_emailadm: String;
p_telefono: String;
p_email: String;
p_digest: String;
p_track2: String;
p_accion: String;
p_nombret: String;
p_numtarjeta: String;
```

---

## Resumen Ejecutivo

Este módulo es fundamental para la **modernización del cobro** en las recaudadoras municipales. Permite aceptar pagos con tarjeta de forma segura, cumpliendo con estándares internacionales de seguridad (PCI-DSS).

**Beneficios Principales:**
- Facilita el pago a contribuyentes
- Reduce manejo de efectivo
- Agiliza la recaudación
- Genera comprobantes automáticos
- Trazabilidad completa
- Seguridad en transacciones

**Aspectos Críticos:**
- Requiere capacitación específica en Pinpad
- Validaciones estrictas antes de procesar
- Manejo adecuado de errores de comunicación
- Conciliación diaria obligatoria
- Respaldo de comprobantes

**Recomendaciones Operativas:**
- Verificar conexión del Pinpad antes de iniciar turno
- Validar comunicación con Adquira
- Realizar prueba de transacción al inicio del día
- Mantener papel suficiente en impresora
- Archivar comprobantes de forma ordenada
- Conciliar al cierre de caja
