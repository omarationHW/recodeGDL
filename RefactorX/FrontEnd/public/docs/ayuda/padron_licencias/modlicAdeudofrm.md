# Modificacion de Adeudos de Licencia

## Descripcion General

### Que hace este modulo
El modulo de Modificacion de Adeudos permite al personal autorizado agregar, modificar o eliminar registros de adeudos manuales asociados a licencias o anuncios. Estos adeudos son cargos adicionales que no se generan automaticamente por el sistema sino que requieren registro manual por situaciones especiales o extraordinarias.

### Para que sirve en el proceso administrativo
Este modulo sirve para:
- Registrar adeudos extraordinarios no contemplados en el calculo automatico
- Modificar montos de adeudos capturados previamente
- Eliminar adeudos que fueron registrados por error
- Llevar control de derechos, formas y recargos especiales
- Recalcular automaticamente el saldo total de la licencia
- Mantener actualizado el estado de cuenta del contribuyente
- Documentar cobros excepcionales o ajustes administrativos

### Quienes lo utilizan
- Personal de Recaudacion con autorizacion especial
- Supervisores que autorizan cargos extraordinarios
- Jefes de departamento que aprueban ajustes
- Personal de auditoria que corrige errores
- Contraloria para regularizaciones

## Proceso Administrativo

### Como funciona el proceso paso a paso

**Apertura del Modulo:**

1. El modulo se abre desde el contexto de una licencia o anuncio especifico
2. Sistema recibe como parametros:
   - label1.caption = id_licencia
   - label2.caption = id_anuncio
3. Se cargan automaticamente los adeudos existentes para ese id_licencia e id_anuncio
4. Usuario visualiza listado de adeudos actuales

**Agregar Nuevo Adeudo:**

1. Usuario presiona boton "Agregar"
2. Sistema habilita panel de captura (panel2)
3. Sistema deshabilita navegacion y otros botones
4. Sistema inicializa valores en cero:
   - Derechos = 0
   - Derechos2 = 0
   - Descuento derechos = 0
   - Descuento recargos = 0
   - Forma = 0
   - Descuento forma = 0

5. Usuario captura datos obligatorios:
   - **Año (axo):** Año fiscal del adeudo
   - **Derechos:** Monto principal del adeudo
   - **Derechos2:** Concepto secundario (si aplica)
   - **Recargos:** Monto de recargos
   - **Forma:** Costo de formatos o papeleria

6. Usuario puede capturar descuentos (opcional):
   - Descuento en derechos
   - Descuento en recargos
   - Descuento en forma

7. Usuario presiona "Aceptar"
8. Sistema valida que el año no sea cero
9. Sistema calcula saldo = forma + derechos + derechos2 + recargos
10. Sistema guarda registro en base de datos
11. Sistema ejecuta SP para recalcular saldos totales (calcsl)
12. Sistema refresca listado de adeudos

**Modificar Adeudo Existente:**

1. Usuario selecciona adeudo del listado
2. Usuario presiona boton "Modificar"
3. Sistema habilita panel de captura con datos actuales
4. Usuario modifica los valores necesarios
5. Usuario presiona "Aceptar"
6. Sistema recalcula saldo del registro
7. Sistema guarda cambios
8. Sistema ejecuta SP para recalcular saldos totales
9. Sistema refresca listado

**Eliminar Adeudo:**

1. Usuario selecciona adeudo del listado
2. Usuario presiona boton "Eliminar"
3. Sistema muestra confirmacion: "¿Seguro(a) que Desea Eliminar el Adeudo?"
4. Si usuario confirma:
   - Sistema elimina el registro de la base de datos
   - Sistema ejecuta SP para recalcular saldos totales
   - Sistema refresca listado
5. Si usuario cancela:
   - No se realizan cambios

**Cancelar Operacion:**

1. Durante captura o modificacion, usuario puede presionar "Cancelar"
2. Sistema descarta cambios no guardados
3. Sistema regresa a modo consulta

### Que informacion requiere el usuario

**Datos Obligatorios:**
- **Año (axo):** Año fiscal del adeudo (validado != 0)
- **ID Licencia:** Viene del modulo padre
- **ID Anuncio:** Viene del modulo padre

**Datos Opcionales:**
- **Derechos:** Monto principal
- **Derechos2:** Segundo concepto de derechos
- **Recargos:** Monto de recargos
- **Forma:** Costo de formato
- **Descuento Derechos:** Descuento aplicado a derechos
- **Descuento Recargos:** Descuento aplicado a recargos
- **Descuento Forma:** Descuento en formato
- **Clave de Pago (cvepago):** Se inicializa en 0

### Que validaciones se realizan

1. **Validacion de Año:**
   - Sistema verifica que axo no sea 0
   - Si es 0, muestra mensaje: "Capture el año"
   - No permite guardar sin año valido

