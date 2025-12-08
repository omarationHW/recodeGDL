# Prepago de Licencias

## Descripcion General

### Que hace este modulo
El modulo de Prepago permite visualizar y calcular el monto total a pagar por una cuenta antes de realizar el pago efectivo. Muestra el desglose detallado de adeudos, recargos, descuentos y permite aplicar descuentos especiales como descuento de pronto pago. Es una herramienta de consulta previa al pago que ayuda al contribuyente a conocer su situacion financiera exacta.

### Para que sirve en el proceso administrativo
Este modulo sirve para:
- Consultar el monto total a pagar antes del pago efectivo
- Visualizar desglose detallado de adeudos por año y bimestre
- Aplicar descuentos de pronto pago automaticamente
- Calcular descuentos por cumplimiento en fechas limite
- Permitir liquidaciones parciales (pago hasta cierto periodo)
- Mostrar descuentos aplicables por multas segun dias transcurridos
- Verificar requerimientos pendientes de pago
- Informar al contribuyente el monto exacto antes de procesar pago

### Quienes lo utilizan
- Personal de caja que atiende contribuyentes
- Personal de ventanilla para informar montos
- Contribuyentes que consultan su adeudo
- Supervisores que autorizan descuentos
- Personal de recaudacion para calculo de ingresos

## Proceso Administrativo

### Como funciona el proceso paso a paso

**Apertura y Visualizacion Inicial:**

1. Modulo se abre desde el contexto de una cuenta especifica
2. Sistema realiza validaciones iniciales:
   - Verifica que cuenta no este cancelada
   - Verifica que cuenta no sea exenta
   - Si hay problemas, muestra mensaje y sale

3. Sistema calcula automaticamente:
   - Periodo de consulta (año actual hasta bimestre 6)
   - Carga saldos historicos desde 1900/1 hasta hoy
   - Consulta ultimo requerimiento de pronto pago
   - Calcula descuentos aplicables

4. Sistema muestra en pantalla:
   - **Query1:** Datos generales de la cuenta
   - **Query2:** Desglose por periodo (año/bimestre) de:
     - Valor fiscal
     - Tasa aplicable
     - Recargos virtuales
     - Impuestos facturados, virtuales y adeudados
     - Totales por periodo
   - **Query3:** Totales consolidados de:
     - Recargos por pagar
     - Impuesto por pagar
     - Multas
     - Gastos
     - Descuentos (tope y pronto pago)
     - Total general
   - **difdesctosQry:** Detalle de cada descuento aplicado

5. Panel de totales muestra:
   - Multa Total
   - Pago Total (suma de todos los conceptos)

**Consulta de Requerimiento:**

- Si existe requerimiento de pronto pago vigente:
  - Se muestra panel "Datos del Requerimiento"
  - Incluye:
    - Folio del requerimiento
    - Periodo que abarca (inicio y fin)
    - Total del requerimiento
    - Fecha de entrega
    - Dias transcurridos desde entrega
  - Sistema calcula descuento en multa automaticamente segun dias:
    - Consulta tabla c_descmul (descuentos por multa)
    - Aplica porcentaje segun rango de dias
    - Muestra MultaVir (multa virtual con descuento)

**Liquidacion Parcial:**

1. Usuario presiona boton "Liquidacion Parcial"
2. Sistema muestra dialogo para seleccionar:
   - Bimestre hasta el cual desea pagar (1-6)
   - Año hasta el cual desea pagar

3. Sistema valida:
   - Si es cuota minima, no permite pagar menos del año completo
   - Si paga hasta bimestre 6 del año actual y es antes de marzo:
     - Aplica descuento de pronto pago
   - Si paga menos de bimestre 6 en año actual antes de marzo:
     - Elimina descuento de pronto pago

4. Sistema recalcula:
   - Filtra Query2 y Query3 hasta el periodo seleccionado
   - Recalcula totales
   - Actualiza MultaTot y PagoTot

**Aplicacion de Descuentos:**

1. **Descuento de Pronto Pago (DPP):**
   - Se aplica si paga completo hasta bimestre 6 del año actual
   - Solo antes del tercer bimestre (antes de marzo)
   - Sistema ejecuta SP calc_dppSP o calc_descpredSP
   - Descuento se refleja en Query3

2. **Descuento por Dias de Requerimiento:**
   - Si existe requerimiento practicado
   - Sistema calcula dias habiles transcurridos (excluye dias no laborables)
   - Busca en c_descmul el porcentaje aplicable
   - Calcula MultaVir = Multa * (1 - porcentaje/100)
   - Actualiza total a pagar

**Visualizacion de Descuentos:**

- Usuario puede marcar checkbox "Mostrar Descuentos"
- Sistema muestra/oculta panel con detalle de descuentos
- Listado incluye:
  - Clave de descuento
  - Descripcion del descuento
  - Importe del descuento

### Que informacion requiere el usuario

**Datos de Entrada:**
- Cuenta catastral (viene del modulo padre)
- Para liquidacion parcial:
  - Bimestre hasta el cual pagar
  - Año hasta el cual pagar

