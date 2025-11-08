# Módulo de Actualización de Estacionamientos Públicos

## Información General

**Archivo:** spubActualizacionfrm.pas
**Módulo:** Estacionamientos Públicos
**Propósito:** Gestión integral de estacionamientos públicos registrados en el sistema municipal

---

## ¿Qué hace este módulo?

Este módulo es el corazón del sistema de administración de estacionamientos públicos. Permite realizar **todas las operaciones administrativas** relacionadas con los estacionamientos registrados en el municipio, desde modificaciones de datos básicos hasta la aplicación de pagos y gestión de adeudos.

---

## ¿Para qué sirve?

### Funciones Principales

1. **Modificación de Datos de Estacionamientos**
   - Actualizar información general del estacionamiento
   - Cambiar datos de ubicación y contacto
   - Modificar vínculos con licencias y predios

2. **Gestión de Bajas**
   - Dar de baja estacionamientos
   - Registrar fecha y folio de cancelación
   - Cambiar estatus a "CANCELADO"

3. **Aplicación de Pagos**
   - Registrar pagos realizados por diversos conceptos
   - Aplicar pagos a adeudos específicos (año/mes)
   - Validar y confirmar operaciones de caja

4. **Gestión de Adeudos**
   - Visualizar adeudos pendientes por año y mes
   - Eliminar adeudos cuando corresponda
   - Consultar historial de recibos y pagos

5. **Incrementos y Decrementos de Cajones**
   - Modificar la capacidad (número de cajones)
   - Registrar oficios que autorizan cambios
   - Mantener historial de movimientos

6. **Cambio de Categoría**
   - Reclasificar estacionamientos según normativa
   - Actualizar categorías del padrón
   - Ajustar costos según nueva categoría

7. **Gestión de Multas Relacionadas**
   - Visualizar multas asociadas al estacionamiento
   - Dar mantenimiento a multas específicas
   - Vincular y desvincular infracciones

---

## ¿Cómo funciona?

### Flujo Operativo General

```
1. BÚSQUEDA → Usuario captura número de estacionamiento
              ↓
2. CONSULTA → Sistema recupera información completa
              ↓
3. VALIDACIÓN → Verifica estatus (VIGENTE/CANCELADO)
              ↓
4. PRESENTACIÓN → Muestra datos en pestañas organizadas
              ↓
5. MODIFICACIÓN → Usuario realiza cambios necesarios
              ↓
6. CONFIRMACIÓN → Sistema valida y guarda cambios
              ↓
7. REGISTRO → Se genera historial del movimiento
```

### Modos de Operación

El sistema opera en **5 modos diferentes** según la opción inicial:

#### Opción 1: Modificación de Estacionamientos
- Permite editar todos los datos del estacionamiento
- Requiere que el estacionamiento esté VIGENTE
- Valida cuenta predial asociada
- Actualiza licencia vinculada si existe

#### Opción 2: Baja de Estacionamientos
- Cambia estatus a CANCELADO
- Requiere folio de baja obligatorio
- Registra fecha de cancelación
- Deshabilita operaciones futuras

#### Opción 3: Aplicar Pagos por Diversos
- Para pagos realizados fuera del sistema normal
- Requiere datos de operación de caja
- Aplica pago a adeudo específico (año/mes)
- Genera confirmación de aplicación

#### Opción 4: Incrementos/Decrementos de Cajones
- Modifica cantidad de cajones del estacionamiento
- Requiere número de oficio que autoriza
- Registra fecha del movimiento
- Recalcula adeudos si aplica

#### Opción 5: Cambio de Categoría
- Permite reclasificar el estacionamiento
- Requiere oficio de autorización
- Actualiza categoría en el padrón
- Puede afectar costos futuros

---

## ¿Qué necesita para funcionar?

### Datos de Entrada Obligatorios

1. **Número de Estacionamiento** (campo clave)
   - Identificador único del establecimiento
   - Debe existir en el padrón

2. **Para Modificaciones:**
   - Cuenta predial válida y activa
   - Datos de ubicación (calle, número)
   - Información de contacto (teléfono)
   - Fechas (autorización, inicio, vencimiento)
   - Número de solicitud y control

3. **Para Aplicar Pagos:**
   - Año y mes del adeudo a pagar
   - Fecha de operación
   - Oficina recaudadora (id_rec)
   - Caja que realizó el cobro
   - Número de operación

4. **Para Bajas:**
   - Folio de baja
   - Fecha de cancelación

5. **Para Cambios de Cajones:**
   - Cantidad nueva de cajones
   - Fecha del cambio
   - Número de oficio

