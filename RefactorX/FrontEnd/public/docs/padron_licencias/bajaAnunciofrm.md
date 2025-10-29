# BAJA DE ANUNCIO - Módulo de Cancelación de Anuncios Publicitarios

## ¿QUÉ ES?
El módulo **Baja de Anuncio** es una herramienta administrativa crítica que permite CANCELAR anuncios publicitarios previamente autorizados, gestionando automáticamente la cancelación de adeudos asociados y actualizando el estado financiero de la licencia matriz. Es un módulo con controles estrictos de seguridad y validaciones temporales.

## ¿PARA QUÉ SIRVE?

### Propósito Principal
Realizar el proceso formal y controlado de cancelación de anuncios publicitarios cuando:
- El contribuyente retira el anuncio publicitario
- El establecimiento cierra operaciones
- Se detecta un error en el registro del anuncio
- Existe una resolución administrativa de retiro
- El anuncio fue colocado sin autorización y debe regularizarse

### Funciones Clave
1. **Cancelación formal** del anuncio en el sistema
2. **Liberación automática** de adeudos pendientes
3. **Actualización financiera** de la licencia matriz
4. **Registro de documentación** oficial (año y folio de baja)
5. **Control de permisos** según usuario y periodo
6. **Trazabilidad completa** de la operación

### Usuarios del Sistema
1. **Personal de ventanilla**: Baja normal en periodo permitido (enero-abril)
2. **Supervisores de Catastro (dep. 30, nivel >1)**: Baja por error administrativo
3. **Personal autorizado especial (nivel 1, depto. 9)**: Baja excepcional fuera de periodo
4. **Coordinadores**: Validación y autorización de bajas

## ¿CÓMO FUNCIONA?

### Proceso Operativo Completo

#### 1. BÚSQUEDA Y VALIDACIÓN DEL ANUNCIO

**Paso 1: Ingreso del Número de Anuncio**
1. Usuario captura el número de anuncio en el campo correspondiente
2. Presiona ENTER para ejecutar la búsqueda
3. Sistema consulta la base de datos y valida:
   - ¿Existe el anuncio?
   - ¿Cuál es su estado actual (Vigente/Cancelado)?
   - ¿Tiene adeudos pendientes?
   - ¿Hay licencia de referencia?

**Validaciones Automáticas:**

**A) Anuncio NO Encontrado**
- Sistema no muestra datos
- Panel de adeudos permanece oculto
- Botón de baja deshabilitado
- Usuario debe verificar el número

**B) Anuncio YA Dado de Baja (vigente = 'B')**
- Sistema muestra mensaje: "El anuncio ya se encuentra dado de baja"
- Panel de adeudos oculto
- No permite procesar nuevamente

**C) Anuncio Vigente SIN Adeudos o en Periodo Permitido**
- Muestra todos los datos del anuncio
- Oculta panel de adeudos
- Habilita botón "Dar de baja"
- Solicita captura de año y folio

**D) Anuncio Vigente CON Adeudos FUERA de Periodo**
- Muestra panel de adeudos en color de advertencia
- Deshabilita botón de baja
- Detalla adeudos por año y monto
- Requiere autorización especial o esperar periodo permitido

#### 2. INFORMACIÓN MOSTRADA DEL ANUNCIO

**Datos de la Licencia de Referencia:**
- **Licencia ID**: Número de licencia matriz
- **Fecha de otorgamiento**: Cuándo se autorizó la licencia
- **Propietario**: Nombre completo del titular
- **Teléfono**: Contacto del propietario

**Datos del Anuncio:**
- **Medidas**: Dimensiones del anuncio (alto x ancho en metros)
- **Área**: Superficie total en metros cuadrados
- **Ubicación**: Calle donde está instalado
- **Numeración**: Exterior/interior con letras

**Datos Financieros (si aplica):**
- **Años con adeudo**: Lista de ejercicios fiscales pendientes
- **Saldo por año**: Monto adeudado por cada ejercicio

#### 3. PERIODO PERMITIDO PARA BAJA

**Regla General: ENERO a ABRIL**
- Meses permitidos: 01, 02, 03, 04
- Razón administrativa: Control presupuestal y cierre fiscal
- Permite bajas normales sin restricciones adicionales

**Fuera de Periodo (Mayo a Diciembre):**
- Requiere permisos especiales
- Solo si NO hay adeudos, o
- Si usuario tiene privilegio "Baja por error" o "Baja en tiempo"