2. **Calculo Automatico de Saldo:**
   - Antes de guardar (BeforePost)
   - Formula: Saldo = forma + derechos + derechos2 + recargos
   - Se ejecuta automaticamente

3. **Inicializacion de IDs:**
   - Al insertar nuevo registro (AfterInsert)
   - Asigna automaticamente:
     - id_licencia = valor del label1
     - id_anuncio = valor del label2
     - cvepago = 0
     - recargos = 0

4. **Recalculo de Saldos Generales:**
   - Despues de cada operacion exitosa
   - Ejecuta SP calcsl con id_licencia
   - Actualiza tabla saldoslic con totales consolidados

5. **Confirmacion de Eliminacion:**
   - Requiere confirmacion explicita del usuario
   - Previene eliminaciones accidentales

### Que documentos genera
- **Ninguno directamente**
- Este modulo modifica datos que luego se reflejan en:
  - Estados de cuenta
  - Recibos de pago
  - Reportes de adeudos
  - Cierres de caja

## Tablas de Base de Datos

### Tabla Principal
- **adeudos_lic (query1):** Tabla que almacena adeudos manuales por licencia/anuncio, con desglose de derechos, recargos, formas y descuentos

### Tablas Relacionadas

**Tablas que Consulta:**
- **adeudos_lic:** Para mostrar listado de adeudos existentes
- **saldoslic:** Para obtener totales consolidados (via SP)

**Tablas que Modifica:**
- **adeudos_lic:**
  - INSERT al agregar nuevo adeudo
  - UPDATE al modificar adeudo existente
  - DELETE al eliminar adeudo
- **saldoslic:** Modificada indirectamente via SP calcsl

## Stored Procedures

- **calcsl (calcular saldos de licencia):**
  - Parametro: id_licencia
  - Proposito: Recalcular totales consolidados de adeudos
  - Se ejecuta despues de cada operacion (agregar, modificar, eliminar)
  - Actualiza tabla saldoslic con sumas de:
    - Total de derechos
    - Total de formas
    - Total de recargos
    - Total de anuncios
    - Saldo total
  - Consolida adeudos manuales + adeudos automaticos

## Impacto y Repercusiones

### Que registros afecta

**Al Agregar Adeudo:**
- Inserta nuevo registro en adeudos_lic
- Actualiza saldoslic (via SP) incrementando totales
- El contribuyente ve aumento en su adeudo

**Al Modificar Adeudo:**
- Actualiza registro existente en adeudos_lic
- Recalcula saldoslic reflejando nuevo monto
- El estado de cuenta se actualiza

**Al Eliminar Adeudo:**
- Elimina registro de adeudos_lic
- Recalcula saldoslic disminuyendo totales
- El adeudo del contribuyente se reduce

### Que cambios de estado provoca

1. **Estado de Cuenta:**
   - Cualquier operacion modifica el saldo del contribuyente
   - Afecta monto a pagar en proxima transaccion

2. **Disponibilidad de Documentos:**
   - Si se agrega adeudo, licencia puede quedar con saldo pendiente
   - Puede bloquear emision de documentos o tramites

3. **Recalculo Automatico:**
   - SP calcsl actualiza totales en cascada
   - Garantiza consistencia en todo el sistema

### Que documentos/reportes genera
- No genera documentos directamente
- Los cambios se reflejan en:
  - Estados de cuenta generados por otros modulos
  - Recibos de pago
  - Reportes de cartera

### Que validaciones de negocio aplica

1. **Año Fiscal Obligatorio:**
   - Todo adeudo debe asociarse a un año
   - Permite analisis historico y por ejercicio fiscal

2. **Integridad de IDs:**
   - Adeudo siempre ligado a licencia o anuncio especifico
   - No pueden existir adeudos "huerfanos"

3. **Recalculo Garantizado:**
   - Uso de try-except para manejar errores
   - Si falla SP, se captura excepcion
   - Evita inconsistencias en saldos

4. **Descuentos Permitidos:**
   - Sistema permite registrar descuentos por concepto
   - Flexibilidad para casos especiales
   - Transparencia en aplicacion de descuentos

## Flujo de Trabajo

### Descripcion del flujo completo del proceso

**Caso de Uso: Cobro Extraordinario por Inspeccion**