6. **Para Cambio de Categoría:**
   - Nueva categoría (del catálogo)
   - Fecha del cambio
   - Número de oficio

### Permisos Requeridos

- Usuario autenticado en el sistema
- Permisos para módulo de Estacionamientos
- Acceso a recaudadora correspondiente

---

## ¿Qué tablas utiliza?

### Tabla Principal

**`pubmain_esta`** - Tabla maestra de estacionamientos públicos
- Almacena todos los datos del estacionamiento
- Contiene información de licencias y predios vinculados
- Registra estatus actual (VIGENTE/CANCELADO)
- Guarda historial de movimientos

### Tablas de Soporte

1. **`pubadeudos`**
   - Almacena adeudos pendientes por año/mes
   - Registra importes, recargos y descuentos
   - Vincula con estacionamiento (pubmain_id)

2. **`pubcategorias`**
   - Catálogo de categorías de estacionamientos
   - Define tipos y descripciones
   - Determina costos asociados

3. **`pubpagos`** (implícita en operaciones)
   - Registra pagos realizados
   - Vincula operaciones de caja
   - Almacena detalles de cada transacción

4. **`pubmovtos`**
   - Historial de movimientos del estacionamiento
   - Registra cambios de cajones
   - Almacena cambios de categoría

5. **`pubmultas_rel`**
   - Multas relacionadas al estacionamiento
   - Infracciones pendientes y liquidadas

6. **Tablas de Predio (consulta)**
   - Se consultan para validar cuenta predial
   - Obtener datos de ubicación
   - Verificar estatus del predio

---

## ¿Qué procedimientos almacenados consume?

### Procedimientos Principales

1. **`sp_actualizapubpago`**
   - **Parámetros:** opc, pubmain_id, axo, mes, tipo, fecha, reca, caja, operacion
   - **Función:** Aplica un pago realizado a un adeudo específico
   - **Retorna:** id (0=éxito), mensaje descriptivo

2. **`sp_movtos`**
   - **Parámetros:** opc, pubmain_id, fecha, cajones, categoria, oficio, usuario
   - **Función:**
     - opc=1: Incremento/decremento de cajones
     - opc=2: Cambio de categoría
   - **Retorna:** resultado (0=éxito)

3. **`sp_conspredio`**
   - **Parámetros:** opc, dato
   - **Función:** Consulta información de predio virtual
   - **Retorna:** Datos completos del predio, estatus, mensaje

4. **Queries de Actualización (Query1, Query3)**
   - Ejecutan actualizaciones directas a `pubmain_esta`
   - Validan datos antes de guardar
   - Retornan resultado y mensaje

---

## ¿Qué tablas afecta?

### Modificaciones Directas

1. **`pubmain_esta`**
   - Actualiza todos los campos del estacionamiento
   - Modifica estatus (movto_cve: V=Vigente, C=Cancelado)
   - Actualiza contador de movimientos
   - Registra usuario que realizó el cambio

2. **`pubadeudos`**
   - **Elimina:** Adeudos específicos cuando se aplica baja
   - **Modifica:** Cambia estatus al aplicar pagos
   - **Crea:** Genera adeudos por solicitud de forma

3. **`pubmovtos`**
   - **Inserta:** Nuevo registro por cada movimiento
   - Almacena cambios de cajones
   - Registra cambios de categoría

4. **`pubpagos`** (a través de sp)
   - **Inserta:** Registro de cada pago aplicado
   - Vincula con operación de caja
   - Actualiza importes y conceptos

---

## Repercusiones en el Sistema

### Impacto Operativo

#### Modificación de Datos
- **Positivo:** Mantiene información actualizada del padrón
- **Cuidado:** Cambios en cuenta predial afectan facturación
- **Atención:** Modificar licencia puede desvincular registros

#### Aplicación de Pagos
- **Positivo:** Regulariza adeudos pendientes
- **Cuidado:** Debe coincidir con operación de caja real
- **Crítico:** No puede revertirse fácilmente
- **Auditoría:** Queda registrado usuario y fecha

#### Baja de Estacionamiento
- **Crítico:** Es una operación casi irreversible
- **Impacto:** Bloquea todas las operaciones futuras
- **Requerimiento:** Debe existir folio oficial
- **Consecuencia:** Ya no se generarán adeudos nuevos

#### Cambio de Cajones
- **Impacto:** Puede modificar cálculo de adeudos futuros
- **Requiere:** Autorización oficial (oficio)
- **Historial:** Se mantiene registro del cambio