#### 4. MODALIDADES ESPECIALES DE BAJA

**A) BAJA POR ERROR**
- **¿Quién puede?**: Usuarios con nivel > 1 Y dependencia = 30 (Catastro)
- **Cuándo usar**: Error administrativo en el registro del anuncio
- **Efecto**:
  - Omite validación de adeudos
  - Omite validación de periodo
  - Oculta panel de adeudos
  - Oculta captura de año/folio
  - Permite baja inmediata
- **Checkbox**: "Baja por error" (visible solo para usuarios autorizados)
- **Ejemplo de uso**: Anuncio capturado dos veces por error

**B) BAJA EN TIEMPO**
- **¿Quién puede?**: Usuarios con nivel = 1 Y departamento = 9
- **Cuándo usar**: Casos excepcionales fuera de periodo normal
- **Efecto**:
  - Omite validación de periodo
  - Omite validación de adeudos
  - Permite baja en cualquier mes
  - Oculta panel de adeudos
- **Checkbox**: "Baja en tiempo" (visible solo para usuarios autorizados)
- **Ejemplo de uso**: Resolución judicial de retiro inmediato

#### 5. CAPTURA DE DATOS OFICIALES

**Datos Requeridos (excepto bajas por error):**

**A) Año de Baja (axo_baja)**
- Año del documento oficial que autoriza la baja
- Formato: 4 dígitos (ej: 2024)
- Obligatorio para trazabilidad

**B) Folio de Baja (folio_baja)**
- Número de folio del documento oficial
- Referencia al acta administrativa o resolución
- Obligatorio para auditorías

**C) Especificaciones de Ubicación (espubic)**
- Campo opcional de texto libre
- Permite capturar detalles adicionales del lugar
- Ejemplos: "ESQUINA CON AVE JUÁREZ", "SEGUNDO PISO"
- Máximo 100 caracteres

**Validación de Captura:**
- Sistema valida que año y folio no estén vacíos
- Mensaje de error: "Debes indicar año y folio"
- No permite continuar sin estos datos

#### 6. EJECUCIÓN DE LA BAJA

**Confirmación del Usuario:**
- Sistema muestra mensaje: "A continuación se dará de baja el anuncio, ¿desea continuar?"
- Opciones: SÍ / NO
- Requiere confirmación explícita

**Proceso Interno (si usuario confirma SÍ):**

**PASO 1: Actualizar el Anuncio**
```
Tabla: anuncios
Registro: anuncio específico
Campos modificados:
- vigente: 'V' → 'C' (Cancelado)
- fecha_baja: NULL → fecha actual del sistema
- axo_baja: NULL → año capturado
- folio_baja: NULL → folio capturado
- espubic: → especificaciones capturadas
```

**PASO 2: Cancelar Adeudos del Anuncio**
```
Tabla: detsal_lic (detalle de saldos)
Filtro: id_anuncio = anuncio actual AND cvepago = 0
Proceso: Recorre TODOS los registros de adeudo
Para cada registro:
- cvepago: 0 → 999999 (código de cancelación)
- Efecto: El adeudo queda marcado como cancelado
```

**PASO 3: Recalcular Saldos de la Licencia**
```
Stored Procedure: calc_sdosl
Parámetro: id_licencia de la licencia matriz
Función: Recalcula todos los totales de la licencia
- Suma adeudos vigentes (excluyendo cancelados)
- Actualiza saldo total
- Actualiza tabla saldos_lic
```

**PASO 4: Deshabilitar Botón**
- Botón "Dar de baja" se deshabilita
- Previene doble ejecución accidental
- Usuario debe cerrar la ventana

#### 7. MANEJO DE ADEUDOS

**¿Qué son los Adeudos?**
- Cobros pendientes de ejercicios fiscales anteriores
- Pueden ser por derechos anuales del anuncio
- Se acumulan año con año si no se pagan

**Visualización de Adeudos:**
- Panel muestra: "EL ANUNCIO CUENTA CON ADEUDO, NO SE PODRÁ DAR DE BAJA"
- Cuadrícula con columnas:
  - Año: Ejercicio fiscal del adeudo
  - Saldo: Monto pendiente

**¿Por qué se Cancelan los Adeudos?**
- El anuncio ya no existe físicamente
- No se puede cobrar por un anuncio inexistente
- Marca administrativa: cvepago = 999999
- Permite identificar adeudos históricos cancelados

## ¿QUÉ NECESITA PARA FUNCIONAR?