```
1. CONTEXTO:
   a. Licencia requiere inspeccion extraordinaria
   b. Inspeccion tiene costo de $500.00
   c. Costo no esta en calculo automatico
   d. Requiere registro manual

2. ACCESO AL MODULO:
   e. Supervisor abre expediente de la licencia
   f. Desde modulo de licencias, accede a "Modificar Adeudos"
   g. Sistema abre frmmodlicAdeudo
   h. Sistema carga label1=id_licencia, label2=0 (no es anuncio)
   i. Sistema muestra adeudos actuales de la licencia

3. REGISTRO DEL ADEUDO:
   j. Supervisor presiona "Agregar"
   k. Sistema habilita panel de captura
   l. Supervisor captura:
      - Año: 2024
      - Derechos: 500.00
      - Concepto: Inspeccion extraordinaria (en observaciones)
      - Forma: 0
      - Recargos: 0
   m. Supervisor presiona "Aceptar"

4. PROCESAMIENTO:
   n. Sistema valida año != 0 (Ok)
   o. Sistema calcula saldo = 500.00
   p. Sistema guarda registro en adeudos_lic
   q. Sistema ejecuta calcsl(id_licencia)
   r. SP recalcula totales en saldoslic
   s. Sistema refresca listado

5. RESULTADO:
   t. Adeudo aparece en listado
   u. Saldo de licencia incremento en $500.00
   v. Contribuyente vera cargo en su proximo estado de cuenta
   w. Al pagar, este cargo se incluira en el recibo
```

**Caso de Uso: Correccion de Adeudo Erroneo**

```
1. DETECCION:
   a. Auditor detecta adeudo capturado por error
   b. Monto incorrecto o año equivocado
   c. Requiere eliminacion

2. ACCESO Y BUSQUEDA:
   d. Auditor abre modulo de modificacion de adeudos
   e. Sistema carga adeudos de la licencia
   f. Auditor localiza el registro erroneo en el grid

3. ELIMINACION:
   g. Auditor selecciona el registro
   h. Auditor presiona "Eliminar"
   i. Sistema muestra confirmacion
   j. Auditor confirma la eliminacion

4. PROCESAMIENTO:
   k. Sistema elimina registro de BD
   l. Sistema ejecuta calcsl para recalcular
   m. SP ajusta saldoslic restando el adeudo eliminado
   n. Sistema refresca listado

5. RESULTADO:
   o. Adeudo desaparece del listado
   p. Saldo de licencia se reduce
   q. Contribuyente ve correccion en estado de cuenta
   r. Se restaura consistencia de datos
```

## Notas Importantes

### Consideraciones especiales

1. **Uso Restringido:**
   - Este modulo debe usarse con precaucion
   - Requiere autorizacion de supervisor
   - Los cambios afectan directamente la cuenta del contribuyente

2. **Adeudos Manuales vs Automaticos:**
   - Sistema genera adeudos automaticamente (refrendos, etc.)
   - Este modulo es para casos EXTRAORDINARIOS
   - Ejemplos: inspecciones especiales, multas, ajustes administrativos

3. **Importancia del Año:**
   - Permite segregar adeudos por ejercicio fiscal
   - Facilita cierres contables
   - Esencial para reportes historicos

4. **Recalculo Automatico:**
   - Garantiza que saldoslic siempre este actualizado
   - Evita inconsistencias entre detalle y totales
   - Proceso transparente para el usuario

5. **Multiples Conceptos:**
   - Derechos: Concepto principal
   - Derechos2: Permite segundo concepto
   - Flexibilidad para casos complejos

### Restricciones

1. **Solo Licencias Existentes:**
   - No permite crear adeudos para licencias inexistentes
   - Validacion por llave foranea

2. **Sin Historial:**
   - No mantiene log de cambios en adeudos
   - Una vez modificado o eliminado, no hay registro anterior

3. **Año Obligatorio:**
   - No permite guardar sin especificar año
   - Año 0 se considera invalido

4. **Sin Flujo de Aprobacion:**
   - Los cambios son inmediatos
   - No hay proceso de revision o autorizacion integrado
   - La supervision debe ser externa al sistema

### Permisos necesarios

- **Acceso al Modulo:** Requiere permisos especiales
- **Agregar Adeudos:** Permisos de INSERT en adeudos_lic
- **Modificar Adeudos:** Permisos de UPDATE en adeudos_lic
- **Eliminar Adeudos:** Permisos de DELETE en adeudos_lic
- **Ejecutar SP:** Permisos de EXECUTE en calcsl
- **Actualizar Saldos:** Permisos de UPDATE en saldoslic (via SP)

### Integracion con otros modulos

**Modulos que invocan este modulo:**
- Modulo de Licencias (para gestionar adeudos de licencia)
- Modulo de Anuncios (para gestionar adeudos de anuncios)
- Modulo de Recaudacion (para revisar adeudos antes de pago)

**Modulos afectados por este modulo:**
- Estados de Cuenta: Reflejan adeudos capturados
- Recibos de Pago: Incluyen estos adeudos en total
- Reportes de Cartera: Consideran adeudos manuales
- Cierres de Caja: Se contabilizan en ingresos

### Importancia en el Control Financiero

- Permite flexibilidad para casos especiales
- Mantiene integridad de saldos
- Documenta cargos extraordinarios
- Facilita auditoria de movimientos especiales
- Herramienta para correccion de errores