**Informacion que se Muestra:**
- Nombre completo del contribuyente
- Domicilio fiscal
- Domicilio de ubicacion (si diferente)
- Ultimo comprobante de pago y año
- Desglose por periodo:
  - Año efectivo
  - Valor fiscal
  - Tasa aplicable
  - Año sobre el cual se calcula
  - Recargos virtuales
  - Impuesto facturado, virtual y adeudado
  - Total del periodo
  - Bimestre inicial y final
  - Periodos en texto (ej: "ENE-FEB")
- Totales consolidados:
  - Recargos por pagar
  - Impuesto por pagar
  - Multa y multa virtual
  - Gastos
  - Año tope de descuento
  - Descuentos en tope y pronto pago
  - Total general
- Multa total calculada
- Pago total calculado

### Que validaciones se realizan

1. **Validacion de Cuenta:**
   - Cuenta no cancelada (vigente != 'C')
   - Cuenta no exenta (exento != 'S')
   - Si falla, muestra mensaje y sale

2. **Validacion de Cuota Minima:**
   - Si cuenta tiene cuota minima
   - No permite pagar menos del año completo
   - Valida que bimestre seleccionado sea 6

3. **Validacion de Descuento Pronto Pago:**
   - Solo aplica si año actual
   - Solo aplica si hasta bimestre 6
   - Solo aplica antes del bimestre 3 (marzo)
   - Verifica ultimo descuento aplicado (999999)

4. **Calculo de Dias Habiles:**
   - Consulta tabla de dias no laborables
   - Resta dias no habiles del calculo
   - Aplica descuento correcto por dias transcurridos

5. **Recalculo Automatico:**
   - Al cambiar periodo de liquidacion
   - Sistema recalcula automaticamente totales
   - Actualiza SP de descuentos si corresponde

### Que documentos genera
- **Ninguno directamente**
- Es modulo de consulta previa
- Los documentos (recibos) se generan en modulo de Pagos
- La informacion aqui calculada se usa al momento del pago efectivo

## Tablas de Base de Datos

### Tabla Principal
- **convctaqry (cuenta de conversion):** Datos principales de la cuenta catastral

### Tablas Relacionadas

**Tablas que Consulta:**
- **convctaqry:** Datos de la cuenta
- **detsaldosQry:** Detalle de saldos por periodo
- **regpropQry:** Datos del propietario y exenciones
- **ultreqpredQry:** Ultimo requerimiento de pronto pago
- **tienereqQry:** Verifica si tiene requerimientos sin practicar
- **UltcvedesctoQry:** Ultimo descuento aplicado
- **nolaborQry:** Dias no laborables para calculo
- **c_descmulQry:** Tabla de descuentos por multa segun dias

**Tablas que Modifica:**
- **Ninguna directamente**
- Ejecuta SPs que pueden modificar tablas de descuentos

## Stored Procedures

- **calc_dppSP (calcular descuento pronto pago):**
  - Parametro: cvecuenta
  - Aplica descuento si paga hasta bimestre 6 del año actual
  - Solo antes del tercer bimestre

- **del_dppSP (eliminar descuento pronto pago):**
  - Parametro: cvecuenta
  - Elimina descuento si paga parcial antes de bimestre 6
  - Marca para recalculo posterior

- **calc_descpredSP (calcular descuento de predecesor):**
  - Parametro: cvecuenta
  - Calcula descuentos especiales de cuentas predecesoras

## Impacto y Repercusiones

### Que registros afecta

**En Modo Consulta:**
- No afecta registros
- Solo lee informacion

**Al Cambiar Periodo de Liquidacion:**
- Puede modificar tabla de descuentos (via SP)
- Marca cuenta para recalculo posterior si sale sin pagar
- Variable recalc_dpp controla si debe recalcular al cerrar

### Que cambios de estado provoca

1. **Aplicacion Temporal de Descuentos:**
   - Si usuario selecciona liquidacion parcial
   - Descuentos se calculan temporalmente
   - Si no paga, se revierten al cerrar (o al cambiar cuenta)

2. **Marca de Recalculo:**
   - Variable recalc_dpp indica si debe recalcular
   - Al destruir formulario o cambiar cuenta
   - Sistema ejecuta calc_dppSP si es necesario

### Que documentos/reportes genera
- No genera documentos
- Proporciona informacion para generar recibo en modulo de Pagos

### Que validaciones de negocio aplica

1. **Descuento Pronto Pago:**
   - Solo año actual
   - Solo hasta bimestre 6
   - Solo antes de marzo
   - Un descuento por ejercicio fiscal

2. **Descuento por Dias:**
   - Basado en dias habiles transcurridos
   - Porcentaje segun tabla c_descmul
   - Solo aplica si hay requerimiento vigente

3. **Cuota Minima:**
   - Algunas cuentas tienen obligacion de pagar año completo
   - No se permite liquidacion parcial

4. **Integridad de Calculos:**
   - Totales siempre consistentes
   - Recalculo automatico al cambiar parametros

## Flujo de Trabajo

### Descripcion del flujo completo del proceso

**Caso de Uso: Contribuyente Consulta Adeudo para Pagar Completo**