### Datos de Entrada Obligatorios
1. **Número de anuncio**: Identificador único del anuncio a dar de baja
2. **Año de baja**: Año del documento oficial (excepto baja por error)
3. **Folio de baja**: Número de folio del documento (excepto baja por error)

### Datos Opcionales
1. **Especificaciones de ubicación**: Detalles adicionales del lugar
2. **Motivo de la baja**: Texto libre explicando la razón

### Información de Usuario Requerida
- **Nombre de usuario**: Para validar permisos
- **Nivel del usuario**: Determina privilegios
- **Dependencia**: Valida si es Catastro (30)
- **Departamento**: Valida permisos especiales (9)

## TABLAS DE BASE DE DATOS

### Tabla Principal

**anuncios**
- **Descripción**: Tabla maestra de anuncios publicitarios autorizados
- **Campos CONSULTADOS**:
  - anuncio: Número de anuncio (clave de búsqueda)
  - id_anuncio: Identificador interno
  - id_licencia: Referencia a la licencia matriz
  - vigente: Estado del anuncio ('V'=Vigente, 'C'=Cancelado, 'B'=Baja)
  - medidas1, medidas2: Dimensiones del anuncio
  - area_anuncio: Superficie en m²
  - ubicacion: Calle de instalación
  - numext_ubic, letraext_ubic, numint_ubic, letraint_ubic: Numeración
  - fecha_otorgamiento: Cuándo se autorizó

- **Campos MODIFICADOS**:
  - vigente: Se cambia de 'V' a 'C'
  - fecha_baja: Se registra la fecha actual
  - axo_baja: Se guarda el año del documento
  - folio_baja: Se guarda el folio del documento
  - espubic: Se actualizan especificaciones

### Tablas de Apoyo

**1. licencias**
- **Propósito**: Obtener información del propietario
- **Relación**: id_licencia del anuncio
- **Campos consultados**:
  - propietario, primer_ap, segundo_ap: Nombre completo
  - telefono_prop: Contacto del propietario
  - Campos calculados: propietarionvo (nombre completo concatenado)

**2. detsal_lic (Detalle de Saldos de Licencias)**
- **Propósito**: Adeudos pendientes del anuncio
- **Filtro**: id_anuncio = anuncio actual AND cvepago = 0
- **Campos consultados**:
  - axo: Año del adeudo
  - saldo: Monto pendiente
- **Campos MODIFICADOS**:
  - cvepago: 0 → 999999 (marca como cancelado)

**3. usuarios**
- **Propósito**: Validar permisos del usuario
- **Join con**: deptos
- **Campos consultados**:
  - nivel: Nivel jerárquico del usuario
  - cvedepto: Departamento al que pertenece
  - cvedependencia: Dependencia (vía join con deptos)

**4. deptos**
- **Propósito**: Obtener dependencia del usuario
- **Campos consultados**:
  - cvedepto: Clave del departamento
  - cvedependencia: Dependencia a la que pertenece

## STORED PROCEDURES (SP) QUE CONSUME

### calc_sdosl (Calcular Saldos de Licencia)

**Nombre completo**: calc_sdosl
**Base de datos**: DBCatastro2

**¿Qué hace?**
Recalcula TODOS los saldos de una licencia específica, sumando:
- Adeudos de la licencia directamente
- Adeudos de todos sus anuncios ligados
- Excluyendo adeudos cancelados (cvepago = 999999)

**Parámetros de entrada**:
- id_licencia (INTEGER): Identificador de la licencia a recalcular

**¿Cuándo se ejecuta?**
Inmediatamente después de:
1. Actualizar el anuncio a estado 'C'
2. Cancelar todos los adeudos del anuncio (cvepago = 999999)

**¿Por qué es necesario?**
- Al cancelar adeudos del anuncio, cambia el total de la licencia
- La tabla saldos_lic debe reflejar el nuevo total
- Otros módulos consultan saldos_lic para validaciones
- Mantiene consistencia de datos financieros

**Impacto en el sistema**:
- Actualiza tabla saldos_lic
- Los totales de la licencia disminuyen
- Afecta reportes financieros
- Impacta validaciones de tramites futuros

## TABLAS QUE AFECTA

### Modificaciones (UPDATE)

**1. anuncios** - 1 registro modificado
```
Registro afectado: WHERE anuncio = número ingresado
Campos actualizados:
- vigente = 'C'
- fecha_baja = SYSDATE
- axo_baja = [año capturado]
- folio_baja = [folio capturado]
- espubic = [especificaciones capturadas]
```

