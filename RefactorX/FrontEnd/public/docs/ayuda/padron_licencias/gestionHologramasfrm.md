# Gestion de Hologramas

## Descripcion General

### Que hace este modulo
El modulo de Gestion de Hologramas administra el control, autorizacion y entrega de hologramas de seguridad que se colocan en establecimientos con licencia. Los hologramas son calcomanias de seguridad oficial que identifican que un negocio cuenta con sus permisos al corriente y sirven como control visual para inspecciones.

### Para que sirve en el proceso administrativo
Este modulo sirve para:
- Autorizar la emision de hologramas a contribuyentes
- Registrar la entrega fisica de hologramas
- Controlar el inventario de hologramas por rango de folios
- Generar recibos de pago por los hologramas
- Consultar historial de hologramas autorizados y entregados
- Llevar registro de quien autoriza y quien entrega
- Generar listados estadisticos de hologramas

### Quienes lo utilizan
- Personal de Recaudacion (dependencia 30) para autorizar hologramas
- Personal de Ventanilla para entregar hologramas
- Supervisores para consultar y generar listados
- Auditores para verificar control de inventarios
- Personal de archivo para control documental

## Proceso Administrativo

### Como funciona el proceso paso a paso

**Proceso de Autorizacion de Hologramas (Personal de Recaudacion):**

1. Usuario con clave de dependencia 30 accede al modulo
2. Presiona boton "Autoriza"
3. Sistema habilita formulario de captura
4. Usuario selecciona el propietario/contribuyente de un catalogo
5. Captura cantidad de hologramas a autorizar
6. Captura numero inicial del rango de hologramas
7. Sistema calcula automaticamente el numero final (inicial + cantidad - 1)
8. Usuario presiona "Aceptar"
9. Sistema:
   - Registra usuario que autoriza
   - Registra fecha de autorizacion
   - Calcula costo (30 pesos por holograma)
   - Genera e imprime recibo automaticamente
   - Guarda registro en base de datos
10. Sistema actualiza listado de hologramas

**Proceso de Entrega de Hologramas (Personal de Ventanilla):**

1. Usuario sin dependencia 30 accede al modulo
2. Selecciona un holograma autorizado pero no entregado del listado
3. Presiona boton "Entrega"
4. Sistema habilita campos de entrega
5. Usuario captura:
   - Nombre de quien recibe
   - Identificacion oficial con que recoge
6. Usuario presiona "Aceptar"
7. Sistema:
   - Registra usuario que entrega
   - Registra fecha de entrega
   - Marca el holograma como entregado
   - Actualiza registro
8. Sistema regresa a modo consulta

**Consultas y Reportes:**

1. Usuario puede buscar hologramas por:
   - Numero de folio
   - Nombre del propietario
   - Domicilio
   - Rango de fechas de entrega

2. Usuario puede generar:
   - Listado general de hologramas
   - Reimprimir recibo de un holograma especifico

### Que informacion requiere el usuario

**Para Autorizar Hologramas:**
- Propietario/Contribuyente (seleccion de catalogo)
- Cantidad de hologramas
- Numero inicial del rango de folios
- Sistema calcula: numero final, costo total

**Para Entregar Hologramas:**
- Nombre de quien recibe
- Identificacion oficial presentada

**Para Consultas:**
- Folio del holograma (opcional)
- Nombre del propietario (parcial, opcional)
- Domicilio (parcial, opcional)
- Rango de fechas de entrega (opcional)

### Que validaciones se realizan

1. **Control por Dependencia:**
   - Si usuario pertenece a dependencia 30 (Recaudacion):
     - Puede AUTORIZAR hologramas
     - Puede reimprimir recibos
   - Si usuario NO pertenece a dependencia 30:
     - Solo puede ENTREGAR hologramas autorizados

2. **Calculo Automatico:**
   - Numero final = Numero inicial + Cantidad - 1
   - Garantiza que el rango sea continuo y correcto

3. **Registro de Usuarios:**
   - Usuario que autoriza queda registrado
   - Usuario que entrega queda registrado
   - Fechas de cada operacion se guardan automaticamente