```
1. ACCESO:
   a. Contribuyente acude a caja
   b. Cajero abre expediente de la cuenta
   c. Cajero selecciona opcion "Prepago"
   d. Sistema abre modulo con cuenta cargada

2. VALIDACIONES INICIALES:
   e. Sistema verifica que cuenta no este cancelada (Ok)
   f. Sistema verifica que no sea exenta (Ok)
   g. Sistema carga saldos completos (hasta hoy)

3. VISUALIZACION:
   h. Cajero ve desglose por periodos en Query2
   i. Ve total consolidado en Query3
   j. Ve MultaTot y PagoTot
   k. Sistema detecta que es febrero (bimestre < 3)
   l. Sistema verifica si hay requerimiento
   m. Si hay requerimiento:
      - Calcula dias transcurridos
      - Aplica descuento en multa automaticamente
      - Actualiza MultaTot y PagoTot

4. INFORMACION AL CONTRIBUYENTE:
   n. Cajero informa monto total: $X,XXX.XX
   o. Explica que incluye descuento de pronto pago
   p. Explica descuento por pago oportuno de requerimiento
   q. Contribuyente decide pagar

5. CIERRE Y PAGO:
   r. Cajero cierra modulo de prepago
   s. Cajero procede a modulo de Pagos
   t. Procesa pago con montos ya calculados
```

**Caso de Uso: Liquidacion Parcial**

```
1. CONSULTA INICIAL:
   a. Contribuyente solo quiere pagar parte del adeudo
   b. Cajero abre prepago
   c. Sistema muestra adeudo completo

2. SELECCION DE PERIODO:
   d. Cajero presiona "Liquidacion Parcial"
   e. Sistema muestra dialogo con periodo actual
   f. Cajero/contribuyente seleccionan:
      - Año: 2024
      - Bimestre: 4 (hasta julio-agosto)
   g. Cajero presiona Aceptar en dialogo

3. PROCESAMIENTO:
   h. Sistema valida que no sea cuota minima (Ok)
   i. Sistema detecta que bimestre < 6 y mes < marzo
   j. Sistema ejecuta del_dppSP (elimina descuento pronto pago)
   k. Sistema marca recalc_dpp = True
   l. Sistema filtra Query2 y Query3 hasta 2024/4
   m. Sistema recalcula totales

4. VISUALIZACION ACTUALIZADA:
   n. Cajero ve nuevo total reducido
   o. Descuento pronto pago ya no aparece
   p. MultaTot y PagoTot reflejan solo hasta bimestre 4

5. INFORMACION Y DECISION:
   q. Cajero informa nuevo monto: $Y,YYY.YY
   r. Explica que perdio descuento pronto pago por pago parcial
   s. Contribuyente decide si continua o paga completo
   t. Si acepta, cajero procede a Pagos
   u. Si cancela, al cerrar prepago sistema recalcula descuento

6. RECALCULO AL CERRAR:
   v. Al destruir formulario (OnDestroy)
   w. Sistema detecta recalc_dpp = True
   x. Sistema ejecuta calc_dppSP para restaurar descuento
   y. Descuento queda disponible para proximo calculo
```

## Notas Importantes

### Consideraciones especiales

1. **Caracter Informativo:**
   - Este modulo NO procesa pagos
   - Solo calcula y muestra montos
   - Es preparatorio al pago efectivo

2. **Descuentos Temporales:**
   - Los descuentos se aplican/quitan dinamic amente
   - No son definitivos hasta el pago efectivo
   - Sistema maneja reversiones automaticas

3. **Importancia de Fechas:**
   - Descuento pronto pago solo primer trimestre
   - Calculo de dias critico para descuento multa
   - Bimestre actual afecta calculos

4. **Complejidad de Calculos:**
   - Multiples queries interrelacionados
   - SPs que se ejecutan condicionalmente
   - Variables de estado para control de flujo

5. **Cuenta Antecesora:**
   - Variable cvecuenta_ant guarda cuenta previa
   - Permite recalcular si se cambio de cuenta sin pagar

### Restricciones

1. **Cuentas Especiales:**
   - Canceladas: No permite consulta
   - Exentas: No permite consulta
   - Cuota minima: No permite parciales

2. **Periodo de Descuentos:**
   - Pronto pago: Solo primer trimestre
   - Descuento multa: Solo con requerimiento vigente

3. **Sin Modificacion Manual:**
   - Usuario no puede cambiar montos manualmente
   - Todo es calculado por el sistema

### Permisos necesarios

- Consulta de cuentas y saldos
- Ejecucion de SPs de descuentos
- Consulta de requerimientos
- Consulta de tablas de descuentos

### Integracion con otros modulos

**Modulos Relacionados:**
- **Modulo de Pagos:** Usa los calculos de prepago
- **Estados de Cuenta:** Informacion similar
- **Requerimientos:** Afecta descuentos

### Importancia en Atencion al Contribuyente

- Transparencia en montos a pagar
- Claridad en descuentos aplicables
- Facilita decision de pago completo o parcial
- Evita sorpresas al momento del pago
- Mejora experiencia del contribuyente