**2. detsal_lic** - Múltiples registros modificados
```
Registros afectados: WHERE id_anuncio = [id del anuncio] AND cvepago = 0
Puede ser 0 registros (sin adeudos) o varios (adeudos de múltiples años)
Campos actualizados:
- cvepago = 999999
```

**3. saldos_lic** (vía SP calc_sdosl) - 1 registro modificado indirectamente
```
Registro afectado: WHERE id_licencia = [licencia del anuncio]
Campos actualizados (calculados por el SP):
- derechos: Total de derechos pendientes
- anuncios: Total de cobro de anuncios
- recargos: Recargos acumulados
- gastos: Gastos de cobranza
- multas: Multas aplicadas
- formas: Costo de formas
- total: Suma de todos los conceptos
```

### NO Modifica (Solo Consulta)
- licencias: Solo lee información del propietario
- usuarios: Solo valida permisos
- deptos: Solo obtiene dependencia

## REPERCUSIONES OPERATIVAS

### Impacto Administrativo

**A) Estado del Anuncio**
- **Antes**: Vigente, genera cobros, aparece en reportes activos
- **Después**: Cancelado, NO genera cobros, aparece en históricos
- **Reversibilidad**: NO es reversible por este módulo
- **Consecuencia**: El anuncio NO puede reactivarse automáticamente

**B) Impacto Fiscal**
- **Adeudos cancelados**: Se pierden ingresos proyectados
- **Estimaciones de recaudación**: Deben ajustarse
- **Presupuesto**: Afecta cumplimiento de metas
- **Razón del periodo**: Bajas en enero-abril permiten ajustar presupuesto anual

**C) Licencia Matriz**
- **Saldos actualizados**: Totales de la licencia disminuyen
- **Validaciones futuras**: Puede permitir trámites antes bloqueados
- **Historial**: Queda registrado el anuncio dado de baja

### Impacto en Otros Módulos

**1. Módulo de Consulta de Anuncios**
- Anuncio aparecerá con estado "Cancelado"
- Muestra fecha de baja y documentación oficial

**2. Módulo de Cobro**
- NO genera recibos futuros para este anuncio
- Adeudos cancelados no aparecen en estados de cuenta

**3. Módulo de Estadísticas**
- Contabiliza como baja en el periodo
- Afecta indicadores de anuncios activos

**4. Módulo de Reportes**
- Anuncio sale de listados de vigentes
- Entra en reportes de bajas del periodo

### Restricciones Temporales - PERIODO PERMITIDO

**¿Por qué solo Enero a Abril?**
1. **Control presupuestal**: Permite ajustar ingresos al inicio del año fiscal
2. **Cierre fiscal**: Evita desajustes al cierre del ejercicio
3. **Planeación financiera**: Da certeza de ingresos proyectados
4. **Normatividad interna**: Políticas de la Dirección de Ingresos

**Excepciones documentadas:**
- Bajas por error: Corrección administrativa necesaria
- Bajas en tiempo: Situaciones excepcionales autorizadas
- Ambas requieren nivel jerárquico superior

### Validaciones de Seguridad

**1. Validación de Estado**
- NO permite dar de baja un anuncio ya cancelado
- Mensaje claro al usuario

**2. Validación de Adeudos**
- Fuera de periodo: Bloquea si hay adeudos
- Protege ingresos fuera de periodo permitido

**3. Validación de Permisos**
- Checkbox "Baja por error" solo visible para dep. 30, nivel >1
- Checkbox "Baja en tiempo" solo visible para nivel 1, depto. 9
- Controla quién puede omitir restricciones

**4. Validación de Datos**
- Año y folio obligatorios (excepto baja por error)
- Evita bajas sin documentación de respaldo

**5. Confirmación Explícita**
- Solicita confirmación antes de ejecutar
- Previene bajas accidentales

## FLUJO DE TRABAJO TÍPICO

### Escenario 1: Baja Normal en Periodo Permitido (Marzo)

**Contexto**: Contribuyente solicita baja de su anuncio en marzo, sin adeudos

1. **Recepción de Solicitud**
   - Contribuyente presenta solicitud por escrito
   - Ventanilla verifica que el anuncio fue retirado físicamente
   - Se genera documento oficial con folio

2. **Captura en Sistema**
   - Usuario abre módulo "Baja de Anuncio"
   - Captura número de anuncio: 123456
   - Presiona ENTER