4. **Validacion de Recibo:**
   - Costo fijo de $30.00 por holograma
   - Se convierte cantidad a letras automaticamente
   - Se genera concepto descriptivo

### Que documentos genera

1. **Recibo de Pago:**
   - Generado automaticamente al autorizar hologramas
   - Incluye:
     - Logo institucional
     - Datos del contribuyente
     - Cantidad de hologramas
     - Costo en numero y letra
     - Folio del recibo
     - Fecha de emision
   - Formato oficial para comprobacion

2. **Listado de Hologramas:**
   - Reporte con todos los hologramas del sistema
   - Incluye:
     - Folio
     - Nombre del propietario
     - Domicilio
     - Cantidad de hologramas
     - Rango (inicial - final)
     - Usuario que autorizo
     - Fecha de autorizacion
     - Usuario que entrego
     - Fecha de entrega
   - Ordenado por folio
   - Con totales de cantidad

## Tablas de Base de Datos

### Tabla Principal
- **hologramas:** Registro de todos los hologramas autorizados y entregados, con control de rangos de folios, fechas, usuarios y contribuyentes

### Tablas Relacionadas

**Tablas que Consulta:**
- **c_contribholog (catalogo de contribuyentes para hologramas):** Listado de propietarios que pueden recibir hologramas
- **hologramas:** Para consultas y reportes
- **usr (usuarios):** Para validar dependencia del usuario actual
- **parametros_lic:** Para obtener costo del holograma (aunque en codigo esta fijo en 30)

**Tablas que Modifica:**
- **hologramas:**
  - INSERT al autorizar nuevos hologramas
  - UPDATE al registrar la entrega

## Stored Procedures
- **Ninguno:** No utiliza procedimientos almacenados, maneja transacciones directamente

## Impacto y Repercusiones

### Que registros afecta

**Al Autorizar:**
- Crea nuevo registro en tabla hologramas
- Establece:
  - Folio (consecutivo)
  - Contribuyente
  - Cantidad y rango de hologramas
  - Usuario que autoriza
  - Fecha de autorizacion
  - Marca como NO entregado

**Al Entregar:**
- Actualiza registro existente
- Agrega:
  - Usuario que entrega
  - Fecha de entrega
  - Nombre de quien recibe
  - Identificacion presentada
  - Marca como entregado

### Que cambios de estado provoca

1. **Nuevo Holograma:**
   - Estado: Autorizado (pendiente de entrega)
   - Usuario autorizante registrado
   - Fecha de autorizacion registrada

2. **Holograma Entregado:**
   - Estado: Autorizado Y Entregado (completo)
   - Usuario que entrego registrado
   - Fecha de entrega registrada
   - Datos de quien recibio registrados

### Que documentos/reportes genera

1. **Recibo de Pago (automatico al autorizar)**
2. **Listado de Hologramas (a solicitud)**
3. **Reimprimir Recibo (para hologramas especificos)**

### Que validaciones de negocio aplica

1. **Control de Permisos por Dependencia:**
   - Segmentacion de funciones segun area
   - Evita que personal no autorizado emita hologramas

2. **Rastreabilidad:**
   - Quien autorizo
   - Quien entrego
   - Cuando se realizo cada operacion
   - A quien se entrego

3. **Control de Inventario:**
   - Registro de rangos de folios
   - Control de cantidades
   - Seguimiento de stock

4. **Integridad Financiera:**
   - Costo estandarizado
   - Recibo automatico
   - Conversion a letra del monto

## Flujo de Trabajo

### Descripcion del flujo completo del proceso

**Flujo Completo de Autorizacion y Entrega:**