#### Cambio de Categoría
- **Impacto Mayor:** Afecta costos de servicios
- **Requiere:** Autorización oficial (oficio)
- **Consecuencia:** Modifica base de cálculo de pagos

### Impacto en Recaudación

1. **Adeudos Pendientes:**
   - Los cambios pueden afectar montos a cobrar
   - Se recalculan según nueva configuración

2. **Recibos Emitidos:**
   - No se modifican recibos ya pagados
   - Solo afecta adeudos futuros

3. **Reportes y Estadísticas:**
   - Los cambios de categoría afectan reportes por tipo
   - Las bajas reducen padrón activo

---

## Validaciones Importantes

### Antes de Modificar
- ✓ Estacionamiento debe existir
- ✓ No puede estar CANCELADO (excepto para consulta)
- ✓ Cuenta predial debe ser válida y activa
- ✓ Usuario debe tener permisos

### Antes de Aplicar Pagos
- ✓ Debe existir el adeudo del año/mes indicado
- ✓ Operación de caja debe ser válida
- ✓ Estacionamiento debe estar VIGENTE
- ✓ No se puede duplicar aplicación

### Antes de Dar de Baja
- ✓ Debe capturarse folio obligatorio
- ✓ Fecha de baja válida
- ✓ No puede haber adeudos pendientes (recomendación)

---

## Consultas y Reportes

### Información que Muestra

1. **Datos Generales:**
   - Número de estacionamiento
   - Nombre del propietario
   - Ubicación completa
   - Teléfono de contacto

2. **Datos Técnicos:**
   - Categoría asignada
   - Número de cajones (cupo)
   - Licencia vinculada
   - Cuenta predial asociada

3. **Datos Administrativos:**
   - Número de solicitud
   - Número de control
   - Fechas importantes
   - Estatus actual

4. **Adeudos:**
   - Lista por año y mes
   - Importes y recargos
   - Totales pendientes

5. **Recibos:**
   - Historial de pagos
   - Detalle por operación
   - Conceptos pagados

6. **Multas:**
   - Multas relacionadas
   - Estatus de cada multa
   - Botón para dar mantenimiento

### Visualización de Mapa
- Permite ver ubicación del predio en visor cartográfico
- Requiere clave catastral válida
- Abre en navegador embebido

---

## Usuarios del Sistema

### Usuario Técnico
- Realiza todas las operaciones administrativas
- Requiere conocimiento de procedimientos municipales
- Debe validar documentación soporte

### Usuario Operativo
- Consulta información del estacionamiento
- Aplica pagos realizados en caja
- Imprime estados de cuenta

### Usuario Administrativo
- Autoriza bajas y cambios de categoría
- Supervisa incrementos de cajones
- Valida operaciones especiales

---

## Consideraciones Especiales

1. **Seguridad:**
   - Todas las operaciones quedan auditadas (usuario, fecha)
   - No se pueden eliminar registros, solo cancelar
   - Los cambios críticos requieren oficios

2. **Integridad:**
   - Validación de cuenta predial en tiempo real
   - Verificación de existencia de licencia
   - Control de duplicados en número de estacionamiento

3. **Trazabilidad:**
   - Cada modificación incrementa contador de movimientos
   - Se registra clave de movimiento (M=Modificación, C=Cancelación)
   - Se almacena usuario responsable

4. **Interfaz:**
   - Sistema de pestañas según modo de operación
   - Ventanas emergentes para operaciones críticas
   - Menús contextuales para adeudos

---

## Notas Técnicas para Soporte

- El campo `movtos_no` cuenta las veces que se ha modificado el registro
- El campo `movto_cve` indica estatus: 'V'=Vigente, 'M'=Modificado, 'C'=Cancelado
- Las fechas de vencimiento pueden ser fijas o calculadas
- El sistema valida que no existan adeudos antes de permitir ciertas operaciones
- La consulta de predio se hace mediante procedimiento almacenado que conecta con sistema externo
- Las multas se gestionan en módulo separado pero se visualizan aquí

---

## Resumen Ejecutivo

Este módulo es la **herramienta central** para la administración del padrón de estacionamientos públicos. Permite mantener actualizada toda la información, gestionar los cobros y pagos, controlar cambios en la capacidad y categorización, y dar de baja establecimientos cuando corresponda.

**Es crítico** que los usuarios comprendan que las operaciones realizadas aquí tienen impacto directo en la recaudación municipal y deben realizarse con la documentación soporte correspondiente (oficios, solicitudes, comprobantes de pago).

El sistema proporciona **múltiples validaciones** para evitar errores, pero la responsabilidad final de la correcta captura recae en el usuario operador.