3. **Validación del Sistema**
   - Sistema muestra datos del anuncio
   - Verifica: Vigente, sin adeudos, periodo marzo (permitido)
   - Habilita botón de baja
   - Muestra campos de año y folio

4. **Captura de Documentación**
   - Usuario captura año: 2024
   - Usuario captura folio: 1234
   - Opcionalmente agrega especificaciones: "ANUNCIO ESPECTACULAR AVE AMERICAS"

5. **Ejecución**
   - Usuario presiona "Dar de baja"
   - Confirma operación
   - Sistema ejecuta baja en segundos
   - Mensaje de éxito implícito (botón se deshabilita)

6. **Cierre**
   - Usuario entrega comprobante al contribuyente
   - Archiva documentación con número de folio
   - Cierra ventana

### Escenario 2: Intento de Baja Fuera de Periodo CON Adeudos (Julio)

**Contexto**: Contribuyente solicita baja en julio, tiene adeudos de 2 años

1. **Recepción de Solicitud**
   - Contribuyente presenta solicitud
   - Ventanilla verifica solicitud

2. **Captura en Sistema**
   - Usuario captura número de anuncio
   - Presiona ENTER

3. **Bloqueo del Sistema**
   - Sistema detecta: Julio (fuera de periodo), adeudos presentes
   - Muestra panel rojo: "EL ANUNCIO CUENTA CON ADEUDO, NO SE PODRÁ DAR DE BAJA"
   - Despliega cuadrícula con adeudos:
     * 2022: $1,500.00
     * 2023: $1,650.00
   - Deshabilita botón de baja

4. **Opciones para el Usuario**

   **Opción A**: Solicitar Pago de Adeudos
   - Informa al contribuyente que debe pagar adeudos
   - Genera estado de cuenta
   - Una vez pagado, puede procesar baja

   **Opción B**: Esperar Periodo Permitido
   - Informa que debe esperar hasta enero-abril
   - Agenda recordatorio

   **Opción C**: Solicitar Autorización Especial
   - Si hay justificación administrativa
   - Solicita a supervisor con permiso "Baja en tiempo"
   - Supervisor autoriza y procesa

### Escenario 3: Baja por Error Administrativo

**Contexto**: Anuncio capturado duplicado por error de captura

1. **Detección del Error**
   - Supervisor detecta anuncio duplicado
   - Verifica que es error de captura
   - Decide corregir

2. **Acceso con Privilegios**
   - Supervisor (dep. 30, nivel 3) abre módulo
   - Sistema muestra checkbox "Baja por error" (visible para él)

3. **Activación de Modo Error**
   - Marca checkbox "Baja por error"
   - Panel de adeudos se oculta automáticamente
   - Campos de año/folio se ocultan

4. **Ejecución Rápida**
   - Captura número de anuncio duplicado
   - Sistema muestra datos
   - Presiona "Dar de baja" (habilitado inmediatamente)
   - Confirma operación
   - Baja ejecutada sin solicitar año/folio

5. **Documentación**
   - Registra en bitácora interna la corrección
   - Notifica al área de sistemas si fue error sistémico

## CONSIDERACIONES IMPORTANTES

### Para Usuarios de Ventanilla
1. Verificar físicamente que el anuncio fue retirado antes de dar de baja
2. Solicitar siempre documento oficial con folio
3. Respetar el periodo permitido (enero-abril)
4. Si hay adeudos fuera de periodo, canalizar a cobro primero
5. Capturar especificaciones detalladas para futura referencia

### Para Supervisores
1. Usar "Baja por error" solo para correcciones administrativas reales
2. Documentar todas las bajas por error en bitácora
3. Validar que no se abuse del privilegio
4. Revisar periódicamente bajas ejecutadas

### Para Administradores
1. Monitorear uso de privilegios especiales
2. Generar reportes mensuales de bajas por modalidad
3. Validar impacto en recaudación proyectada
4. Auditar que se respeten periodos permitidos

### Datos Críticos NO Reversibles
- Una vez ejecutada la baja, NO se puede revertir por este módulo
- Requeriría intervención de base de datos directa
- Por eso la confirmación es crítica

### Integración con Auditorías
- Cada baja queda registrada con:
  - Fecha exacta de la operación
  - Usuario que ejecutó
  - Documento oficial de respaldo (año/folio)
- Permite rastreo completo para auditorías internas y externas