```
1. AUTORIZACION (Usuario de Recaudacion)
   a. Contribuyente paga derecho de hologramas en caja
   b. Personal de recaudacion abre modulo
   c. Click en "Autoriza"
   d. Selecciona contribuyente
   e. Captura cantidad y folio inicial
   f. Sistema calcula folio final
   g. Click en "Aceptar"
   h. Sistema genera registro
   i. Sistema imprime recibo automaticamente
   j. Se entrega recibo al contribuyente
   k. Holograma queda en estado "Autorizado, pendiente de entrega"

2. ENTREGA (Usuario de Ventanilla)
   l. Contribuyente acude con recibo a recoger hologramas
   m. Personal de ventanilla abre modulo
   n. Busca el holograma por folio o nombre
   o. Selecciona registro del listado
   p. Click en "Entrega"
   q. Captura nombre de quien recibe
   r. Captura identificacion oficial
   s. Click en "Aceptar"
   t. Sistema registra entrega
   u. Se entregan hologramas fisicos al contribuyente
   v. Holograma queda en estado "Entregado"

3. CONTROL Y CONSULTA (Supervisor)
   w. Puede consultar en cualquier momento
   x. Genera listados para auditoria
   y. Verifica inventarios pendientes
   z. Reimprimir recibos si es necesario
```

**Flujo de Consulta:**

```
1. Usuario abre modulo
2. Selecciona criterio de busqueda (folio, nombre, domicilio, fecha)
3. Captura valor a buscar
4. Presiona boton de busqueda correspondiente
5. Sistema filtra y muestra resultados
6. Usuario puede ordenar por folio o por nombre (radiobuttons)
7. Usuario selecciona registro para ver detalle
8. Puede generar listado o reimprimir recibo
```

## Notas Importantes

### Consideraciones especiales

1. **Costo de Hologramas:**
   - En el codigo esta hardcoded en 30 pesos
   - Existe referencia a parametros_lic pero no se usa
   - Para cambiar costo, se debe modificar codigo

2. **Doble Funcion del Modulo:**
   - Un modulo sirve para dos procesos diferentes
   - La funcionalidad depende del usuario logueado
   - Separacion clara entre autorizar y entregar

3. **Impresion Automatica:**
   - Al autorizar, el recibo se imprime automaticamente
   - No pide confirmacion al usuario
   - Se asume que siempre se necesita el recibo

4. **Rangos de Hologramas:**
   - Los hologramas tienen numeros de folio consecutivos
   - Se registra el rango completo (inicial - final)
   - Facilita el control de inventario fisico

5. **Catalogo de Contribuyentes:**
   - Es un catalogo separado (c_contribholog)
   - No todos los contribuyentes del sistema estan aqui
   - Solo quienes estan autorizados para recibir hologramas

### Restricciones

1. **No se puede Modificar:**
   - Una vez autorizado, no se puede cambiar cantidad ni folio
   - No hay opcion de editar
   - Si hay error, se debe gestionar fuera del sistema

2. **No se puede Cancelar:**
   - No existe funcionalidad para cancelar hologramas
   - Una vez en el sistema, queda registrado permanentemente

3. **Dependencia de Usuario:**
   - Las funciones disponibles dependen de la dependencia del usuario
   - No hay forma de sobreescribir este control

### Permisos necesarios

**Para Autorizar (Dependencia 30):**
- Acceso al modulo
- Permisos de insercion en tabla hologramas
- Permisos de impresion de recibos

**Para Entregar (Otras dependencias):**
- Acceso al modulo
- Permisos de actualizacion en tabla hologramas

**Para Consultas:**
- Permisos de lectura en tablas hologramas y c_contribholog

### Integracion con otros modulos

**Modulos Relacionados:**
- **Propietarios de Hologramas:** Catalogo de contribuyentes elegibles
- **Recaudacion:** Para proceso de cobro
- **Licencias:** Los hologramas se asocian a establecimientos con licencia
- **Reportes Gerenciales:** Estadisticas de hologramas emitidos

### Importancia del Control de Hologramas

1. **Seguridad:** Los hologramas previenen falsificaciones
2. **Identificacion Visual:** Facilitan inspecciones en campo
3. **Control Administrativo:** Rastreabilidad de emision
4. **Comprobacion:** El establecimiento puede demostrar que esta al corriente
5. **Inventario:** Control de calcomanias fisicas entregadas
